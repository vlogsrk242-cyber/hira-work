import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_data.dart';

class WorkPage extends StatefulWidget {
  final String? initialSection;

  const WorkPage({
    super.key,
    this.initialSection,
  });

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  final TextEditingController diamondsController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  final List<String> sections = [
    'તળીયા',
    'પેલ',
    'મથાળા',
  ];

  String selectedSection = 'તળીયા';
  String selectedDate = '';
  String? selectedWorker;
  int? editingIndex;

  @override
  void initState() {
    super.initState();

    selectedSection = widget.initialSection ?? 'તળીયા';

    selectedDate = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());
  }

  @override
  void dispose() {
    diamondsController.dispose();
    rateController.dispose();
    super.dispose();
  }

  double get enteredDiamonds {
    return double.tryParse(
          diamondsController.text.trim(),
        ) ??
        0;
  }

  double get enteredRate {
    return double.tryParse(
          rateController.text.trim(),
        ) ??
        0;
  }

  double get calculatedTotal {
    return enteredDiamonds * enteredRate;
  }

  Future<void> selectDate() async {
    DateTime initialDate = DateTime.now();

    try {
      initialDate = DateFormat(
        'dd-MM-yyyy',
      ).parse(selectedDate);
    } catch (_) {}

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat(
          'dd-MM-yyyy',
        ).format(pickedDate);
      });
    }
  }

  void saveWork() {
    if (selectedWorker == null || selectedWorker!.isEmpty) {
      _showMessage('કૃપા કરીને કારીગર પસંદ કરો');
      return;
    }

    final diamonds = double.tryParse(
      diamondsController.text.trim(),
    );

    final rate = double.tryParse(
      rateController.text.trim(),
    );

    if (diamonds == null || diamonds <= 0) {
      _showMessage('હીરાની સંખ્યા યોગ્ય રીતે નાખો');
      return;
    }

    if (rate == null || rate < 0) {
      _showMessage('Rate યોગ્ય રીતે નાખો');
      return;
    }

    final work = WorkData(
      section: selectedSection,
      date: selectedDate,
      worker: selectedWorker!,
      diamonds: diamonds,
      rate: rate,
    );

    setState(() {
      if (editingIndex == null) {
        AppData.works.add(work);
      } else {
        AppData.works[editingIndex!] = work;
      }

      clearForm();
    });

    _showMessage(
      editingIndex == null
          ? 'કામ સાચવવામાં આવ્યું'
          : 'કામ અપડેટ કરવામાં આવ્યું',
    );
  }

  void clearForm() {
    selectedSection = widget.initialSection ?? 'તળીયા';
    selectedDate = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());

    selectedWorker = null;

    diamondsController.clear();
    rateController.clear();

    editingIndex = null;
  }

  void editWork(int index) {
    final work = AppData.works[index];

    setState(() {
      editingIndex = index;
      selectedSection = work.section;
      selectedDate = work.date;
      selectedWorker = work.worker;

      diamondsController.text =
          work.diamonds.toString();

      rateController.text =
          work.rate.toString();
    });
  }

  void deleteWork(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('કામ Delete કરવું?'),
          content: const Text(
            'આ કામની નોંધ કાયમ માટે દૂર થશે.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('રદ કરો'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  AppData.works.removeAt(index);

                  if (editingIndex == index) {
                    clearForm();
                  }
                });

                Navigator.pop(dialogContext);

                _showMessage(
                  'કામ Delete કરવામાં આવ્યું',
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerNames = AppData.workers
        .map((worker) => worker.name)
        .toList();

    final visibleWorks = AppData.works;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'કામની નોંધ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedSection,
                              decoration:
                                  const InputDecoration(
                                labelText: 'વિભાગ',
                                prefixIcon:
                                    Icon(Icons.category),
                                border:
                                    OutlineInputBorder(),
                              ),
                              items: sections
                                  .map(
                                    (section) =>
                                        DropdownMenuItem(
                                      value: section,
                                      child:
                                          Text(section),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  selectedSection =
                                      value;
                                });
                              },
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              readOnly: true,
                              controller:
                                  TextEditingController(
                                text: selectedDate,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText: 'તારીખ',
                                prefixIcon:
                                    Icon(Icons.calendar_month),
                                border:
                                    OutlineInputBorder(),
                              ),
                              onTap: selectDate,
                            ),

                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              value: workerNames.contains(
                                selectedWorker,
                              )
                                  ? selectedWorker
                                  : null,
                              decoration:
                                  const InputDecoration(
                                labelText: 'કારીગર',
                                prefixIcon:
                                    Icon(Icons.person),
                                border:
                                    OutlineInputBorder(),
                              ),
                              items: workerNames
                                  .map(
                                    (name) =>
                                        DropdownMenuItem(
                                      value: name,
                                      child:
                                          Text(name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedWorker =
                                      value;
                                });
                              },
                            ),

                            if (workerNames.isEmpty) ...[
                              const SizedBox(height: 8),
                              const Align(
                                alignment:
                                    Alignment.centerLeft,
                                child: Text(
                                  'પહેલા કારીગર ઉમેરો.',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),

                            TextField(
                              controller:
                                  diamondsController,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) {
                                setState(() {});
                              },
                              decoration:
                                  const InputDecoration(
                                labelText: 'હીરા',
                                hintText:
                                    'હીરાની સંખ્યા',
                                prefixIcon:
                                    Icon(Icons.diamond),
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextField(
                              controller:
                                  rateController,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) {
                                setState(() {});
                              },
                              decoration:
                                  const InputDecoration(
                                labelText: 'Rate',
                                hintText:
                                    'એક હીરાનો Rate',
                                prefixIcon:
                                    Icon(
                                  Icons.currency_rupee,
                                ),
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(14),
                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'કુલ કામ',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '₹${calculatedTotal.toStringAsFixed(0)}',
                                    style:
                                        const TextStyle(
                                      fontSize: 24,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${enteredDiamonds.toStringAsFixed(0)} × ₹${enteredRate.toStringAsFixed(0)}',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: saveWork,
                                icon: Icon(
                                  editingIndex == null
                                      ? Icons.save
                                      : Icons.edit,
                                ),
                                label: Text(
                                  editingIndex == null
                                      ? 'કામ Save કરો'
                                      : 'કામ Update કરો',
                                ),
                              ),
                            ),

                            if (editingIndex != null) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      clearForm();
                                    });
                                  },
                                  child: const Text(
                                    'Cancel Edit',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'સાચવેલ કામ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (visibleWorks.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'હજુ કોઈ કામની નોંધ નથી.',
                            ),
                          ),
                        ),
                      ),

                    ...visibleWorks
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildWorkCard(
                            entry.key,
                            entry.value,
                          ),
                        ),

                    const SizedBox(height: 20),

                    _buildTotalCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkCard(
    int index,
    WorkData work,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.diamond),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    work.section,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      editWork(index);
                    }

                    if (value == 'delete') {
                      deleteWork(index);
                    }
                  },
                  itemBuilder: (_) => const [
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
              ],
            ),

            const Divider(),

            Text('તારીખ: ${work.date}'),
            Text('કારીગર: ${work.worker}'),
            Text(
              'હીરા: ${work.diamonds.toStringAsFixed(0)}',
            ),
            Text(
              'Rate: ₹${work.rate.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 8),

            Text(
              'કુલ: ₹${work.totalWork.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    final totalDiamonds = AppData.works.fold(
      0.0,
      (sum, work) => sum + work.diamonds,
    );

    final totalAmount = AppData.works.fold(
      0.0,
      (sum, work) => sum + work.totalWork,
    );

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'કુલ કામનો હિસાબ',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('કુલ હીરા'),
                Text(
                  totalDiamonds.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('કુલ કામ'),
                Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
