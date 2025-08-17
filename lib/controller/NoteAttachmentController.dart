import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class NoteAttachmentController extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  RxString attachmentUrl = RxString('');
  RxBool isLoading = false.obs;
  final RxBool _isPickerActive = false.obs;

  Future<void> pickAndUploadAttachment(String noteId) async {
    if (_isPickerActive.value) {
      return;
    }
    _isPickerActive.value = true;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? selectedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (selectedImage != null) {
        await _uploadAttachment(selectedImage, noteId);
      }
    } finally {
      _isPickerActive.value = false;
    }
  }

  Future<void> _uploadAttachment(XFile image, String noteId) async {
    isLoading.value = true;
    try {
      Get.snackbar("Uploading", "Uploading attachment...");
      final Reference storageRef =
          _storage.ref().child('note_attachments/$noteId.jpg');
      final Uint8List imageBytes = await image.readAsBytes();
      final UploadTask uploadTask = storageRef.putData(imageBytes);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      attachmentUrl.value = downloadUrl;
      Get.snackbar("Success", "Attachment uploaded successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload attachment: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
