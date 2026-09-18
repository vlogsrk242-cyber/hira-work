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

  late final String userUid;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _withdrawalsStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _workersStream;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    userUid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userUid.isNotEmpty) {
      _withdrawalsStream = firestore
          .collection('withdrawals')
          .where(
            'ownerUid',
            isEqualTo: userUid,
          )
          .snapshots();

      _workersStream = firestore
          .collection('karigars')
          .where(
            'ownerUid',
            isEqualTo: userUid,
          )
          .snapshots();
    }
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
          stream: _workersStream,
          builder: (context, workerSnapshot) {
            if (workerSnapshot.hasError) {
              return AlertDialog(
                title: const Text('ઉપાડ'),
                content: const Text(
                  'કારીગરનો ડેટા લાવવામાં ભૂલ થઈ',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            }

            final workerDocs =
                workerSnapshot.data?.docs ?? [];

            final workerNames = workerDocs
                .map(
                  (doc) =>
                      doc.data()['name']
                          ?.toString()
                          .trim() ??
                      '',
                )
                .where(
                  (name) => name.isNotEmpty,
                )
                .toSet()
                .toList();

            workerNames.sort();

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
                bool dialogSaving = false;

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
                          onChanged: dialogSaving
                              ? null
                              : (value) {
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
                          onTap: dialogSaving
                              ? null
                              : () async {
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
                            onChanged: dialogSaving
                                ? null
                                : (value) {
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
                          enabled: !dialogSaving,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction:
                              TextInputAction.done,
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
                      onPressed: dialogSaving
                          ? null
                          : () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                      child:
                          const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: dialogSaving
                          ? null
                          : () async {
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

                              if (userUid.isEmpty) {
                                _showMessage(
                                  'કૃપા કરીને પહેલા Login કરો',
                                );
                                return;
                              }

                              setDialogState(() {
                                dialogSaving = true;
                              });

                              try {
                                final data = {
                                  'ownerUid':
                                      userUid,
                                  'section':
                                      selectedSection,
                                  'date':
                                      DateFormat(
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

                                  if (!mounted) {
                                    return;
                                  }

                                  Navigator.pop(
                                    dialogContext,
                                  );

                                  _showMessage(
                                    'ઉપાડ Firebaseમાં Save થયો',
                                  );
                                } else {
                                  await firestore
                                      .collection(
                                        'withdrawals',
                                      )
                                      .doc(docId)
                                      .update(
                                        data,
                                      );

                                  if (!mounted) {
                                    return;
                                  }

                                  Navigator.pop(
                                    dialogContext,
                                  );

                                  _showMessage(
                                    'ઉપાડ Update થયો',
                                  );
                                }
                              } catch (e) {
                                if (!mounted) {
                                  return;
                                }

                                setDialogState(() {
                                  dialogSaving = false;
                                });

                                _showMessage(
                                  'ઉપાડ Save કરવામાં ભૂલ થઈ',
                                );
                              }
                            },
                      child: dialogSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
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
      },
    ).then((_) {
      amountController.dispose();
    });
  }

  Future<void> deleteWithdrawal(
    String docId,
    String worker,
    double amount,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool deleting = false;

        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
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
                  onPressed: deleting
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: deleting
                      ? null
                      : () async {
                          setDialogState(() {
                            deleting = true;
                          });

                          try {
                            await firestore
                                .collection(
                                  'withdrawals',
                                )
                                .doc(docId)
                                .delete();

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                              true,
                            );

                            _showMessage(
                              'ઉપાડ Delete થઈ ગયો',
                            );
                          } catch (e) {
                            if (!mounted) {
                              return;
                            }

                            setDialogState(() {
                              deleting = false;
                            });

                            _showMessage(
                              'Delete કરવામાં ભૂલ થઈ',
                            );
                          }
                        },
                  child: deleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
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

    if (confirmed != true) {
      return;
    }
  }

  double calculateTotal(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    double total = 0;

    for (final doc in docs) {
      final amount =
          doc.data()['amount'];

      if (amount is num) {
        total += amount.toDouble();
      } else {
        total +=
            double.tryParse(
                  amount?.toString() ?? '',
                ) ??
                0;
      }
    }

    return total;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (userUid.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('💰 ઉપાડ'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'કૃપા કરીને પહેલા Login કરો',
          ),
        ),
        floatingActionButton:
            const SizedBox.shrink(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 ઉપાડ'),
        centerTitle: true,
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _withdrawalsStream,
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
                  ConnectionState.waiting &&
              !snapshot.hasData) {
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
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        itemCount: docs.length,
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
                              data['worker']
                                      ?.toString() ??
                                  '';

                          final section =
                              data['section']
                                      ?.toString() ??
                                  '';

                          final date =
                              data['date']
                                      ?.toString() ??
                                  '';

                          final amount =
                              _toDouble(
                            data['amount'],
                          );

                          return Card(
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 12,
                            ),
                            child: ListTile(
                              leading:
                                  const CircleAvatar(
                                child: Icon(
                                  Icons.payments,
                                ),
                              ),
                              title: Text(
                                worker,
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
                                      worker,
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
                                    value: 'edit',
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
                      const EdgeInsets.all(12),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
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
        onPressed: saving
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

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
