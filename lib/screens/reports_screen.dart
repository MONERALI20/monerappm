import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_manager/models/product.dart';
import 'package:inventory_manager/models/stock_movement.dart';
import 'package:inventory_manager/services/product_service.dart';
import 'package:inventory_manager/services/stock_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<ProductModel>> _products;
  ProductModel? _selectedProduct;
  String _stockFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _products = ProductService.getAllProducts();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير'),
          bottom: const TabBar(tabs: [
            Tab(text: 'تقرير المخزون', icon: Icon(Icons.inventory_2_outlined)),
            Tab(text: 'حركة المنتج', icon: Icon(Icons.timeline)),
          ]),
        ),
        body: FutureBuilder<List<ProductModel>>(
          future: _products,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final products = snapshot.data!;
            return TabBarView(children: [
              _InventoryReport(
                  products: products,
                  filter: _stockFilter,
                  onFilterChanged: (value) =>
                      setState(() => _stockFilter = value)),
              _MovementReport(
                products: products,
                selectedProduct: _selectedProduct,
                onProductChanged: (product) =>
                    setState(() => _selectedProduct = product),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _InventoryReport extends StatelessWidget {
  final List<ProductModel> products;
  final String filter;
  final ValueChanged<String> onFilterChanged;

  const _InventoryReport({
    required this.products,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((product) {
      if (filter == 'الناقص') {
        return product.currentQuantity > 0 && product.isLowStock;
      }
      if (filter == 'النافد') return product.currentQuantity == 0;
      return true;
    }).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: filter,
          decoration: const InputDecoration(labelText: 'تصفية التقرير'),
          items: const ['الكل', 'الناقص', 'النافد']
              .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) {
            if (value != null) onFilterChanged(value);
          },
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Center(child: Text('لا توجد منتجات مطابقة')),
        ...filtered.map((product) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(
                    'الكمية: ${product.currentQuantity} | شراء: ${product.purchasePrice.toStringAsFixed(2)} | بيع: ${product.salePrice.toStringAsFixed(2)}'),
                trailing: Text(
                  (product.currentQuantity * product.purchasePrice)
                      .toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: Icon(
                  product.currentQuantity == 0
                      ? Icons.error
                      : product.isLowStock
                          ? Icons.warning_amber
                          : Icons.check_circle,
                  color: product.currentQuantity == 0
                      ? Colors.red
                      : product.isLowStock
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            )),
      ],
    );
  }
}

class _MovementReport extends StatelessWidget {
  final List<ProductModel> products;
  final ProductModel? selectedProduct;
  final ValueChanged<ProductModel?> onProductChanged;

  const _MovementReport({
    required this.products,
    required this.selectedProduct,
    required this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<ProductModel>(
          initialValue: selectedProduct,
          decoration: const InputDecoration(labelText: 'اختر المنتج'),
          items: products
              .map((product) =>
                  DropdownMenuItem(value: product, child: Text(product.name)))
              .toList(),
          onChanged: onProductChanged,
        ),
        const SizedBox(height: 16),
        if (selectedProduct == null)
          const Center(child: Text('اختر منتجًا لعرض حركاته'))
        else
          FutureBuilder<List<StockMovementModel>>(
            future: StockService.getMovementsForProduct(selectedProduct!.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final movements = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الرصيد الحالي: ${selectedProduct!.currentQuantity}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (movements.isEmpty)
                    const Text('لا توجد حركات مسجلة لهذا المنتج'),
                  ...movements
                      .map((movement) => _MovementRow(movement: movement)),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  final StockMovementModel movement;
  const _MovementRow({required this.movement});

  @override
  Widget build(BuildContext context) {
    final inbound = movement.type == 'وارد';
    final date = DateTime.tryParse(movement.date);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(inbound ? Icons.add_circle : Icons.remove_circle,
          color: inbound ? Colors.green : Colors.red),
      title:
          Text('${movement.type}  ${inbound ? '+' : '-'}${movement.quantity}'),
      subtitle: Text(date == null
          ? movement.date
          : DateFormat('dd/MM/yyyy HH:mm').format(date)),
      trailing: Text(movement.referenceNo.isEmpty ? '-' : movement.referenceNo),
    );
  }
}
