import 'package:flutter/material.dart';
import 'workers_page.dart';
import 'work_page.dart';
import 'withdrawal_page.dart';
import 'pdf_page.dart';
import 'app_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
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

  double get totalWithdrawal {
    return AppData.withdrawals.fold(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  void openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('શેઠ Dashboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const Text(
                'હીરા કામ હિસ્ટરી',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.people,
                      title: 'કારીગર',
                      subtitle: 'કારીગર મેનેજમેન્ટ',
                      onTap: () {
                        openPage(
                          const WorkersPage(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.work,
                      title: 'કામ',
                      subtitle: 'કામ Entry',
                      onTap: () {
                        openPage(
                          const WorkPage(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.account_balance_wallet,
                      title: 'ઉપાડ',
                      subtitle: 'ઉપાડ Entry',
                      onTap: () {
                        openPage(
                          const WithdrawalPage(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dashboardCard(
                      icon: Icons.picture_as_pdf,
                      title: 'PDF',
                      subtitle: 'Report બનાવો',
                      onTap: () {
                        openPage(
                          const PdfPage(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.diamond,
                    size: 40,
                  ),
                  title: const Text(
                    'ટોટલ હીરા',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${totalDiamonds.toStringAsFixed(0)} હીરા',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.currency_rupee,
                    size: 40,
                  ),
                  title: const Text(
                    'ટોટલ કામ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '₹ ${totalWork.toStringAsFixed(2)}',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.payments,
                    size: 40,
                  ),
                  title: const Text(
                    'ટોટલ ઉપાડ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '₹ ${totalWithdrawal.toStringAsFixed(2)}',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.account_balance,
                    size: 40,
                  ),
                  title: const Text(
                    'બાકી રકમ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '₹ ${(totalWork - totalWithdrawal).toStringAsFixed(2)}',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25,
            horizontal: 8,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 45,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
