import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  bool loading = false;

  String get currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>> get workersStream {
    return firestore
        .collection('karigars')
        .where('ownerUid', isEqualTo: currentUid)
        .snapshots();
  }

  Future<void> saveWorker({
    String? docId,
    Map<String, dynamic>? worker,
  }) async {
    final nameController = TextEditingController(
      text: worker?['name'] ?? '',
    );

    final mobileController = TextEditingController(
      text: worker?['mobile'] ?? '',
    );

    final factoryController = TextEditingController(
      text: worker?['factoryNumber'] ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            docId == null
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

                if (currentUid.isEmpty) {
                  _showMessage('કૃપા કરીને પહેલા Login કરો');
                  return;
                }

                try {
                  setState(() {
                    loading = true;
                  });

                  final data = {
                    'ownerUid': currentUid,
                    'name': name,
                    'mobile': mobile,
                    'factoryNumber': factory,
                    'updatedAt':
                        FieldValue.serverTimestamp(),
                  };

                  if (docId == null) {
                    await firestore
                        .collection('karigars')
                        .add({
                      ...data,
                      'createdAt':
                          FieldValue.serverTimestamp(),
                    });

                    _showMessage(
                      'કારીગર Firebaseમાં Save થયો',
                    );
                  } else {
                    await firestore
                        .collection('karigars')
                        .doc(docId)
                        .update(data);

                    _showMessage(
                      'કારીગર Update થયો',
                    );
                  }
                } catch (e) {
                  _showMessage(
                    'Databaseમાં Save કરવામાં ભૂલ થઈ',
                  );
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

  Future<void> deleteWorker(
    String docId,
    String workerName,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'કારીગર Delete કરો?',
          ),
          content: Text(
            'શું તમે "$workerName" ને Delete કરવા માંગો છો?',
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

                  await firestore
                      .collection('karigars')
                      .doc(docId)
                      .delete();

                  _showMessage(
                    'કારીગર Delete થઈ ગયો',
                  );
                } catch (e) {
                  _showMessage(
                    'Delete કરવામાં ભૂલ થઈ',
                  );
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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
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
          : currentUid.isEmpty
              ? const Center(
                  child: Text(
                    'કૃપા કરીને પહેલા Login કરો',
                  ),
                )
              : StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                  stream: workersStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'કારીગરનો ડેટા લાવવામાં ભૂલ થઈ',
                        ),
                      );
                    }

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final docs =
                        snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'હજુ કોઈ કારીગર ઉમેરાયો નથી',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();

                        final name =
                            data['name'] ?? '';

                        final mobile =
                            data['mobile'] ?? '';

                        final factory =
                            data['factoryNumber'] ?? '';

                        return Card(
                          child: ListTile(
                            leading:
                                const CircleAvatar(
                              child:
                                  Icon(Icons.person),
                            ),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'મોબાઈલ: $mobile\n'
                              'કારખાના નંબર: $factory',
                            ),
                            isThreeLine: true,
                            trailing:
                                PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  saveWorker(
                                    docId: doc.id,
                                    worker: data,
                                  );
                                }

                                if (value == 'delete') {
                                  deleteWorker(
                                    doc.id,
                                    name,
                                  );
                                }
                              },
                              itemBuilder:
                                  (context) =>
                                      const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child:
                                      Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child:
                                      Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
