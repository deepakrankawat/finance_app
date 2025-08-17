import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadDataController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  RxString imageUrl = RxString(''); // Observable for image URL
  RxBool isLoading = false.obs;
  final RxBool _isPickerActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize imageUrl with current user's photoURL if available
    imageUrl.value = _auth.currentUser?.photoURL ?? '';
  }

  Future<void> pickAndUploadImage() async {
    if (_isPickerActive.value) {
      return;
    }
    _isPickerActive.value = true;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? selectedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // Limit width to 1024 pixels
        maxHeight: 1024, // Limit height to 1024 pixels
        imageQuality: 80, // Compress image quality to 80%
      );

      if (selectedImage != null) {
        await _uploadImage(selectedImage);
      }
    } finally {
      _isPickerActive.value = false;
    }
  }

  Future<void> _uploadImage(XFile image) async {
    if (_auth.currentUser == null) return;

    isLoading.value = true;
    try {
      Get.snackbar("Uploading", "Uploading profile picture...");
      final String userId = _auth.currentUser!.uid;
      final Reference storageRef = _storage.ref().child('profile_images/$userId.jpg');
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await _updateUserProfile(downloadUrl);
      imageUrl.value = downloadUrl; // Update observable URL
      Get.snackbar("Success", "Profile picture uploaded successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload profile picture: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateUserProfile(String newImageUrl) async {
    if (_auth.currentUser == null) return;

    try {
      // Update Firebase Auth profile
      await _auth.currentUser!.updatePhotoURL(newImageUrl);

      // Update Firestore user document
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'photoUrl': newImageUrl,
       
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar("Error", "Failed to update user profile: $e");
    }
  }
}
