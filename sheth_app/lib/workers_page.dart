import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final String userUid;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _workersStream;

  @override
  void initState() {
    super.initState();

    userUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userUid.isNotEmpty) {
      _workersStream = firestore
          .collection('karigars')
          .where('ownerUid', isEqualTo: userUid)
          .snapshots();
    }
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

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              if (saving) return;

              final name = nameController.text.trim();
              final mobile = mobileController.text.trim();
              final factory = factoryController.text.trim();

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

              if (userUid.isEmpty) {
                Navigator.pop(dialogContext);

                _showMessage(
                  'કૃપા કરીને પહેલા Login કરો',
                );
                return;
              }

              FocusScope.of(context).unfocus();

              // Firestore network ફરી enable કરો
              await firestore.enableNetwork();

              setDialogState(() {
                saving = true;
              });

              try {
                final data = <String, dynamic>{
                  'ownerUid': userUid,
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
                  })
                      .timeout(
                    const Duration(seconds: 15),
                    onTimeout: () {
                      throw Exception(
                        'Firestore connection timeout: 15 seconds સુધી Firebase તરફથી જવાબ મળ્યો નથી.',
                      );
                    },
                  );
                } else {
                  await firestore
                      .collection('karigars')
                      .doc(docId)
                      .update(data)
                      .timeout(
                    const Duration(seconds: 15),
                    onTimeout: () {
                      throw Exception(
                        'Firestore connection timeout: 15 seconds સુધી Firebase તરફથી જવાબ મળ્યો નથી.',
                      );
                    },
                  );
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);

                _showMessage(
                  docId == null
                      ? 'કારીગર Firebaseમાં Save થયો'
                      : 'કારીગર Update થયો',
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  saving = false;
                });

                _showMessage(
                  'Firebase Error: $e',
                );
              }
            }

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
                      textInputAction: TextInputAction.next,
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
                      textInputAction: TextInputAction.next,
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
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => save(),
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
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    mobileController.dispose();
    factoryController.dispose();
  }

  Future<void> deleteWorker(
    String docId,
    String workerName,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool deleting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> delete() async {
              if (deleting) return;

              setDialogState(() {
                deleting = true;
              });

              try {
                await firestore
                    .collection('karigars')
                    .doc(docId)
                    .delete()
                    .timeout(
                  const Duration(seconds: 15),
                  onTimeout: () {
                    throw Exception(
                      'Firestore connection timeout: 15 seconds સુધી Firebase તરફથી જવાબ મળ્યો નથી.',
                    );
                  },
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                _showMessage(
                  'કારીગર Delete થઈ ગયો',
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  deleting = false;
                });

                _showMessage(
                  'Delete Error: $e',
                );
              }
            }

            return AlertDialog(
              title: const Text(
                'કારીગર Delete કરો?',
              ),
              content: Text(
                'શું તમે "$workerName" ને Delete કરવા માંગો છો?',
              ),
              actions: [
                TextButton(
                  onPressed: deleting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: deleting ? null : delete,
                  child: deleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (userUid.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('👷 કારીગર'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'કૃપા કરીને પહેલા Login કરો',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('👷 કારીગર'),
        centerTitle: true,
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _workersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'કારીગરનો ડેટા લાવવામાં ભૂલ થઈ\n\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

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
                  data['name']?.toString() ?? '';

              final mobile =
                  data['mobile']?.toString() ?? '';

              final factory =
                  data['factoryNumber']?.toString() ?? '';

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),

                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'મોબાઈલ: $mobile\n'
                    'કારખાના નંબર: $factory',
                  ),

                  isThreeLine: true,

                  trailing: PopupMenuButton<String>(
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
                    itemBuilder: (context) => const [
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
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          saveWorker();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('કારીગર ઉમેરો'),
      ),
    );
  }
}
