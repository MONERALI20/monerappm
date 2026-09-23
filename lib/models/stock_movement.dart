class StockMovementModel {
  final String id;
  final String productName;
  final String productId;
  final String type;
  final int quantity;
  final String referenceNo;
  final String userName;
  final String date;
  final String notes;

  const StockMovementModel({
    required this.id,
    required this.productName,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.referenceNo,
    required this.userName,
    required this.date,
    required this.notes,
  });

  String get quantityText => type == 'وارد' ? '+$quantity' : '-$quantity';

  factory StockMovementModel.fromMap(Map<String, Object?> map) {
    return StockMovementModel(
      id: map['id']! as String,
      productName: map['product_name']! as String,
      productId: map['product_id']! as String,
      type: map['type']! as String,
      quantity: map['quantity']! as int,
      referenceNo: map['reference_no']! as String,
      userName: map['user_name']! as String,
      date: map['date']! as String,
      notes: map['notes']! as String,
    );
  }
}
