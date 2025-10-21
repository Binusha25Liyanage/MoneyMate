import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  int? _currentUserId;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version for schema changes
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serverId INTEGER,
        userId INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        date_created TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serverId INTEGER,
        userId INTEGER NOT NULL,
        target_amount REAL NOT NULL,
        target_month INTEGER NOT NULL,
        target_year INTEGER NOT NULL,
        created_at TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE current_user(
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        last_login TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add userId column to transactions table
      await db.execute('''
        CREATE TABLE transactions_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverId INTEGER,
          userId INTEGER NOT NULL,
          amount REAL NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          date_created TEXT,
          isSynced INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Copy data from old table to new table
      await db.execute('''
        INSERT INTO transactions_new (id, serverId, userId, amount, description, type, category, date, date_created, isSynced)
        SELECT id, serverId, 0, amount, description, type, category, date, date_created, isSynced FROM transactions
      ''');

      // Drop old table and rename new one
      await db.execute('DROP TABLE transactions');
      await db.execute('ALTER TABLE transactions_new RENAME TO transactions');

      // Add userId column to goals table
      await db.execute('''
        CREATE TABLE goals_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverId INTEGER,
          userId INTEGER NOT NULL,
          target_amount REAL NOT NULL,
          target_month INTEGER NOT NULL,
          target_year INTEGER NOT NULL,
          created_at TEXT,
          isSynced INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Copy data from old table to new table
      await db.execute('''
        INSERT INTO goals_new (id, serverId, userId, target_amount, target_month, target_year, created_at, isSynced)
        SELECT id, serverId, 0, target_amount, target_month, target_year, created_at, isSynced FROM goals
      ''');

      // Drop old table and rename new one
      await db.execute('DROP TABLE goals');
      await db.execute('ALTER TABLE goals_new RENAME TO goals');

      // Create current_user table
      await db.execute('''
        CREATE TABLE current_user(
          id INTEGER PRIMARY KEY,
          user_id INTEGER NOT NULL,
          last_login TEXT NOT NULL
        )
      ''');
    }
  }

  // User management methods
  Future<void> setCurrentUser(int userId) async {
    final db = await database;
    _currentUserId = userId;
    
    // Clear any existing current user
    await db.delete('current_user');
    
    // Insert new current user
    await db.insert('current_user', {
      'user_id': userId,
      'last_login': DateTime.now().toIso8601String(),
    });
  }

  Future<int?> getCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId;
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('current_user');
    
    if (maps.isNotEmpty) {
      _currentUserId = maps.first['user_id'] as int;
      return _currentUserId;
    }
    
    return null;
  }

  Future<void> clearCurrentUser() async {
    final db = await database;
    _currentUserId = null;
    await db.delete('current_user');
  }

  // Transaction methods
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    final localMap = transaction.toLocalMap();
    localMap['userId'] = userId;
    
    return await db.insert('transactions', localMap);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      return [];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions', 
      where: 'userId = ?', 
      whereArgs: [userId],
      orderBy: 'date DESC'
    );
    
    return maps.map((map) => TransactionModel.fromLocalMap(map)).toList();
  }

  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      return [];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions', 
      where: 'isSynced = ? AND userId = ?', 
      whereArgs: [0, userId]
    );
    
    return maps.map((map) => TransactionModel.fromLocalMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    final localMap = transaction.toLocalMap();
    localMap['userId'] = userId;
    
    return await db.update(
      'transactions',
      localMap,
      where: 'id = ? AND userId = ?',
      whereArgs: [transaction.id, userId],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    return await db.delete(
      'transactions',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> markTransactionAsSynced(int localId, int serverId) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    return await db.update(
      'transactions',
      {'serverId': serverId, 'isSynced': 1},
      where: 'id = ? AND userId = ?',
      whereArgs: [localId, userId],
    );
  }

  Future<void> clearAllTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }

  // Goal methods
  Future<int> insertGoal(GoalModel goal) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    final localMap = goal.toLocalMap();
    localMap['userId'] = userId;
    
    return await db.insert('goals', localMap);
  }

  Future<List<GoalModel>> getGoals() async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      return [];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'goals', 
      where: 'userId = ?', 
      whereArgs: [userId],
      orderBy: 'target_year DESC, target_month DESC'
    );
    
    return maps.map((map) => GoalModel.fromLocalMap(map)).toList();
  }

  Future<List<GoalModel>> getUnsyncedGoals() async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      return [];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'goals', 
      where: 'isSynced = ? AND userId = ?', 
      whereArgs: [0, userId]
    );
    
    return maps.map((map) => GoalModel.fromLocalMap(map)).toList();
  }

  Future<int> updateGoal(GoalModel goal) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    final localMap = goal.toLocalMap();
    localMap['userId'] = userId;
    
    return await db.update(
      'goals',
      localMap,
      where: 'id = ? AND userId = ?',
      whereArgs: [goal.id, userId],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    return await db.delete(
      'goals',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> markGoalAsSynced(int localId, int serverId) async {
    final db = await database;
    final userId = await getCurrentUserId();
    
    if (userId == null) {
      throw Exception('No current user found');
    }

    return await db.update(
      'goals',
      {'serverId': serverId, 'isSynced': 1},
      where: 'id = ? AND userId = ?',
      whereArgs: [localId, userId],
    );
  }

  Future<void> clearAllGoals() async {
    final db = await database;
    await db.delete('goals');
  }

  // Clear all user data (for logout)
  Future<void> clearAllUserData() async {
    final db = await database;
    await clearCurrentUser();
    await clearAllTransactions();
    await clearAllGoals();
  }
}