```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkEntry {
  String section;
  String date;
  String worker;
  double diamonds;
  double rate;

  WorkEntry({
    required this.section,
    required this.date,
    required this.worker,
    required this.diamonds,
    required this.rate,
  });

  double get totalWork => diamonds * rate;
}

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  final List<WorkEntry> workEntries = [];

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

  void showWorkForm({
    WorkEntry? entry,
    int? index,
  }) {
    String selectedSection =
        entry?.section ?? sections.first;

    final dateController = TextEditingController(
      text: entry?.date ??
          DateFormat('dd-MM-yyyy').format(DateTime.now()),
    );

    final workerController = TextEditingController(
      text: entry?.worker ?? '',
    );

    final diamondsController = TextEditingController(
      text: entry == null ? '' : entry.diamonds.toString(),
    );

    final rateController = TextEditingController(
      text: entry == null ? '' : entry.rate.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final diamonds =
                double.tryParse(diamondsController.text) ?? 0;

            final rate =
                double.tryParse(rateController.text) ?? 0;

            final total = diamonds * rate;

            return AlertDialog(
              title: Text(
                entry == null
                    ? 'કામ ઉમેરો'
                    : 'કામ Edit કરો',
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
                        return DropdownMenuItem(
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
                        hintText: 'તારીખ પસંદ કરો',
                        prefixIcon:
                            Icon(Icons.calendar_month),
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

                    TextField(
                      controller: workerController,
                      decoration: const InputDecoration(
                        labelText: 'કારીગર',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: diamondsController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'હીરા',
                        prefixIcon: Icon(Icons.diamond),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: rateController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ભાવ',
                        prefixIcon:
                            Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                      ),
                      child: Text(
                        'ટોટલ કામ = ₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                    final diamonds =
                        double.tryParse(
                              diamondsController.text
                                  .trim(),
                            ) ??
                            0;

                    final rate =
                        double.tryParse(
                              rateController.text.trim(),
                            ) ??
                            0;

                    if (workerController.text
                            .trim()
                            .isEmpty ||
                        diamonds <= 0 ||
                        rate <= 0) {
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

                    final newEntry = WorkEntry(
                      section: selectedSection,
                      date: dateController.text.trim(),
                      worker: workerController.text.trim(),
                      diamonds: diamonds,
                      rate: rate,
                    );

                    setState(() {
                      if (entry == null) {
                        workEntries.add(newEntry);
                      } else {
                        workEntries[index!] = newEntry;
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

  void deleteWork(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('કામ Delete કરો?'),
          content: const Text(
            'શું તમે આ કામની Entry Delete કરવા માંગો છો?',
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
                  workEntries.removeAt(index);
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

  double get totalDiamonds {
    return workEntries.fold(
      0,
      (sum, item) => sum + item.diamonds,
    );
  }

  double get totalWork {
    return workEntries.fold(
      0,
      (sum, item) => sum + item.totalWork,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💼 કામ'),
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
                    MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('ટોટલ હીરા'),
                      const SizedBox(height: 5),
                      Text(
                        totalDiamonds.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('ટોટલ કામ'),
                      const SizedBox(height: 5),
                      Text(
                        '₹ ${totalWork.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
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
            child: workEntries.isEmpty
                ? const Center(
                    child: Text(
                      'હજુ કોઈ કામની Entry નથી',
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: workEntries.length,
                    itemBuilder: (context, index) {
                      final entry = workEntries[index];

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.diamond),
                          ),
                          title: Text(
                            entry.worker,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${entry.date} | ${entry.section}\n'
                            '${entry.diamonds} હીરા × '
                            '₹${entry.rate} = '
                            '₹${entry.totalWork.toStringAsFixed(2)}',
                          ),
                          isThreeLine: true,
                          trailing:
                              PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                showWorkForm(
                                  entry: entry,
                                  index: index,
                                );
                              }

                              if (value == 'delete') {
                                deleteWork(index);
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
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showWorkForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('કામ ઉમેરો'),
      ),
    );
  }
}
```
