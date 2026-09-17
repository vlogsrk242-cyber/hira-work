import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_data.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  final List<String> sections = [
    'તળીયા',
    'પેલ',
    'મથાળા',
  ];

  void showWorkForm({
    WorkData? work,
    int? index,
  }) {
    String selectedSection = work?.section ?? sections.first;
    String selectedWorker =
        work?.worker ??
        (AppData.workers.isNotEmpty
            ? AppData.workers.first.name
            : '');

    DateTime selectedDate =
        work != null
            ? DateFormat('dd-MM-yyyy').parse(work.date)
            : DateTime.now();

    final diamondsController = TextEditingController(
      text: work != null ? work.diamonds.toString() : '',
    );

    final rateController = TextEditingController(
      text: work != null ? work.rate.toString() : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                work == null ? 'કામ ઉમેરો' : 'કામ Edit કરો',
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
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
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
                        decoration: const InputDecoration(
                          labelText: 'તારીખ',
                          prefixIcon: Icon(Icons.calendar_month),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat(
                            'dd-MM-yyyy',
                          ).format(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (AppData.workers.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
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
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rateController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Rate',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (_) {
                        final diamonds =
                            double.tryParse(
                              diamondsController.text,
                            ) ??
                            0;

                        final rate =
                            double.tryParse(
                              rateController.text,
                            ) ??
                            0;

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'કુલ કામ: ₹ ${(diamonds * rate).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
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
                    final diamonds = double.tryParse(
                      diamondsController.text.trim(),
                    );

                    final rate = double.tryParse(
                      rateController.text.trim(),
                    );

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

                    if (diamonds == null || diamonds <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'હીરાની સંખ્યા સાચી નાખો',
                          ),
                        ),
                      );
                      return;
                    }

                    if (rate == null || rate < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Rate સાચો નાખો',
                          ),
                        ),
                      );
                      return;
                    }

                    final newWork = WorkData(
                      section: selectedSection,
                      date: DateFormat(
                        'dd-MM-yyyy',
                      ).format(selectedDate),
                      worker: selectedWorker,
                      diamonds: diamonds,
                      rate: rate,
                    );

                    setState(() {
                      if (work == null) {
                        AppData.works.add(newWork);
                      } else {
                        AppData.works[index!] = newWork;
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
    final work = AppData.works[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('કામ Delete કરો?'),
          content: Text(
            'શું તમે ${work.worker} નું કામ Delete કરવા માંગો છો?',
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
                  AppData.works.removeAt(index);
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

  double get totalDiamonds {
    return AppData.works.fold(
      0,
      (sum, item) => sum + item.diamonds,
    );
  }

  double get totalWork {
    return AppData.works.fold(
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
      body: AppData.works.isEmpty
          ? const Center(
              child: Text(
                'હજુ કોઈ કામ ઉમેરાયું નથી',
                style: TextStyle(fontSize: 17),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: AppData.works.length,
              itemBuilder: (context, index) {
                final work = AppData.works[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.diamond),
                    ),
                    title: Text(
                      work.worker,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'વિભાગ: ${work.section}\n'
                      'તારીખ: ${work.date}\n'
                      'હીરા: ${work.diamonds.toStringAsFixed(0)}\n'
                      'Rate: ₹ ${work.rate.toStringAsFixed(2)}\n'
                      'કુલ: ₹ ${work.totalWork.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showWorkForm(
                            work: work,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showWorkForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('કામ ઉમેરો'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ટોટલ હીરા: ${totalDiamonds.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ટોટલ કામ: ₹ ${totalWork.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
