```dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('શેઠ Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                    context,
                    icon: Icons.people,
                    title: 'કારીગર',
                    subtitle: 'કારીગર મેનેજમેન્ટ',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dashboardCard(
                    context,
                    icon: Icons.work,
                    title: 'કામ',
                    subtitle: 'કામ Entry',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _dashboardCard(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'ઉપાડ',
                    subtitle: 'ઉપાડ Entry',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dashboardCard(
                    context,
                    icon: Icons.picture_as_pdf,
                    title: 'PDF',
                    subtitle: 'Report બનાવો',
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
                subtitle: const Text(
                  '0 હીરા',
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
                subtitle: const Text(
                  '₹ 0',
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
                subtitle: const Text(
                  '₹ 0',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title વિભાગ આગળ બનાવવામાં આવશે'),
            ),
          );
        },
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
```
