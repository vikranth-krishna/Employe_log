import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/employee_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;

  DBHelper._();
  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String dbPath;
    if (kIsWeb) {

      dbPath = join(await getDatabasesPath(), 'employees.db');
    } else {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      dbPath = join(documentsDirectory.path, 'employees.db');
    }
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        startDate TEXT,
        endDate TEXT,
        isDeleted INTEGER
      )
    ''');
  }

  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert('employees', employee.toMap());
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
