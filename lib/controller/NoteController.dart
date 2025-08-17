import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_app/model/NoteModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NoteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<NoteModel> notes = <NoteModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  String? get userId => _auth.currentUser?.uid;

  Future<void> fetchNotes() async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .orderBy('updatedAt', descending: true)
          .get();
      notes.value = snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch notes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNote(String title, String content, {String? attachmentUrl}) async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      final newNote = NoteModel(
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        attachmentUrl: attachmentUrl,
      );
      await _firestore.collection('users').doc(userId).collection('notes').add(newNote.toMap());
      fetchNotes(); // Refresh notes after adding
      Get.snackbar("Success", "Note added successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add note: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateNote(NoteModel note) async {
    if (userId == null || note.id == null) return;

    isLoading.value = true;
    try {
      final updatedNoteMap = note.toMap();
      updatedNoteMap['updatedAt'] = DateTime.now(); // Update timestamp
      await _firestore.collection('users').doc(userId).collection('notes').doc(note.id).update(updatedNoteMap);
      fetchNotes(); // Refresh notes after updating
      Get.snackbar("Success", "Note updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update note: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNote(String noteId) async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      await _firestore.collection('users').doc(userId).collection('notes').doc(noteId).delete();
      fetchNotes(); // Refresh notes after deleting
      Get.snackbar("Success", "Note deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete note: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
