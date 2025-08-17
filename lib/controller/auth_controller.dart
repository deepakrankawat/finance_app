import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_app/model/UserDataModel.dart';
import 'package:finance_app/view/home_view.dart';
import 'package:finance_app/view/login_view.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../utils/shared_prefs.dart';


// same imports...

class AuthController extends GetxController with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;
  RxString userName = ''.obs;
  Rx<User?> currentUser = Rx<User?>(null);
  var verificationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadUserState();
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        updateUserOnlineStatus(false); // User logged out
      } else {
        updateUserOnlineStatus(true); // User logged in
      }
    });
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        updateUserOnlineStatus(false); // No internet connection
      } else {
        updateUserOnlineStatus(true); // Internet connection available
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      updateUserOnlineStatus(true); // User is online (app in foreground)
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      updateUserOnlineStatus(false); // User is offline (app in background or terminated)
    }
  }

  Future<void> _loadUserState() async {
    isLoggedIn.value = await SharedPrefs.isLoggedIn();
    currentUser.value = _auth.currentUser;
    if (currentUser.value != null) {
      await _fetchUserData(currentUser.value!);
      updateUserOnlineStatus(true); // Set online status on app start if already logged in
    }
  }

  Future<void> _fetchUserData(User user) async {
    final DocumentSnapshot snapshot =
        await _firestore.collection("users").doc(user.uid).get();
    if (snapshot.exists) {
      final fetchedUser = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      userName.value = fetchedUser.name;
    } else {
      // If the user document doesn't exist, log them out.
      await logout();
    }
  }

  Future<void> updateUserOnlineStatus(bool isOnline) async {
    if (_auth.currentUser == null) return;
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'isOnline': isOnline});
  }

  Future<void> signUpWithEmail(String email, String password  , String name, {String? photoUrl}) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password, displayName: name);
      if (cred.user != null) {
        await cred.user!.updateDisplayName(name);
        if (photoUrl != null) {
          await cred.user!.updatePhotoURL(photoUrl);
        }
        await _fetchOrCreateUser(cred.user!, name: name, photoUrl: photoUrl);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        await _fetchOrCreateUser(cred.user!);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

Future<void> loginWithGoogle() async {
  _setLoading(true);

  try {
    // Step 1: Trigger the Google Sign-In flow
    final GoogleSignIn googleSignIn = GoogleSignIn.standard();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // User canceled the login
    if (googleUser == null) {
      _setLoading(false);
      return;
    }

    // Step 2: Get the Google Auth details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Step 3: Create Firebase credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Step 4: Sign in to Firebase with the Google credential
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) throw Exception("Google login failed. No user found.");

    await _fetchOrCreateUser(user);

  } catch (e) {
    debugPrint("Google Sign-In Error: $e");
    Get.snackbar("Google Login Failed", e.toString());
  } finally {
    _setLoading(false);
  }
}

  Future<void> logout() async {
    _setLoading(true);
    try {
      await updateUserOnlineStatus(false); // Set offline status on logout
      await _auth.signOut();
      await _googleSignIn.signOut();
      await SharedPrefs.clear();

      isLoggedIn.value = false;
      userName.value = '';
      currentUser.value = null;
      Get.offAll(() => const LoginView());
    } catch (e) {
      Get.snackbar("Logout Failed", e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyPhone(String phoneNumber) async {
    _setLoading(true);
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCred = await _auth.signInWithCredential(credential);
        if (userCred.user != null) {
          await _fetchOrCreateUser(userCred.user!);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar("OTP Failed", e.message ?? "Verification failed");
        _setLoading(false);
      },
      codeSent: (String verId, int? resendToken) {
        verificationId.value = verId;
        _setLoading(false);
        Get.toNamed("/otp");
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId.value = verId;
      },
    );
  }

  Future<void> verifyOTP(String otp, String phone) async {
    _setLoading(true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      final userCred = await _auth.signInWithCredential(credential);

      if (userCred.user != null) {
        await _fetchOrCreateUser(userCred.user!, name: phone);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("OTP Error", e.message ?? "OTP failed");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchOrCreateUser(User user, {String? name, String? photoUrl}) async {
    final DocumentSnapshot snapshot =
        await _firestore.collection("users").doc(user.uid).get();

    if (snapshot.exists) {
      final fetchedUser = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      userName.value = fetchedUser.name;
      // Update existing user's online status to true
      await _firestore.collection("users").doc(user.uid).update({'isOnline': true});
    } else {
      final newUser = UserModel(
        uid: user.uid,
        name: name ?? user.displayName ?? user.email ?? "User",
        email: user.email ?? "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        photoUrl: photoUrl ?? user.photoURL,
        isOnline: true, // Set online status to true for new user
      );

      await _firestore.collection("users").doc(user.uid).set(newUser.toMap());
      userName.value = newUser.name;
    }

    currentUser.value = user;
    await SharedPrefs.setLoggedIn(true);
    isLoggedIn.value = true;
    Get.offAll(() => const HomeView());
    Get.snackbar("Success", "Welcome ${userName.value}");
  }

  void _handleAuthError(FirebaseAuthException e) {
    Get.snackbar("Auth Error", e.message ?? "Something went wrong");
  }

  void _setLoading(bool value) {
    isLoading.value = value;
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }
}
