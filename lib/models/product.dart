class ProductModel {
  final String id;
  final String name;
  final String code;
  final String barcode;
  final String category;
  final String unit;
  final int currentQuantity;
  final int minimumStock;
  final double purchasePrice;
  final double salePrice;
  final String supplier;
  final String dateAdded;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.code,
    required this.barcode,
    required this.category,
    required this.unit,
    required this.currentQuantity,
    required this.minimumStock,
    required this.purchasePrice,
    required this.salePrice,
    required this.supplier,
    required this.dateAdded,
    this.imageUrl =
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
  });

  bool get isLowStock => currentQuantity <= minimumStock;

  factory ProductModel.fromMap(Map<String, Object?> map) {
    return ProductModel(
      id: map['id']! as String,
      name: map['name']! as String,
      code: map['code']! as String,
      barcode: map['barcode']! as String,
      category: map['category']! as String,
      unit: map['unit']! as String,
      currentQuantity: map['current_quantity']! as int,
      minimumStock: map['minimum_stock']! as int,
      purchasePrice: (map['purchase_price']! as num).toDouble(),
      salePrice: (map['sale_price']! as num).toDouble(),
      supplier: map['supplier']! as String,
      dateAdded: map['date_added']! as String,
      imageUrl: map['image_url']! as String,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'code': code,
        'barcode': barcode,
        'category': category,
        'unit': unit,
        'current_quantity': currentQuantity,
        'minimum_stock': minimumStock,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'supplier': supplier,
        'date_added': dateAdded,
        'image_url': imageUrl,
      };
}
