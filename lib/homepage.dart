import 'package:flutter/material.dart';
// Alias added to avoid 'context' conflict from path package
import 'package:path/path.dart' as path;
import 'package:project1/data/local/db_helper.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late TextEditingController titleController;
  late TextEditingController descController;

  List<Map<String, dynamic>> allNotes = [];
  late DbHelper dbRef;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descController = TextEditingController();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef.getAllNotes();
    setState(() {});
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      body:
          allNotes.isNotEmpty
              ? ListView.builder(
                itemCount: allNotes.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    leading: Text(
                      "${index+1}",
                    ),
                    title: Text(allNotes[index][DbHelper.COLUMN_NOTE_title]),
                    subtitle: Text(allNotes[index][DbHelper.COLUMN_NOTE_desc]),
                    trailing: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  titleController.text =
                                      allNotes[index][DbHelper
                                          .COLUMN_NOTE_title];
                                  descController.text =
                                      allNotes[index][DbHelper
                                          .COLUMN_NOTE_desc];
                                  return getBottomSheetWidget(
                                    isUpdate: true,
                                    context,
                                    sno:
                                        allNotes[index][DbHelper
                                            .COLUMN_NOTE_sno],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.edit),
                          ),
                          InkWell(
                            onTap: () async {
                              bool check = await dbRef!.deleteNote(
                                sno: allNotes[index][DbHelper.COLUMN_NOTE_sno],
                              );
                              if (check) {
                                getNotes();
                              }
                            },
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : const Center(child: Text("No notes yet")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,

            builder: (ctx) {
              titleController.clear();
              descController.clear();
              return getBottomSheetWidget(ctx);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget(
    BuildContext ctx, {
    bool isUpdate = false,
    int sno = 0,
  }) {
    return Padding(
      padding: MediaQuery.of(ctx).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(11),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isUpdate ? "Update" : "Add Note",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter Title here",
                labelText: "Title*",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter Description here",
                labelText: "Description*",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      String title = titleController.text.trim();
                      String desc = descController.text.trim();
                      if (title.isNotEmpty && desc.isNotEmpty) {
                        bool check =
                            isUpdate
                                ? await dbRef!.updateNote(
                                  mTitle: title,
                                  mDesc: desc,
                                  sno: sno,
                                )
                                : await dbRef.addNote(
                                  mTitle: title,
                                  mDesc: desc,
                                );
                        if (check) {
                          getNotes();
                        }
                        titleController.clear();
                        descController.clear();
                        Navigator.pop(ctx);
                      } else {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all required fields!"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(isUpdate ? "Update" : "Add Note"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
