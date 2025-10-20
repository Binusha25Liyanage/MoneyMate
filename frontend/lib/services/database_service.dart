import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serverId INTEGER,
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
        target_amount REAL NOT NULL,
        target_month INTEGER NOT NULL,
        target_year INTEGER NOT NULL,
        created_at TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Transaction methods
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toLocalMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => TransactionModel.fromLocalMap(map)).toList();
  }

  Future<List<TransactionModel>> getUnsyncedTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((map) => TransactionModel.fromLocalMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toLocalMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markTransactionAsSynced(int localId, int serverId) async {
    final db = await database;
    return await db.update(
      'transactions',
      {'serverId': serverId, 'isSynced': 1},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Goal methods
  Future<int> insertGoal(GoalModel goal) async {
    final db = await database;
    return await db.insert('goals', goal.toLocalMap());
  }

  Future<List<GoalModel>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals', orderBy: 'target_year DESC, target_month DESC');
    return maps.map((map) => GoalModel.fromLocalMap(map)).toList();
  }

  Future<List<GoalModel>> getUnsyncedGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((map) => GoalModel.fromLocalMap(map)).toList();
  }

  Future<int> updateGoal(GoalModel goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toLocalMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markGoalAsSynced(int localId, int serverId) async {
    final db = await database;
    return await db.update(
      'goals',
      {'serverId': serverId, 'isSynced': 1},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}