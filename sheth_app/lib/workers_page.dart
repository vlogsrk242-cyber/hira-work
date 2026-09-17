```dart
import 'package:flutter/material.dart';

class Worker {
  String name;
  String mobile;
  String factoryNumber;

  Worker({
    required this.name,
    required this.mobile,
    required this.factoryNumber,
  });
}

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final List<Worker> workers = [];

  void showWorkerForm({Worker? worker, int? index}) {
    final nameController =
        TextEditingController(text: worker?.name ?? '');
    final mobileController =
        TextEditingController(text: worker?.mobile ?? '');
    final factoryController =
        TextEditingController(text: worker?.factoryNumber ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            worker == null ? 'કારીગર ઉમેરો' : 'કારીગર Edit કરો',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'કારીગરનું નામ',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'મોબાઈલ નંબર',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: factoryController,
                  decoration: const InputDecoration(
                    labelText: 'કારખાના નંબર',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
              ],
            ),
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
                if (nameController.text.trim().isEmpty ||
                    mobileController.text.trim().isEmpty ||
                    factoryController.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  if (worker == null) {
                    workers.add(
                      Worker(
                        name: nameController.text.trim(),
                        mobile: mobileController.text.trim(),
                        factoryNumber:
                            factoryController.text.trim(),
                      ),
                    );
                  } else {
                    workers[index!] = Worker(
                      name: nameController.text.trim(),
                      mobile: mobileController.text.trim(),
                      factoryNumber:
                          factoryController.text.trim(),
                    );
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteWorker(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('કારીગર Delete કરો?'),
          content: const Text(
            'શું તમે આ કારીગરને Delete કરવા માંગો છો?',
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
                  workers.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('કારીગર'),
        centerTitle: true,
      ),
      body: workers.isEmpty
          ? const Center(
              child: Text(
                'હજુ કોઈ કારીગર ઉમેરાયો નથી',
                style: TextStyle(fontSize: 17),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      worker.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'મોબાઈલ: ${worker.mobile}\n'
                      'કારખાના નંબર: ${worker.factoryNumber}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showWorkerForm(
                            worker: worker,
                            index: index,
                          );
                        }

                        if (value == 'delete') {
                          deleteWorker(index);
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
          showWorkerForm();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('કારીગર ઉમેરો'),
      ),
    );
  }
}
```
