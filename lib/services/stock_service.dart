import 'package:inventory_manager/database/database_helper.dart';
import 'package:inventory_manager/models/stock_movement.dart';

class StockService {
  static Future<List<StockMovementModel>> getMovements() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query('stock_movements', orderBy: 'date DESC');
    return rows.map(StockMovementModel.fromMap).toList();
  }

  static Future<List<StockMovementModel>> getMovementsForProduct(
      String productId) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query('stock_movements',
        where: 'product_id = ?', whereArgs: [productId], orderBy: 'date ASC');
    return rows.map(StockMovementModel.fromMap).toList();
  }

  static Future<void> recordMovement({
    required String productId,
    required String type,
    required int quantity,
    required String referenceNo,
    required String userName,
    required String notes,
  }) async {
    if (quantity <= 0) throw ArgumentError('الكمية يجب أن تكون أكبر من صفر');
    final db = await DatabaseHelper.database;
    await db.transaction((transaction) async {
      final products = await transaction
          .query('products', where: 'id = ?', whereArgs: [productId]);
      if (products.isEmpty) throw StateError('المنتج غير موجود');
      final currentQuantity = products.first['current_quantity']! as int;
      if (type == 'صرف' && quantity > currentQuantity) {
        throw StateError('لا يمكن صرف كمية أكبر من المخزون');
      }
      final newQuantity = type == 'وارد'
          ? currentQuantity + quantity
          : currentQuantity - quantity;
      await transaction.update('products', {'current_quantity': newQuantity},
          where: 'id = ?', whereArgs: [productId]);
      await transaction.insert('stock_movements', {
        'id': 'MOV-${DateTime.now().microsecondsSinceEpoch}',
        'product_id': productId,
        'product_name': products.first['name'],
        'type': type,
        'quantity': quantity,
        'reference_no': referenceNo,
        'user_name': userName,
        'date': DateTime.now().toIso8601String(),
        'notes': notes,
      });
    });
  }
}
