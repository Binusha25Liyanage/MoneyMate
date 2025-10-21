class TransactionModel {
  final int? id;
  final int? serverId;
  final int? userId;
  final double amount;
  final String description;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;
  final DateTime? dateCreated;
  final bool isSynced;

  TransactionModel({
    this.id,
    this.serverId,
    this.userId,
    required this.amount,
    required this.description,
    required this.type,
    required this.category,
    required this.date,
    this.dateCreated,
    this.isSynced = false,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      serverId: json['id'],
      amount: json['amount'] is int ? (json['amount'] as int).toDouble() : json['amount'],
      description: json['desc'] ?? json['description'],
      type: json['type'],
      category: json['category'],
      date: DateTime.parse(json['date'] ?? json['transaction_date']),
      dateCreated: json['date_created'] != null ? DateTime.parse(json['date_created']) : null,
      isSynced: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (serverId != null) 'id': serverId,
      'amount': amount,
      'desc': description,
      'type': type,
      'category': category,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'serverId': serverId,
      'userId': userId,
      'amount': amount,
      'description': description,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'date_created': dateCreated?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory TransactionModel.fromLocalMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      serverId: map['serverId'],
      userId: map['userId'],
      amount: map['amount'],
      description: map['description'],
      type: map['type'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      dateCreated: map['date_created'] != null ? DateTime.parse(map['date_created']) : null,
      isSynced: map['isSynced'] == 1,
    );
  }

  TransactionModel copyWith({
    int? id,
    int? serverId,
    int? userId,
    double? amount,
    String? description,
    String? type,
    String? category,
    DateTime? date,
    DateTime? dateCreated,
    bool? isSynced,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      dateCreated: dateCreated ?? this.dateCreated,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}