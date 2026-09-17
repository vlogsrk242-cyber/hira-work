import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_data.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final List<String> sections = [
    'તળીયા',
    'પેલ',
    'મથાળા',
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

    final picked = await showDatePicker(
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
    WithdrawalData? entry,
    int? index,
  }) {
    if (AppData.workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'પહેલા કારીગર ઉમેરો',
          ),
        ),
      );
      return;
    }

    String selectedSection =
        entry?.section ?? sections.first;

    String selectedWorker =
        entry?.worker ?? AppData.workers.first.name;

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

                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'તારીખ',
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

                    DropdownButtonFormField<String>(
                      value: selectedWorker,
                      decoration: const InputDecoration(
                        labelText: 'કારીગર',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: AppData.workers.map((worker) {
                        return DropdownMenuItem<String>(
                          value: worker.name,
                          child: Text(worker.name),
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

                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ઉપાડની રકમ',
                        hintText: '₹ 500',
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

                    if (dateController.text.trim().isEmpty ||
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

                    final newEntry = WithdrawalData(
                      section: selectedSection,
                      date: dateController.text.trim(),
                      worker: selectedWorker,
                      amount: amount,
                    );

                    setState(() {
                      if (entry == null) {
                        AppData.withdrawals.add(newEntry);
                      } else {
                        AppData.withdrawals[index!] =
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
    final entry = AppData.withdrawals[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'ઉપાડ Delete કરો?',
          ),
          content: Text(
            'શું તમે ${entry.worker} નો ₹${entry.amount.toStringAsFixed(2)} નો ઉપાડ Delete કરવા માંગો છો?',
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
                setState(() {
                  AppData.withdrawals.removeAt(index);
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  double get totalWithdrawal {
    return AppData.withdrawals.fold(
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
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.payments,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      const Text(
                        'ટોટલ ઉપાડ',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '₹ ${totalWithdrawal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 21,
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
            child: AppData.withdrawals.isEmpty
                ? const Center(
                    child: Text(
                      'હજુ કોઈ ઉપાડની Entry નથી',
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount:
                        AppData.withdrawals.length,
                    itemBuilder: (context, index) {
                      final entry =
                          AppData.withdrawals[index];

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
        onPressed: showWithdrawalForm,
        icon: const Icon(Icons.add),
        label: const Text('ઉપાડ ઉમેરો'),
      ),
    );
  }
}
