class GoalModel {
  final int? id;
  final int? serverId;
  final int? userId;
  final double targetAmount;
  final int targetMonth;
  final int targetYear;
  final DateTime? createdAt;
  final bool isSynced;

  GoalModel({
    this.id,
    this.serverId,
    this.userId,
    required this.targetAmount,
    required this.targetMonth,
    required this.targetYear,
    this.createdAt,
    this.isSynced = false,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle targetAmount which might be int or double
      double parseAmount(dynamic amountValue) {
        if (amountValue == null) return 0.0;
        if (amountValue is int) return amountValue.toDouble();
        if (amountValue is double) return amountValue;
        if (amountValue is String) return double.tryParse(amountValue) ?? 0.0;
        return 0.0;
      }

      // Handle targetMonth and targetYear
      int parseMonth(dynamic monthValue) {
        if (monthValue == null) return DateTime.now().month;
        if (monthValue is int) return monthValue;
        if (monthValue is String) return int.tryParse(monthValue) ?? DateTime.now().month;
        return DateTime.now().month;
      }

      int parseYear(dynamic yearValue) {
        if (yearValue == null) return DateTime.now().year;
        if (yearValue is int) return yearValue;
        if (yearValue is String) return int.tryParse(yearValue) ?? DateTime.now().year;
        return DateTime.now().year;
      }

      // Handle createdAt
      DateTime? createdAt;
      if (json['created_at'] != null) {
        try {
          createdAt = DateTime.parse(json['created_at'].toString());
        } catch (e) {
          print('Error parsing created_at: ${json['created_at']}');
          createdAt = null;
        }
      }

      return GoalModel(
        serverId: json['id'] is int ? json['id'] : null,
        targetAmount: parseAmount(json['target_amount']),
        targetMonth: parseMonth(json['target_month']),
        targetYear: parseYear(json['target_year']),
        createdAt: createdAt,
        isSynced: true,
      );
    } catch (e) {
      print('Error creating GoalModel from JSON: $e');
      print('JSON data: $json');
      // Return a default goal model to prevent complete failure
      return GoalModel(
        targetAmount: 0.0,
        targetMonth: DateTime.now().month,
        targetYear: DateTime.now().year,
        isSynced: true,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (serverId != null) 'id': serverId,
      'target_amount': targetAmount,
      'target_month': targetMonth,
      'target_year': targetYear,
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'serverId': serverId,
      'userId': userId,
      'target_amount': targetAmount,
      'target_month': targetMonth,
      'target_year': targetYear,
      'created_at': createdAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory GoalModel.fromLocalMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      serverId: map['serverId'],
      userId: map['userId'],
      targetAmount: map['target_amount'] is int ? (map['target_amount'] as int).toDouble() : map['target_amount'],
      targetMonth: map['target_month'],
      targetYear: map['target_year'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      isSynced: map['isSynced'] == 1,
    );
  }

  GoalModel copyWith({
    int? id,
    int? serverId,
    int? userId,
    double? targetAmount,
    int? targetMonth,
    int? targetYear,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return GoalModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      targetAmount: targetAmount ?? this.targetAmount,
      targetMonth: targetMonth ?? this.targetMonth,
      targetYear: targetYear ?? this.targetYear,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  String get monthYear {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[targetMonth - 1]} $targetYear';
  }
}