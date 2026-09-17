import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'app_data.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  String? selectedWorker;

  List<WorkData> get workerWorks {
    if (selectedWorker == null) {
      return [];
    }

    return AppData.works
        .where((work) => work.worker == selectedWorker)
        .toList();
  }

  List<WithdrawalData> get workerWithdrawals {
    if (selectedWorker == null) {
      return [];
    }

    return AppData.withdrawals
        .where(
          (withdrawal) =>
              withdrawal.worker == selectedWorker,
        )
        .toList();
  }

  double get totalDiamonds {
    return workerWorks.fold(
      0,
      (sum, item) => sum + item.diamonds,
    );
  }

  double get totalWork {
    return workerWorks.fold(
      0,
      (sum, item) => sum + item.totalWork,
    );
  }

  double get totalWithdrawal {
    return workerWithdrawals.fold(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  double get balance {
    return totalWork - totalWithdrawal;
  }

  Future<pw.Document> createPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(
              'HIRA WORK HISTORY',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Worker: ${selectedWorker ?? ''}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Section',
                'Diamonds',
                'Rate',
                'Work',
              ],
              data: workerWorks.map((work) {
                return [
                  work.date,
                  work.section,
                  work.diamonds.toStringAsFixed(0),
                  'Rs. ${work.rate.toStringAsFixed(2)}',
                  'Rs. ${work.totalWork.toStringAsFixed(2)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Diamonds: '
              '${totalDiamonds.toStringAsFixed(0)}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Total Work: '
              'Rs. ${totalWork.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Total Withdrawal: '
              'Rs. ${totalWithdrawal.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Balance: '
              'Rs. ${balance.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ];

          if (workerWithdrawals.isNotEmpty) {
            widgets.add(
              pw.SizedBox(height: 25),
            );

            widgets.add(
              pw.Text(
                'Withdrawal Details',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );

            widgets.add(
              pw.SizedBox(height: 8),
            );

            widgets.add(
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Section',
                  'Withdrawal',
                ],
                data: workerWithdrawals.map((withdrawal) {
                  return [
                    withdrawal.date,
                    withdrawal.section,
                    'Rs. '
                        '${withdrawal.amount.toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf;
  }

  Future<bool> validateReport() async {
    if (selectedWorker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'પહેલા કારીગર પસંદ કરો',
          ),
        ),
      );
      return false;
    }

    if (workerWorks.isEmpty &&
        workerWithdrawals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'આ કારીગર માટે કોઈ સાચો ડેટા નથી',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> previewPdf() async {
    final valid = await validateReport();

    if (!valid) {
      return;
    }

    final pdf = await createPdf();

    await Printing.layoutPdf(
      onLayout: (format) async {
        return pdf.save();
      },
    );
  }

  Future<void> sharePdf() async {
    final valid = await validateReport();

    if (!valid) {
      return;
    }

    final pdf = await createPdf();
    final bytes = await pdf.save();

    final safeName =
        selectedWorker!
            .replaceAll(' ', '_')
            .replaceAll('/', '_');

    await Printing.sharePdf(
      bytes: bytes,
      filename: '${safeName}_hira_work_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 PDF Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (AppData.workers.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'પહેલા કારીગર ઉમેરો.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: selectedWorker,
                decoration: const InputDecoration(
                  labelText: 'કારીગર પસંદ કરો',
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
                  setState(() {
                    selectedWorker = value;
                  });
                },
              ),
            const SizedBox(height: 20),
            if (selectedWorker != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        selectedWorker!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _summaryRow(
                        'કુલ હીરા',
                        totalDiamonds.toStringAsFixed(0),
                      ),
                      _summaryRow(
                        'કુલ કામ',
                        '₹ ${totalWork.toStringAsFixed(2)}',
                      ),
                      _summaryRow(
                        'કુલ ઉપાડ',
                        '₹ ${totalWithdrawal.toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      _summaryRow(
                        'બાકી રકમ',
                        '₹ ${balance.toStringAsFixed(2)}',
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (workerWorks.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'કામની વિગતો',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...workerWorks.map(
                          (work) => ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.diamond,
                            ),
                            title: Text(
                              '${work.date} | ${work.section}',
                            ),
                            subtitle: Text(
                              '${work.diamonds.toStringAsFixed(0)} હીરા × '
                              '₹${work.rate.toStringAsFixed(2)} = '
                              '₹${work.totalWork.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (workerWithdrawals.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ઉપાડની વિગતો',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...workerWithdrawals.map(
                          (withdrawal) => ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.payments,
                            ),
                            title: Text(
                              '${withdrawal.date} | '
                              '${withdrawal.section}',
                            ),
                            subtitle: Text(
                              'ઉપાડ: '
                              '₹${withdrawal.amount.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: previewPdf,
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label: const Text(
                    'PDF બનાવો / Print',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: sharePdf,
                  icon: const Icon(
                    Icons.share,
                  ),
                  label: const Text(
                    'PDF Share કરો',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
