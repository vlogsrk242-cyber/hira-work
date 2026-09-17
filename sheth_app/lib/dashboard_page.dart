import 'package:flutter/material.dart';

import 'app_data.dart';
import 'workers_page.dart';
import 'work_page.dart';
import 'withdrawal_page.dart';
import 'pdf_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;

  double get totalDiamonds {
    return AppData.works.fold(
      0,
      (sum, work) => sum + work.diamonds,
    );
  }

  double get totalWork {
    return AppData.works.fold(
      0,
      (sum, work) => sum + work.totalWork,
    );
  }

  double get totalWithdrawal {
    return AppData.withdrawals.fold(
      0,
      (sum, withdrawal) => sum + withdrawal.amount,
    );
  }

  double get balance {
    return totalWork - totalWithdrawal;
  }

  void openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    ).then((_) {
      setState(() {});
    });
  }

  String money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'હીરા કામ હિસ્ટરી',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 18),

                const Text(
                  'ઝડપી વિકલ્પો',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    _buildMenuCard(
                      icon: Icons.people,
                      title: 'કારીગર',
                      subtitle: 'Add / Edit / Delete',
                      onTap: () {
                        openPage(const WorkersPage());
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.diamond,
                      title: 'કામ',
                      subtitle: 'હીરા અને Rate',
                      onTap: () {
                        openPage(const WorkPage());
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.account_balance_wallet,
                      title: 'ઉપાડ',
                      subtitle: 'ઉપાડની નોંધ',
                      onTap: () {
                        openPage(const WithdrawalPage());
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.picture_as_pdf,
                      title: 'PDF',
                      subtitle: 'Report / Share / Print',
                      onTap: () {
                        openPage(const PdfPage());
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'કુલ હિસાબ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _buildSummaryCard(
                  icon: Icons.diamond,
                  title: 'કુલ હીરા',
                  value: totalDiamonds.toStringAsFixed(0),
                ),

                const SizedBox(height: 10),

                _buildSummaryCard(
                  icon: Icons.currency_rupee,
                  title: 'કુલ કામ',
                  value: money(totalWork),
                ),

                const SizedBox(height: 10),

                _buildSummaryCard(
                  icon: Icons.account_balance_wallet,
                  title: 'કુલ ઉપાડ',
                  value: money(totalWithdrawal),
                ),

                const SizedBox(height: 10),

                _buildSummaryCard(
                  icon: Icons.account_balance,
                  title: 'બાકી રકમ',
                  value: money(balance),
                ),

                const SizedBox(height: 24),

                _buildSectionSummary('તળીયા'),
                const SizedBox(height: 8),
                _buildSectionSummary('પેલ'),
                const SizedBox(height: 8),
                _buildSectionSummary('મથાળા'),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 0) {
            openPage(
              const WorkPage(
                initialSection: 'તળીયા',
              ),
            );
          }

          if (index == 1) {
            openPage(
              const WorkPage(
                initialSection: 'પેલ',
              ),
            );
          }

          if (index == 2) {
            openPage(
              const WorkPage(
                initialSection: 'મથાળા',
              ),
            );
          }

          if (index == 3) {
            openPage(const WorkersPage());
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.diamond_outlined),
            selectedIcon: Icon(Icons.diamond),
            label: 'તળીયા',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'પેલ',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'મથાળા',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'કારીગર',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: const Icon(
                Icons.diamond,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'શેઠ Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'હીરા કામનો સંપૂર્ણ હિસાબ',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSummary(String section) {
    final sectionWorks = AppData.works
        .where((work) => work.section == section)
        .toList();

    final diamonds = sectionWorks.fold(
      0.0,
      (sum, work) => sum + work.diamonds,
    );

    final workAmount = sectionWorks.fold(
      0.0,
      (sum, work) => sum + work.totalWork,
    );

    final sectionWithdrawals = AppData.withdrawals
        .where((withdrawal) => withdrawal.section == section)
        .toList();

    final withdrawalAmount = sectionWithdrawals.fold(
      0.0,
      (sum, withdrawal) => sum + withdrawal.amount,
    );

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.category),
        title: Text(
          section,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'હીરા: ${diamonds.toStringAsFixed(0)}',
        ),
        children: [
          ListTile(
            title: const Text('કુલ કામ'),
            trailing: Text(
              money(workAmount),
            ),
          ),
          ListTile(
            title: const Text('કુલ ઉપાડ'),
            trailing: Text(
              money(withdrawalAmount),
            ),
          ),
          ListTile(
            title: const Text('બાકી'),
            trailing: Text(
              money(workAmount - withdrawalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
