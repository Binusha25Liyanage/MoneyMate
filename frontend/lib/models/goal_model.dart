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
    return GoalModel(
      serverId: json['id'],
      targetAmount: json['target_amount'] is int ? (json['target_amount'] as int).toDouble() : json['target_amount'],
      targetMonth: json['target_month'],
      targetYear: json['target_year'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isSynced: true,
    );
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
      targetAmount: map['target_amount'],
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