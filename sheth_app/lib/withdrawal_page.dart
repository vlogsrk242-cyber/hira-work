import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WithdrawalEntry {
  String section;
  String date;
  String worker;
  double amount;

  WithdrawalEntry({
    required this.section,
    required this.date,
    required this.worker,
    required this.amount,
  });
}

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final List<WithdrawalEntry> withdrawalEntries = [];

  final List<String> sections = [
    'તળીયા',
    'પેલ',
    'મથાળા',
  ];

  // હાલ Demo માટે કારીગરોની યાદી
  // પછી WorkersPage / Firebaseમાંથી આપમેળે આવશે.
  final List<String> workers = [
    'કારીગર પસંદ કરો',
    'રમેશ',
    'સુરેશ',
    'મહેશ',
  ];

  Future<void> selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.isNotEmpty) {
      try {
        initialDate =
            DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'તારીખ પસંદ કરો',
      cancelText: 'રદ કરો',
      confirmText: 'પસંદ કરો',
    );

    if (picked != null) {
      controller.text =
          DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  void showWithdrawalForm({
    WithdrawalEntry? entry,
    int? index,
  }) {
    String selectedSection =
        entry?.section ?? sections.first;

    String selectedWorker =
        entry?.worker ?? workers.first;

    final dateController = TextEditingController(
      text: entry?.date ??
          DateFormat('dd-MM-yyyy').format(DateTime.now()),
    );

    final amountController = TextEditingController(
      text: entry == null ? '' : entry.amount.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                entry == null
                    ? 'ઉપાડ ઉમેરો'
                    : 'ઉપાડ Edit કરો',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // વિભાગ
                    DropdownButtonFormField<String>(
                      value: selectedSection,
                      decoration: const InputDecoration(
                        labelText: 'વિભાગ',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: sections.map((section) {
                        return DropdownMenuItem<String>(
                          value: section,
                          child: Text(section),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedSection = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // તારીખ
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'તારીખ',
                        hintText: 'તારીખ પસંદ કરો',
                        prefixIcon:
                            Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        await selectDate(
                          context,
                          dateController,
                        );

                        setDialogState(() {});
                      },
                    ),

                    const SizedBox(height: 12),

                    // કારીગર
                    DropdownButtonFormField<String>(
                      value: selectedWorker,
                      decoration: const InputDecoration(
                        labelText: 'કારીગર',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: workers.map((worker) {
                        return DropdownMenuItem<String>(
                          value: worker,
                          child: Text(worker),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedWorker = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // ઉપાડની રકમ
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ઉપાડની રકમ',
                        hintText: '500',
                        prefixIcon:
                            Icon(Icons.currency_rupee),
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
                  onPressed: () {
                    final amount =
                        double.tryParse(
                              amountController.text.trim(),
                            ) ??
                            0;

                    if (dateController.text
                            .trim()
                            .isEmpty ||
                        selectedWorker ==
                            'કારીગર પસંદ કરો' ||
                        amount <= 0) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'બધી માહિતી યોગ્ય રીતે ભરો',
                          ),
                        ),
                      );
                      return;
                    }

                    final newEntry = WithdrawalEntry(
                      section: selectedSection,
                      date: dateController.text.trim(),
                      worker: selectedWorker,
                      amount: amount,
                    );

                    setState(() {
                      if (entry == null) {
                        withdrawalEntries.add(newEntry);
                      } else {
                        withdrawalEntries[index!] =
                            newEntry;
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteWithdrawal(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ઉપાડ Delete કરો?'),
          content: const Text(
            'શું તમે આ ઉપાડની Entry Delete કરવા માંગો છો?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  withdrawalEntries.removeAt(index);
                });

                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  double get totalWithdrawal {
    return withdrawalEntries.fold(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 ઉપાડ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Total
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.payments,
                    size: 35,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      const Text('ટોટલ ઉપાડ'),
                      const SizedBox(height: 5),
                      Text(
                        '₹ ${totalWithdrawal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: withdrawalEntries.isEmpty
                ? const Center(
                    child: Text(
                      'હજુ કોઈ ઉપાડની Entry નથી',
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: withdrawalEntries.length,
                    itemBuilder: (context, index) {
                      final entry =
                          withdrawalEntries[index];

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.payments),
                          ),
                          title: Text(
                            entry.worker,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${entry.date} | ${entry.section}\n'
                            'ઉપાડ: ₹${entry.amount.toStringAsFixed(2)}',
                          ),
                          isThreeLine: true,
                          trailing:
                              PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                showWithdrawalForm(
                                  entry: entry,
                                  index: index,
                                );
                              }

                              if (value == 'delete') {
                                deleteWithdrawal(index);
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
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showWithdrawalForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('ઉપાડ ઉમેરો'),
      ),
    );
  }
}
