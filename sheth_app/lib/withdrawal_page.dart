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

  void showWithdrawalForm({
    WithdrawalData? withdrawal,
    int? index,
  }) {
    String selectedSection =
        withdrawal?.section ?? sections.first;

    String selectedWorker =
        withdrawal?.worker ??
        (AppData.workers.isNotEmpty
            ? AppData.workers.first.name
            : '');

    DateTime selectedDate =
        withdrawal != null
            ? DateFormat('dd-MM-yyyy')
                .parse(withdrawal.date)
            : DateTime.now();

    final amountController = TextEditingController(
      text: withdrawal != null
          ? withdrawal.amount.toString()
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                withdrawal == null
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
                        prefixIcon:
                            Icon(Icons.category),
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

                    InkWell(
                      onTap: () async {
                        final picked =
                            await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText: 'તારીખ',
                          prefixIcon: Icon(
                            Icons.calendar_month,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd-MM-yyyy')
                              .format(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (AppData.workers.isEmpty)
                      const Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Text(
                          'પહેલા કારીગર ઉમેરો',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: selectedWorker,
                        decoration:
                            const InputDecoration(
                          labelText: 'કારીગર',
                          prefixIcon:
                              Icon(Icons.person),
                          border:
                              OutlineInputBorder(),
                        ),
                        items: AppData.workers.map(
                          (worker) {
                            return DropdownMenuItem<
                                String>(
                              value: worker.name,
                              child:
                                  Text(worker.name),
                            );
                          },
                        ).toList(),
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
                      decoration:
                          const InputDecoration(
                        labelText: 'ઉપાડની રકમ',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
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
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(
                      amountController.text.trim(),
                    );

                    if (AppData.workers.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'પહેલા કારીગર ઉમેરો',
                          ),
                        ),
                      );
                      return;
                    }

                    if (amount == null ||
                        amount <= 0) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'ઉપાડની રકમ સાચી નાખો',
                          ),
                        ),
                      );
                      return;
                    }

                    final newWithdrawal =
                        WithdrawalData(
                      section: selectedSection,
                      date: DateFormat(
                        'dd-MM-yyyy',
                      ).format(selectedDate),
                      worker: selectedWorker,
                      amount: amount,
                    );

                    setState(() {
                      if (withdrawal == null) {
                        AppData.withdrawals
                            .add(newWithdrawal);
                      } else {
                        AppData.withdrawals[index!] =
                            newWithdrawal;
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
    final withdrawal =
        AppData.withdrawals[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'ઉપાડ Delete કરો?',
          ),
          content: Text(
            'શું તમે ${withdrawal.worker} નો '
            '₹ ${withdrawal.amount.toStringAsFixed(2)} '
            'ઉપાડ Delete કરવા માંગો છો?',
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
                  AppData.withdrawals
                      .removeAt(index);
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
      body: AppData.withdrawals.isEmpty
          ? const Center(
              child: Text(
                'હજુ કોઈ ઉપાડ ઉમેરાયો નથી',
                style: TextStyle(fontSize: 17),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(12),
              itemCount:
                  AppData.withdrawals.length,
              itemBuilder:
                  (context, index) {
                final withdrawal =
                    AppData.withdrawals[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
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
                      withdrawal.worker,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'વિભાગ: '
                      '${withdrawal.section}\n'
                      'તારીખ: '
                      '${withdrawal.date}\n'
                      'ઉપાડ: ₹ '
                      '${withdrawal.amount.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing:
                        PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showWithdrawalForm(
                            withdrawal:
                                withdrawal,
                            index: index,
                          );
                        }

                        if (value == 'delete') {
                          deleteWithdrawal(index);
                        }
                      },
                      itemBuilder:
                          (context) =>
                              const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
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
            ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showWithdrawalForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('ઉપાડ ઉમેરો'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(12),
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Text(
                'ટોટલ ઉપાડ: ₹ '
                '${totalWithdrawal.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
