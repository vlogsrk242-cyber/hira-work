import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final List<String> sections = [
    'તળીયા',
    'પેલ',
    'મથાળા',
  ];

  bool loading = false;

  String get currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get withdrawalsStream {
    return firestore
        .collection('withdrawals')
        .where(
          'ownerUid',
          isEqualTo: currentUid,
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get workersStream {
    return firestore
        .collection('karigars')
        .where(
          'ownerUid',
          isEqualTo: currentUid,
        )
        .snapshots();
  }

  void showWithdrawalForm({
    String? docId,
    Map<String, dynamic>? withdrawal,
  }) {
    String selectedSection =
        withdrawal?['section'] ?? sections.first;

    String selectedWorker =
        withdrawal?['worker'] ?? '';

    DateTime selectedDate = DateTime.now();

    if (withdrawal != null &&
        withdrawal['date'] != null) {
      try {
        selectedDate = DateFormat(
          'dd-MM-yyyy',
        ).parse(
          withdrawal['date'].toString(),
        );
      } catch (_) {}
    }

    final amountController =
        TextEditingController(
      text: withdrawal != null
          ? (withdrawal['amount'] ?? '')
              .toString()
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: workersStream,
          builder: (context, workerSnapshot) {
            final workerDocs =
                workerSnapshot.data?.docs ?? [];

            final workerNames = workerDocs
                .map(
                  (doc) =>
                      doc.data()['name']?.toString() ??
                      '',
                )
                .where((name) => name.isNotEmpty)
                .toList();

            if (selectedWorker.isEmpty &&
                workerNames.isNotEmpty) {
              selectedWorker = workerNames.first;
            }

            if (!workerNames.contains(selectedWorker)) {
              selectedWorker = workerNames.isNotEmpty
                  ? workerNames.first
                  : '';
            }

            return StatefulBuilder(
              builder: (
                dialogContext,
                setDialogState,
              ) {
                return AlertDialog(
                  title: Text(
                    docId == null
                        ? 'ઉપાડ ઉમેરો'
                        : 'ઉપાડ Edit કરો',
                  ),
                  content:
                      SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<
                            String>(
                          value: selectedSection,
                          decoration:
                              const InputDecoration(
                            labelText: 'વિભાગ',
                            prefixIcon:
                                Icon(
                              Icons.category,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                          items: sections
                              .map(
                                (section) =>
                                    DropdownMenuItem<
                                        String>(
                                  value: section,
                                  child:
                                      Text(section),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedSection =
                                    value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        InkWell(
                          onTap: () async {
                            final picked =
                                await showDatePicker(
                              context:
                                  dialogContext,
                              initialDate:
                                  selectedDate,
                              firstDate:
                                  DateTime(2020),
                              lastDate:
                                  DateTime(2100),
                            );

                            if (picked != null) {
                              setDialogState(() {
                                selectedDate =
                                    picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(
                              labelText: 'તારીખ',
                              prefixIcon:
                                  Icon(
                                Icons
                                    .calendar_month,
                              ),
                              border:
                                  OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat(
                                'dd-MM-yyyy',
                              ).format(
                                selectedDate,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (workerNames.isEmpty)
                          const Align(
                            alignment:
                                Alignment
                                    .centerLeft,
                            child: Text(
                              'પહેલા કારીગર ઉમેરો',
                              style: TextStyle(
                                color:
                                    Colors.red,
                              ),
                            ),
                          )
                        else
                          DropdownButtonFormField<
                              String>(
                            value:
                                selectedWorker,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'કારીગર',
                              prefixIcon:
                                  Icon(
                                Icons.person,
                              ),
                              border:
                                  OutlineInputBorder(),
                            ),
                            items: workerNames
                                .map(
                                  (name) =>
                                      DropdownMenuItem<
                                          String>(
                                    value: name,
                                    child:
                                        Text(name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedWorker =
                                      value;
                                });
                              }
                            },
                          ),

                        const SizedBox(height: 12),

                        TextField(
                          controller:
                              amountController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'ઉપાડની રકમ',
                            prefixIcon:
                                Icon(
                              Icons
                                  .currency_rupee,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                        );
                      },
                      child:
                          const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final amount =
                            double.tryParse(
                          amountController
                              .text
                              .trim(),
                        );

                        if (workerNames.isEmpty) {
                          _showMessage(
                            'પહેલા કારીગર ઉમેરો',
                          );
                          return;
                        }

                        if (amount == null ||
                            amount <= 0) {
                          _showMessage(
                            'ઉપાડની રકમ સાચી નાખો',
                          );
                          return;
                        }

                        if (currentUid.isEmpty) {
                          _showMessage(
                            'કૃપા કરીને પહેલા Login કરો',
                          );
                          return;
                        }

                        try {
                          Navigator.pop(
                            dialogContext,
                          );

                          setState(() {
                            loading = true;
                          });

                          final data = {
                            'ownerUid':
                                currentUid,
                            'section':
                                selectedSection,
                            'date': DateFormat(
                              'dd-MM-yyyy',
                            ).format(
                              selectedDate,
                            ),
                            'worker':
                                selectedWorker,
                            'amount': amount,
                            'updatedAt':
                                FieldValue
                                    .serverTimestamp(),
                          };

                          if (docId == null) {
                            await firestore
                                .collection(
                                  'withdrawals',
                                )
                                .add({
                              ...data,
                              'createdAt':
                                  FieldValue
                                      .serverTimestamp(),
                            });

                            _showMessage(
                              'ઉપાડ Firebaseમાં Save થયો',
                            );
                          } else {
                            await firestore
                                .collection(
                                  'withdrawals',
                                )
                                .doc(docId)
                                .update(data);

                            _showMessage(
                              'ઉપાડ Update થયો',
                            );
                          }
                        } catch (e) {
                          _showMessage(
                            'ઉપાડ Save કરવામાં ભૂલ થઈ',
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              loading = false;
                            });
                          }
                        }
                      },
                      child:
                          const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> deleteWithdrawal(
    String docId,
    String worker,
    double amount,
  ) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'ઉપાડ Delete કરો?',
          ),
          content: Text(
            'શું તમે $worker નો '
            '₹ ${amount.toStringAsFixed(2)} '
            'ઉપાડ Delete કરવા માંગો છો?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                try {
                  setState(() {
                    loading = true;
                  });

                  await firestore
                      .collection(
                        'withdrawals',
                      )
                      .doc(docId)
                      .delete();

                  _showMessage(
                    'ઉપાડ Delete થઈ ગયો',
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

  double calculateTotal(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    double total = 0;

    for (final doc in docs) {
      final amount =
          (doc.data()['amount'] ?? 0);

      if (amount is num) {
        total += amount.toDouble();
      } else {
        total +=
            double.tryParse(
                  amount.toString(),
                ) ??
                0;
      }
    }

    return total;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 ઉપાડ'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : currentUid.isEmpty
              ? const Center(
                  child: Text(
                    'કૃપા કરીને પહેલા Login કરો',
                  ),
                )
              : StreamBuilder<
                  QuerySnapshot<
                      Map<String, dynamic>>>(
                  stream: withdrawalsStream,
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'ઉપાડનો ડેટા લાવવામાં ભૂલ થઈ',
                        ),
                      );
                    }

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    final docs =
                        snapshot.data?.docs ?? [];

                    final total =
                        calculateTotal(docs);

                    return Column(
                      children: [
                        Expanded(
                          child: docs.isEmpty
                              ? const Center(
                                  child: Text(
                                    'હજુ કોઈ ઉપાડ ઉમેરાયો નથી',
                                    style:
                                        TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding:
                                      const EdgeInsets
                                          .all(12),
                                  itemCount:
                                      docs.length,
                                  itemBuilder:
                                      (
                                    context,
                                    index,
                                  ) {
                                    final doc =
                                        docs[index];

                                    final data =
                                        doc.data();

                                    final worker =
                                        data['worker'] ??
                                            '';

                                    final section =
                                        data['section'] ??
                                            '';

                                    final date =
                                        data['date'] ??
                                            '';

                                    final amount =
                                        (data['amount'] ??
                                                0)
                                            .toDouble();

                                    return Card(
                                      margin:
                                          const EdgeInsets
                                              .only(
                                        bottom: 12,
                                      ),
                                      child:
                                          ListTile(
                                        leading:
                                            const CircleAvatar(
                                          child:
                                              Icon(
                                            Icons
                                                .payments,
                                          ),
                                        ),
                                        title:
                                            Text(
                                          worker
                                              .toString(),
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                        subtitle:
                                            Text(
                                          'વિભાગ: $section\n'
                                          'તારીખ: $date\n'
                                          'ઉપાડ: ₹ ${amount.toStringAsFixed(2)}',
                                        ),
                                        isThreeLine:
                                            true,
                                        trailing:
                                            PopupMenuButton<
                                                String>(
                                          onSelected:
                                              (
                                            value,
                                          ) {
                                            if (value ==
                                                'edit') {
                                              showWithdrawalForm(
                                                docId:
                                                    doc.id,
                                                withdrawal:
                                                    data,
                                              );
                                            }

                                            if (value ==
                                                'delete') {
                                              deleteWithdrawal(
                                                doc.id,
                                                worker
                                                    .toString(),
                                                amount,
                                              );
                                            }
                                          },
                                          itemBuilder:
                                              (
                                            context,
                                          ) =>
                                              const [
                                            PopupMenuItem(
                                              value:
                                                  'edit',
                                              child:
                                                  Text(
                                                'Edit',
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value:
                                                  'delete',
                                              child:
                                                  Text(
                                                'Delete',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        SafeArea(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(12),
                            child: Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .all(16),
                                child: Text(
                                  'ટોટલ ઉપાડ: ₹ '
                                  '${total.toStringAsFixed(2)}',
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: loading
            ? null
            : () {
                showWithdrawalForm();
              },
        icon: const Icon(Icons.add),
        label:
            const Text('ઉપાડ ઉમેરો'),
      ),
    );
  }
}
