import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static Database? _database;

  static Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await database;
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    final databasePath =
        path.join(await getDatabasesPath(), 'inventory_manager.db');
    _database = await openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute('''CREATE TABLE products (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, code TEXT NOT NULL UNIQUE,
        barcode TEXT NOT NULL, category TEXT NOT NULL, unit TEXT NOT NULL,
        current_quantity INTEGER NOT NULL DEFAULT 0, minimum_stock INTEGER NOT NULL DEFAULT 0,
        purchase_price REAL NOT NULL DEFAULT 0, sale_price REAL NOT NULL DEFAULT 0,
        supplier TEXT NOT NULL, date_added TEXT NOT NULL, image_url TEXT NOT NULL)''');
      await db.execute('''CREATE TABLE stock_movements (
        id TEXT PRIMARY KEY, product_id TEXT NOT NULL, product_name TEXT NOT NULL,
        type TEXT NOT NULL, quantity INTEGER NOT NULL, reference_no TEXT NOT NULL,
        user_name TEXT NOT NULL, date TEXT NOT NULL, notes TEXT NOT NULL)''');
    });
    return _database!;
  }
}
