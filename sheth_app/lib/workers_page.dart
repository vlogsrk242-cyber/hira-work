import 'package:flutter/material.dart';
import 'app_data.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  void showWorkerForm({
    WorkerData? worker,
    int? index,
  }) {
    final nameController = TextEditingController(
      text: worker?.name ?? '',
    );

    final mobileController = TextEditingController(
      text: worker?.mobile ?? '',
    );

    final factoryController = TextEditingController(
      text: worker?.factoryNumber ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            worker == null
                ? 'કારીગર ઉમેરો'
                : 'કારીગર Edit કરો',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'કારીગરનું નામ',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'મોબાઈલ નંબર',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: factoryController,
                  decoration: const InputDecoration(
                    labelText: 'કારખાના નંબર',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
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
                final name = nameController.text.trim();
                final mobile = mobileController.text.trim();
                final factory =
                    factoryController.text.trim();

                if (name.isEmpty ||
                    mobile.isEmpty ||
                    factory.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'બધી માહિતી ભરો',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  final newWorker = WorkerData(
                    name: name,
                    mobile: mobile,
                    factoryNumber: factory,
                  );

                  if (worker == null) {
                    AppData.workers.add(newWorker);
                  } else {
                    AppData.workers[index!] =
                        newWorker;
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
  }

  void deleteWorker(int index) {
    final worker = AppData.workers[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'કારીગર Delete કરો?',
          ),
          content: Text(
            'શું તમે "${worker.name}" ને Delete કરવા માંગો છો?',
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
                  AppData.workers.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👷 કારીગર'),
        centerTitle: true,
      ),
      body: AppData.workers.isEmpty
          ? const Center(
              child: Text(
                'હજુ કોઈ કારીગર ઉમેરાયો નથી',
                style: TextStyle(fontSize: 17),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: AppData.workers.length,
              itemBuilder: (context, index) {
                final worker =
                    AppData.workers[index];

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
                    trailing:
                        PopupMenuButton<String>(
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
                      itemBuilder: (context) =>
                          const [
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
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showWorkerForm();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('કારીગર ઉમેરો'),
      ),
    );
  }
}
