import 'package:flutter/material.dart';
import 'package:inventory_manager/models/product.dart';
import 'package:inventory_manager/services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final search = TextEditingController();
  late Future<List<ProductModel>> products;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => products = ProductService.search(search.text);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('المنتجات والمخزون')),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: search,
                onChanged: (_) => setState(_reload),
                decoration: const InputDecoration(
                    hintText: 'بحث باسم المنتج أو الكود أو الباركود',
                    prefixIcon: Icon(Icons.search)),
              )),
          Expanded(
              child: FutureBuilder<List<ProductModel>>(
            future: products,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('لا توجد منتجات'));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) {
                    final product = snapshot.data![index];
                    return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            'الكود: ${product.code} | الكمية: ${product.currentQuantity}'),
                        onTap: () => _edit(product));
                  });
            },
          )),
        ]),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('إضافة منتج')),
      );

  Future<void> _add() => _form();
  Future<void> _edit(ProductModel product) => _form(product);
  Future<void> _form([ProductModel? old]) async {
    final name = TextEditingController(text: old?.name);
    final code = TextEditingController(text: old?.code);
    final quantity =
        TextEditingController(text: '${old?.currentQuantity ?? 0}');
    final minimum = TextEditingController(text: '${old?.minimumStock ?? 0}');
    final purchase = TextEditingController(text: '${old?.purchasePrice ?? 0}');
    final sale = TextEditingController(text: '${old?.salePrice ?? 0}');
    final result = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(old == null ? 'إضافة منتج' : 'تعديل المنتج'),
              content: SingleChildScrollView(
                  child: Column(children: [
                _field(name, 'اسم المنتج'),
                _field(code, 'رمز المنتج'),
                _field(quantity, 'الكمية'),
                _field(minimum, 'الحد الأدنى'),
                _field(purchase, 'سعر الشراء'),
                _field(sale, 'سعر البيع'),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء')),
                ElevatedButton(
                    onPressed: () async {
                      final q = int.tryParse(quantity.text),
                          min = int.tryParse(minimum.text);
                      final buy = double.tryParse(purchase.text),
                          sell = double.tryParse(sale.text);
                      if (name.text.trim().isEmpty ||
                          code.text.trim().isEmpty ||
                          q == null ||
                          q < 0 ||
                          min == null ||
                          min < 0 ||
                          buy == null ||
                          buy < 0 ||
                          sell == null ||
                          sell < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تحقق من جميع المدخلات')));
                        return;
                      }
                      try {
                        await ProductService.save(ProductModel(
                            id: old?.id ??
                                'PRD-${DateTime.now().microsecondsSinceEpoch}',
                            name: name.text.trim(),
                            code: code.text.trim(),
                            barcode: old?.barcode ?? code.text.trim(),
                            category: old?.category ?? 'عام',
                            unit: old?.unit ?? 'قطعة',
                            currentQuantity: q,
                            minimumStock: min,
                            purchasePrice: buy,
                            salePrice: sell,
                            supplier: old?.supplier ?? '',
                            dateAdded: old?.dateAdded ??
                                DateTime.now().toIso8601String(),
                            imageUrl: old?.imageUrl ?? ''));
                        if (mounted) Navigator.pop(context, true);
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('حدث خطأ أثناء حفظ المنتج')));
                      }
                    },
                    child: const Text('حفظ'))
              ],
            ));
    name.dispose();
    code.dispose();
    quantity.dispose();
    minimum.dispose();
    purchase.dispose();
    sale.dispose();
    if (result == true && mounted) setState(_reload);
  }

  Widget _field(TextEditingController c, String label) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label)));
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }
}
