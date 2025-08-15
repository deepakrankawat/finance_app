
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package.get/get.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString _searchQuery = ''.obs;
  RxList<QueryDocumentSnapshot> userList = <QueryDocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    _firestore.collection('users').get().then((querySnapshot) {
      userList.value = querySnapshot.docs;
    });
  }

  void search(String query) {
    _searchQuery.value = query;
  }

  List<QueryDocumentSnapshot> get filteredUsers {
    if (_searchQuery.value.isEmpty) {
      return userList;
    }
    return userList
        .where((user) =>
            user['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.value.toLowerCase()) ||
            user['email']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.value.toLowerCase()))
        .toList();
  }
}
