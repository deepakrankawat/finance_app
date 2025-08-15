import 'package:finance_app/controller/NoteController.dart';
import 'package:finance_app/view/AddEditNoteScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final noteController = Get.put(NoteController());
    return Scaffold(
      appBar: AppBar(title: const Text("My Notes")),
      body: Obx(() {
        if (noteController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (noteController.notes.isEmpty) {
          return const Center(child: Text("No notes yet. Add one!"));
        } else {
          return ListView.builder(
            itemCount: noteController.notes.length,
            itemBuilder: (context, index) {
              final note = noteController.notes[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    '${note.content}\nCreated: ${DateFormat.yMd().add_jm().format(note.createdAt)}\nUpdated: ${DateFormat.yMd().add_jm().format(note.updatedAt)}',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Get.to(() => AddEditNoteScreen(note: note));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Delete Note",
                        middleText:
                            "Are you sure you want to delete this note?",
                        textConfirm: "Delete",
                        textCancel: "Cancel",
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          noteController.deleteNote(note.id!);
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddEditNoteScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
