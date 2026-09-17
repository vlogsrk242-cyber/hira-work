class WorkerData {
  final String name;
  final String mobile;
  final String factoryNumber;

  WorkerData({
    required this.name,
    required this.mobile,
    required this.factoryNumber,
  });
}

class WorkData {
  final String section;
  final String date;
  final String worker;
  final double diamonds;
  final double rate;

  WorkData({
    required this.section,
    required this.date,
    required this.worker,
    required this.diamonds,
    required this.rate,
  });

  double get totalWork => diamonds * rate;
}

class WithdrawalData {
  final String section;
  final String date;
  final String worker;
  final double amount;

  WithdrawalData({
    required this.section,
    required this.date,
    required this.worker,
    required this.amount,
  });
}

class AppData {
  static final List<WorkerData> workers = [];
  static final List<WorkData> works = [];
  static final List<WithdrawalData> withdrawals = [];
}
