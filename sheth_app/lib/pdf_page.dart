import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final String userUid;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _workersStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _worksStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _withdrawalsStream;

  String? selectedWorker;

  late final Future<pw.Font> _gujaratiFontFuture;

  @override
  void initState() {
    super.initState();

    userUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userUid.isNotEmpty) {
      _workersStream = firestore
          .collection('karigars')
          .where('ownerUid', isEqualTo: userUid)
          .snapshots();

      _worksStream = firestore
          .collection('works')
          .where('ownerUid', isEqualTo: userUid)
          .snapshots();

      _withdrawalsStream = firestore
          .collection('withdrawals')
          .where('ownerUid', isEqualTo: userUid)
          .snapshots();
    }

    _gujaratiFontFuture = _loadGujaratiFont();
  }

  Future<pw.Font> _loadGujaratiFont() async {
    final fontData = await rootBundle.load(
      'assets/NotoSansGujarati-Regular.ttf',
    );

    return pw.Font.ttf(fontData);
  }

  String money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _workerName(Map<String, dynamic> data) {
    return (data['name'] ?? '').toString();
  }

  List<Map<String, dynamic>> _workerWorks(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> works,
  ) {
    final worker = selectedWorker;

    if (worker == null || worker!.isEmpty) {
      return [];
    }

    return works
        .where(
          (doc) =>
              (doc.data()['worker'] ?? '').toString() == worker,
        )
        .map((doc) => doc.data())
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _workerWithdrawals(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> withdrawals,
  ) {
    final worker = selectedWorker;

    if (worker == null || worker!.isEmpty) {
      return [];
    }

    return withdrawals
        .where(
          (doc) =>
              (doc.data()['worker'] ?? '').toString() == worker,
        )
        .map((doc) => doc.data())
        .toList(growable: false);
  }

  double _totalDiamonds(
    List<Map<String, dynamic>> works,
  ) {
    double total = 0;

    for (final work in works) {
      total += _toDouble(work['diamonds']);
    }

    return total;
  }

  double _totalWork(
    List<Map<String, dynamic>> works,
  ) {
    double total = 0;

    for (final work in works) {
      final diamonds = _toDouble(work['diamonds']);
      final rate = _toDouble(work['rate']);

      total += diamonds * rate;
    }

    return total;
  }

  double _totalWithdrawal(
    List<Map<String, dynamic>> withdrawals,
  ) {
    double total = 0;

    for (final withdrawal in withdrawals) {
      total += _toDouble(withdrawal['amount']);
    }

    return total;
  }

  Future<pw.Document> createPdf(
    List<Map<String, dynamic>> works,
    List<Map<String, dynamic>> withdrawals,
  ) async {
    final gujaratiFont = await _gujaratiFontFuture;

    double diamondsTotal = 0;
    double workTotal = 0;
    double withdrawalTotal = 0;

    for (final work in works) {
      final diamonds = _toDouble(work['diamonds']);
      final rate = _toDouble(work['rate']);

      diamondsTotal += diamonds;
      workTotal += diamonds * rate;
    }

    for (final withdrawal in withdrawals) {
      withdrawalTotal += _toDouble(withdrawal['amount']);
    }

    final balanceTotal =
        workTotal - withdrawalTotal;

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

            if (works.isNotEmpty) ...[
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
                data: works.map((work) {
                  final diamonds =
                      _toDouble(work['diamonds']);
                  final rate =
                      _toDouble(work['rate']);

                  return [
                    (work['date'] ?? '').toString(),
                    (work['section'] ?? '').toString(),
                    diamonds.toStringAsFixed(0),
                    money(rate),
                    money(diamonds * rate),
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
              padding:
                  const pw.EdgeInsets.all(12),
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
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    'કુલ હીરા: '
                    '${diamondsTotal.toStringAsFixed(0)}',
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    'કુલ કામ: '
                    '${money(workTotal)}',
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    'કુલ ઉપાડ: '
                    '${money(withdrawalTotal)}',
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    'બાકી રકમ: '
                    '${money(balanceTotal)}',
                    style: pw.TextStyle(
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ];

          if (withdrawals.isNotEmpty) {
            widgets.add(
              pw.SizedBox(height: 25),
            );

            widgets.add(
              pw.Text(
                'ઉપાડની વિગતો',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight:
                      pw.FontWeight.bold,
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
                data: withdrawals.map(
                  (withdrawal) {
                    return [
                      (withdrawal['date'] ?? '')
                          .toString(),
                      (withdrawal['section'] ?? '')
                          .toString(),
                      money(
                        _toDouble(
                          withdrawal['amount'],
                        ),
                      ),
                    ];
                  },
                ).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight:
                      pw.FontWeight.bold,
                ),
                cellStyle:
                    const pw.TextStyle(
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

  bool validateReport({
    required List<Map<String, dynamic>> works,
    required List<Map<String, dynamic>> withdrawals,
  }) {
    if (selectedWorker == null ||
        selectedWorker!.trim().isEmpty) {
      _showMessage(
        'પહેલા કારીગર પસંદ કરો',
      );
      return false;
    }

    if (works.isEmpty && withdrawals.isEmpty) {
      _showMessage(
        'આ કારીગર માટે કોઈ સાચો ડેટા નથી',
      );
      return false;
    }

    return true;
  }

  Future<void> previewPdf({
    required List<Map<String, dynamic>> works,
    required List<Map<String, dynamic>> withdrawals,
  }) async {
    if (!validateReport(
      works: works,
      withdrawals: withdrawals,
    )) {
      return;
    }

    try {
      final pdf = await createPdf(
        works,
        withdrawals,
      );

      if (!mounted) return;

      await Printing.layoutPdf(
        onLayout: (format) async {
          return pdf.save();
        },
      );
    } catch (e) {
      _showMessage(
        'PDF બનાવવામાં ભૂલ થઈ',
      );
    }
  }

  Future<void> sharePdf({
    required List<Map<String, dynamic>> works,
    required List<Map<String, dynamic>> withdrawals,
  }) async {
    if (!validateReport(
      works: works,
      withdrawals: withdrawals,
    )) {
      return;
    }

    try {
      final pdf = await createPdf(
        works,
        withdrawals,
      );

      final bytes = await pdf.save();

      final safeWorkerName =
          selectedWorker!
              .replaceAll(' ', '_')
              .replaceAll('/', '_');

      await Printing.sharePdf(
        bytes: bytes,
        filename:
            '${safeWorkerName}_hira_work_report.pdf',
      );
    } catch (e) {
      _showMessage(
        'PDF Share કરવામાં ભૂલ થઈ',
      );
    }
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
      return const Scaffold(
        body: Center(
          child: Text(
            'Login જરૂરી છે',
          ),
        ),
      );
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _workersStream,
      builder: (context, workerSnapshot) {
        if (workerSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'કારીગરની માહિતી લાવવામાં ભૂલ થઈ',
              ),
            ),
          );
        }

        if (workerSnapshot.connectionState ==
                ConnectionState.waiting &&
            !workerSnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final workerDocs =
            workerSnapshot.data?.docs ?? [];

        final workerNames = workerDocs
            .map(_workerName)
            .where((name) => name.isNotEmpty)
            .toList(growable: false);

        if (selectedWorker != null &&
            !workerNames.contains(selectedWorker)) {
          selectedWorker = null;
        }

        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: _worksStream,
          builder: (context, worksSnapshot) {
            if (worksSnapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'કામની માહિતી લાવવામાં ભૂલ થઈ',
                  ),
                ),
              );
            }

            if (worksSnapshot.connectionState ==
                    ConnectionState.waiting &&
                !worksSnapshot.hasData) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _withdrawalsStream,
              builder: (
                context,
                withdrawalsSnapshot,
              ) {
                if (withdrawalsSnapshot.hasError) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        'ઉપાડની માહિતી લાવવામાં ભૂલ થઈ',
                      ),
                    ),
                  );
                }

                if (withdrawalsSnapshot
                            .connectionState ==
                        ConnectionState.waiting &&
                    !withdrawalsSnapshot.hasData) {
                  return const Scaffold(
                    body: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                final workDocs =
                    worksSnapshot.data?.docs ?? [];

                final withdrawalDocs =
                    withdrawalsSnapshot.data?.docs ??
                        [];

                final works =
                    _workerWorks(workDocs);

                final withdrawals =
                    _workerWithdrawals(
                  withdrawalDocs,
                );

                final totalDiamonds =
                    _totalDiamonds(works);

                final totalWork =
                    _totalWork(works);

                final totalWithdrawal =
                    _totalWithdrawal(withdrawals);

                final balance =
                    totalWork - totalWithdrawal;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text(
                      '📄 PDF Report',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<
                              String>(
                            value: workerNames.contains(
                              selectedWorker,
                            )
                                ? selectedWorker
                                : null,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'કારીગર પસંદ કરો',
                              prefixIcon:
                                  Icon(Icons.person),
                              border:
                                  OutlineInputBorder(),
                            ),
                            items: workerNames.map(
                              (name) {
                                return DropdownMenuItem<
                                    String>(
                                  value: name,
                                  child: Text(name),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedWorker =
                                    value;
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

                          if (selectedWorker !=
                              null) ...[
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .all(16),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 45,
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      selectedWorker!,
                                      style:
                                          const TextStyle(
                                        fontSize: 22,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 18,
                                    ),

                                    _summaryRow(
                                      'કુલ હીરા',
                                      totalDiamonds
                                          .toStringAsFixed(
                                        0,
                                      ),
                                    ),

                                    _summaryRow(
                                      'કુલ કામ',
                                      money(
                                        totalWork,
                                      ),
                                    ),

                                    _summaryRow(
                                      'કુલ ઉપાડ',
                                      money(
                                        totalWithdrawal,
                                      ),
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

                            if (works.isNotEmpty)
                              _buildWorkDetails(
                                works,
                              ),

                            if (works.isNotEmpty)
                              const SizedBox(
                                height: 12,
                              ),

                            if (withdrawals.isNotEmpty)
                              _buildWithdrawalDetails(
                                withdrawals,
                              ),

                            const SizedBox(
                              height: 20,
                            ),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child:
                                  ElevatedButton
                                      .icon(
                                onPressed: () =>
                                    previewPdf(
                                  works: works,
                                  withdrawals:
                                      withdrawals,
                                ),
                                icon: const Icon(
                                  Icons
                                      .picture_as_pdf,
                                ),
                                label: const Text(
                                  'PDF બનાવો / Print',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child:
                                  OutlinedButton
                                      .icon(
                                onPressed: () =>
                                    sharePdf(
                                  works: works,
                                  withdrawals:
                                      withdrawals,
                                ),
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
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWorkDetails(
    List<Map<String, dynamic>> works,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'કામની વિગતો',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...works.map(
              (work) {
                final diamonds =
                    _toDouble(work['diamonds']);
                final rate =
                    _toDouble(work['rate']);

                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.diamond,
                  ),
                  title: Text(
                    '${work['date'] ?? ''} | '
                    '${work['section'] ?? ''}',
                  ),
                  subtitle: Text(
                    '${diamonds.toStringAsFixed(0)} '
                    'હીરા × '
                    '₹${rate.toStringAsFixed(2)} = '
                    '₹${(diamonds * rate).toStringAsFixed(2)}',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalDetails(
    List<Map<String, dynamic>> withdrawals,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'ઉપાડની વિગતો',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...withdrawals.map(
              (withdrawal) {
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.payments,
                  ),
                  title: Text(
                    '${withdrawal['date'] ?? ''} | '
                    '${withdrawal['section'] ?? ''}',
                  ),
                  subtitle: Text(
                    'ઉપાડ: '
                    '₹${_toDouble(withdrawal['amount']).toStringAsFixed(2)}',
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
      padding:
          const EdgeInsets.symmetric(
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
