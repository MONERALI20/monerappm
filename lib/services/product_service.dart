import 'package:sqflite/sqflite.dart';
import 'package:inventory_manager/database/database_helper.dart';
import 'package:inventory_manager/models/product.dart';

class ProductService {
  static Future<List<ProductModel>> getAllProducts() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query('products', orderBy: 'date_added DESC');
    return rows.map(ProductModel.fromMap).toList();
  }

  static Future<List<ProductModel>> search(String query) async {
    final db = await DatabaseHelper.database;
    final value = query.trim();
    final rows = await db.query(
      'products',
      where: value.isEmpty
          ? null
          : 'name LIKE ? OR code LIKE ? OR barcode LIKE ? OR category LIKE ?',
      whereArgs: value.isEmpty ? null : List.filled(4, '%$value%'),
      orderBy: 'date_added DESC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  static Future<void> save(ProductModel product) async {
    final db = await DatabaseHelper.database;
    await db.transaction((transaction) async {
      final existing = await transaction.query('products',
          where: 'id = ?', whereArgs: [product.id], limit: 1);
      final oldQuantity =
          existing.isEmpty ? 0 : existing.first['current_quantity']! as int;
      await transaction.insert('products', product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      final difference = product.currentQuantity - oldQuantity;
      if (difference == 0) return;
      await transaction.insert('stock_movements', {
        'id': 'MOV-${DateTime.now().microsecondsSinceEpoch}',
        'product_id': product.id,
        'product_name': product.name,
        'type': difference > 0 ? 'وارد' : 'جرد',
        'quantity': difference.abs(),
        'reference_no': existing.isEmpty ? 'رصيد افتتاحي' : 'تعديل المنتج',
        'user_name': 'المستخدم',
        'date': DateTime.now().toIso8601String(),
        'notes': existing.isEmpty ? 'الرصيد الافتتاحي' : 'تسوية فرق الكمية',
      });
    });
  }

  static Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    await db.transaction((transaction) async {
      await transaction
          .delete('stock_movements', where: 'product_id = ?', whereArgs: [id]);
      await transaction.delete('products', where: 'id = ?', whereArgs: [id]);
    });
  }
}
