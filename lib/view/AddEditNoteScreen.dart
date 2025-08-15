import 'package:finance_app/controller/NoteController.dart';
import 'package:finance_app/model/NoteModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final noteController = Get.find<NoteController>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? "Add Note" : "Edit Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
                  onPressed: noteController.isLoading.value
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final content = contentController.text.trim();

                          if (title.isEmpty || content.isEmpty) {
                            Get.snackbar("Error", "Title and content cannot be empty");
                            return;
                          }

                          if (widget.note == null) {
                            await noteController.addNote(title, content);
                          } else {
                            final updatedNote = NoteModel(
                              id: widget.note!.id,
                              title: title,
                              content: content,
                              createdAt: widget.note!.createdAt,
                              updatedAt: DateTime.now(),
                              
                            );
                            await noteController.updateNote(updatedNote);
                          }
                          Get.back();
                        },
                  child: noteController.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text(widget.note == null ? "Add Note" : "Update Note"),
                )),
          ],
        ),
      ),
    );
  }
}
