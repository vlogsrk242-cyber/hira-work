import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  bool loading = false;

  Future<void> saveWorker({
    WorkerData? worker,
    int? index,
  }) async {
    final nameController = TextEditingController(
      text: worker?.name ?? '',
    );

    final mobileController = TextEditingController(
      text: worker?.mobile ?? '',
    );

    final factoryController = TextEditingController(
      text: worker?.factoryNumber ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            worker == null
                ? 'કારીગર ઉમેરો'
                : 'કારીગર Edit કરો',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'કારીગરનું નામ',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'મોબાઈલ નંબર',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: factoryController,
                  decoration: const InputDecoration(
                    labelText: 'કારખાના નંબર',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final mobile = mobileController.text.trim();
                final factory =
                    factoryController.text.trim();

                if (name.isEmpty ||
                    mobile.isEmpty ||
                    factory.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('બધી માહિતી ભરો'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  setState(() {
                    loading = true;
                  });

                  if (worker == null) {
                    // New worker → Firebase
                    final doc = await firestore
                        .collection('karigars')
                        .add({
                      'name': name,
                      'mobile': mobile,
                      'factoryNumber': factory,
                      'createdAt':
                          FieldValue.serverTimestamp(),
                    });

                    setState(() {
                      AppData.workers.add(
                        WorkerData(
                          name: name,
                          mobile: mobile,
                          factoryNumber: factory,
                        ),
                      );
                    });

                    debugPrint(
                      'Karigar saved: ${doc.id}',
                    );
                  } else {
                    // Edit existing worker
                    final oldWorker = worker;

                    final result = await firestore
                        .collection('karigars')
                        .where(
                          'name',
                          isEqualTo: oldWorker.name,
                        )
                        .where(
                          'mobile',
                          isEqualTo: oldWorker.mobile,
                        )
                        .where(
                          'factoryNumber',
                          isEqualTo:
                              oldWorker.factoryNumber,
                        )
                        .limit(1)
                        .get();

                    if (result.docs.isNotEmpty) {
                      await result.docs.first.reference
                          .update({
                        'name': name,
                        'mobile': mobile,
                        'factoryNumber': factory,
                      });
                    }

                    setState(() {
                      AppData.workers[index!] =
                          WorkerData(
                        name: name,
                        mobile: mobile,
                        factoryNumber: factory,
                      );
                    });
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('કારીગર online databaseમાં Save થયો'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Databaseમાં Save કરવામાં ભૂલ થઈ',
                        ),
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteWorker(int index) {
    final worker = AppData.workers[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'કારીગર Delete કરો?',
          ),
          content: Text(
            'શું તમે "${worker.name}" ને Delete કરવા માંગો છો?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  setState(() {
                    loading = true;
                  });

                  final result = await firestore
                      .collection('karigars')
                      .where(
                        'name',
                        isEqualTo: worker.name,
                      )
                      .where(
                        'mobile',
                        isEqualTo: worker.mobile,
                      )
                      .where(
                        'factoryNumber',
                        isEqualTo:
                            worker.factoryNumber,
                      )
                      .limit(1)
                      .get();

                  if (result.docs.isNotEmpty) {
                    await result.docs.first.reference.delete();
                  }

                  setState(() {
                    AppData.workers.removeAt(index);
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('કારીગર Delete થઈ ગયો'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Delete કરવામાં ભૂલ થઈ'),
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👷 કારીગર'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : AppData.workers.isEmpty
              ? const Center(
                  child: Text(
                    'હજુ કોઈ કારીગર ઉમેરાયો નથી',
                    style: TextStyle(fontSize: 17),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: AppData.workers.length,
                  itemBuilder: (context, index) {
                    final worker =
                        AppData.workers[index];

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          worker.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'મોબાઈલ: ${worker.mobile}\n'
                          'કારખાના નંબર: ${worker.factoryNumber}',
                        ),
                        isThreeLine: true,
                        trailing:
                            PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              saveWorker(
                                worker: worker,
                                index: index,
                              );
                            }

                            if (value == 'delete') {
                              deleteWorker(index);
                            }
                          },
                          itemBuilder: (context) =>
                              const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: loading
            ? null
            : () {
                saveWorker();
              },
        icon: const Icon(Icons.person_add),
        label: const Text('કારીગર ઉમેરો'),
      ),
    );
  }
}
