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
    try {
      // Handle amount which might be int or double
      double parseAmount(dynamic amountValue) {
        if (amountValue == null) return 0.0;
        if (amountValue is int) return amountValue.toDouble();
        if (amountValue is double) return amountValue;
        if (amountValue is String) return double.tryParse(amountValue) ?? 0.0;
        return 0.0;
      }

      // Handle date parsing
      DateTime parseDate(dynamic dateValue) {
        if (dateValue == null) return DateTime.now();
        try {
          if (dateValue is String) {
            return DateTime.parse(dateValue);
          }
          return DateTime.now();
        } catch (e) {
          print('Error parsing date: $dateValue, error: $e');
          return DateTime.now();
        }
      }

      // Handle description - use 'desc' field from JSON
      String description = 'No Description';
      if (json['desc'] != null) {
        description = json['desc'].toString();
      } else if (json['description'] != null) {
        description = json['description'].toString();
      }
      
      // Handle type - default to 'expense' if null
      String type = 'expense';
      if (json['type'] != null) {
        type = json['type'].toString();
      }
      
      // Handle category - default to 'Other' if null
      String category = 'Other';
      if (json['category'] != null) {
        category = json['category'].toString();
      }

      // Handle date_created
      DateTime? dateCreated;
      if (json['date_created'] != null) {
        try {
          dateCreated = DateTime.parse(json['date_created'].toString());
        } catch (e) {
          print('Error parsing date_created: ${json['date_created']}');
          dateCreated = null;
        }
      }

      return TransactionModel(
        serverId: json['id'] is int ? json['id'] : null,
        amount: parseAmount(json['amount']),
        description: description,
        type: type,
        category: category,
        date: parseDate(json['date'] ?? json['transaction_date']),
        dateCreated: dateCreated,
        isSynced: true,
      );
    } catch (e) {
      print('Error creating TransactionModel from JSON: $e');
      print('JSON data: $json');
      // Return a default transaction model to prevent complete failure
      return TransactionModel(
        amount: 0.0,
        description: 'Error parsing transaction',
        type: 'expense',
        category: 'Other',
        date: DateTime.now(),
        isSynced: true,
      );
    }
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
      amount: map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount'],
      description: map['description']?.toString() ?? 'No Description',
      type: map['type']?.toString() ?? 'expense',
      category: map['category']?.toString() ?? 'Other',
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