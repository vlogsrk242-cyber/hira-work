import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          (withdrawal) => withdrawal.worker == selectedWorker,
        )
        .toList();
  }

  double get totalDiamonds {
    return workerWorks.fold(
      0.0,
      (sum, work) => sum + work.diamonds,
    );
  }

  double get totalWork {
    return workerWorks.fold(
      0.0,
      (sum, work) => sum + work.totalWork,
    );
  }

  double get totalWithdrawal {
    return workerWithdrawals.fold(
      0.0,
      (sum, withdrawal) => sum + withdrawal.amount,
    );
  }

  double get balance {
    return totalWork - totalWithdrawal;
  }

  String money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  bool get hasData {
    return workerWorks.isNotEmpty ||
        workerWithdrawals.isNotEmpty;
  }

  Future<pw.Document> createPdf() async {
    final fontData = await rootBundle.load(
      'assets/NotoSansGujarati-Regular.ttf',
    );

    final gujaratiFont = pw.Font.ttf(fontData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: gujaratiFont,
        bold: gujaratiFont,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(
              'હીરા કામ હિસ્ટરી',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'કારીગર: ${selectedWorker ?? ''}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            if (workerWorks.isNotEmpty) ...[
              pw.Text(
                'કામની વિગતો',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Table.fromTextArray(
                headers: const [
                  'તારીખ',
                  'વિભાગ',
                  'હીરા',
                  'ભાવ',
                  'કામ',
                ],
                data: workerWorks.map((work) {
                  return [
                    work.date,
                    work.section,
                    work.diamonds.toStringAsFixed(0),
                    money(work.rate),
                    money(work.totalWork),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: const pw.TextStyle(
                  fontSize: 9,
                ),
                cellPadding:
                    const pw.EdgeInsets.all(5),
              ),

              pw.SizedBox(height: 20),
            ],

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  width: 1,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'સારાંશ',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    'કુલ હીરા: '
                    '${totalDiamonds.toStringAsFixed(0)}',
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    'કુલ કામ: ${money(totalWork)}',
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    'કુલ ઉપાડ: '
                    '${money(totalWithdrawal)}',
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    'બાકી રકમ: ${money(balance)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ];

          if (workerWithdrawals.isNotEmpty) {
            widgets.add(
              pw.SizedBox(height: 25),
            );

            widgets.add(
              pw.Text(
                'ઉપાડની વિગતો',
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
                headers: const [
                  'તારીખ',
                  'વિભાગ',
                  'ઉપાડ',
                ],
                data: workerWithdrawals.map(
                  (withdrawal) {
                    return [
                      withdrawal.date,
                      withdrawal.section,
                      money(withdrawal.amount),
                    ];
                  },
                ).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: const pw.TextStyle(
                  fontSize: 9,
                ),
                cellPadding:
                    const pw.EdgeInsets.all(5),
              ),
            );
          }

          widgets.add(
            pw.SizedBox(height: 25),
          );

          widgets.add(
            pw.Text(
              'હીરા કામ હિસ્ટરી',
              style: const pw.TextStyle(
                fontSize: 9,
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    return pdf;
  }

  Future<bool> validateReport() async {
    if (selectedWorker == null ||
        selectedWorker!.trim().isEmpty) {
      _showMessage(
        'પહેલા કારીગર પસંદ કરો',
      );
      return false;
    }

    if (!hasData) {
      _showMessage(
        'આ કારીગર માટે કોઈ સાચો ડેટા નથી',
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

    final safeWorkerName = selectedWorker!
        .replaceAll(' ', '_')
        .replaceAll('/', '_');

    await Printing.sharePdf(
      bytes: bytes,
      filename:
          '${safeWorkerName}_hira_work_report.pdf',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📄 PDF Report',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: workerNames.contains(
                  selectedWorker,
                )
                    ? selectedWorker
                    : null,
                decoration: const InputDecoration(
                  labelText: 'કારીગર પસંદ કરો',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: workerNames.map(
                  (name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWorker = value;
                  });
                },
              ),

              if (workerNames.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'પહેલા કારીગર ઉમેરો.',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (selectedWorker != null) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 45,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          selectedWorker!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _summaryRow(
                          'કુલ હીરા',
                          totalDiamonds.toStringAsFixed(0),
                        ),

                        _summaryRow(
                          'કુલ કામ',
                          money(totalWork),
                        ),

                        _summaryRow(
                          'કુલ ઉપાડ',
                          money(totalWithdrawal),
                        ),

                        const Divider(),

                        _summaryRow(
                          'બાકી રકમ',
                          money(balance),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (workerWorks.isNotEmpty)
                  _buildWorkDetails(),

                if (workerWorks.isNotEmpty)
                  const SizedBox(height: 12),

                if (workerWithdrawals.isNotEmpty)
                  _buildWithdrawalDetails(),

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
      ),
    );
  }

  Widget _buildWorkDetails() {
    return Card(
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
              (work) {
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.diamond,
                  ),
                  title: Text(
                    '${work.date} | ${work.section}',
                  ),
                  subtitle: Text(
                    '${work.diamonds.toStringAsFixed(0)} '
                    'હીરા × '
                    '₹${work.rate.toStringAsFixed(2)} = '
                    '₹${work.totalWork.toStringAsFixed(2)}',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalDetails() {
    return Card(
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
              (withdrawal) {
                return ListTile(
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
                );
              },
            ),
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
