import 'package:flutter/material.dart';
import 'package:inventory_manager/models/stock_movement.dart';
import 'package:inventory_manager/services/stock_service.dart';
import 'package:inventory_manager/theme/app_theme.dart';

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  late Future<List<StockMovementModel>> _movements;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _movements = StockService.getMovements();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حركة المخزون والتقارير')),
      body: FutureBuilder<List<StockMovementModel>>(
        future: _movements,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final movements = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(
                    child: ElevatedButton.icon(
                  icon: const Icon(Icons.input_outlined),
                  label: const Text('تسجيل وارد'),
                  onPressed: () => _showMovementForm('وارد'),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: OutlinedButton.icon(
                  icon: const Icon(Icons.output_outlined),
                  label: const Text('تسجيل صرف'),
                  onPressed: () => _showMovementForm('صرف'),
                )),
              ]),
              const SizedBox(height: 20),
              const Text('سجل الحركات',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (movements.isEmpty) const Text('لا توجد حركات مسجلة'),
              ...movements.map((movement) => _MovementCard(movement: movement)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showMovementForm(String type) async {
    final productId = TextEditingController();
    final quantity = TextEditingController();
    final reference = TextEditingController();
    final notes = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(type == 'وارد' ? 'تسجيل وارد' : 'تسجيل صرف'),
        content: SingleChildScrollView(
            child: Column(children: [
          _field(productId, 'رقم المنتج'),
          _field(quantity, 'الكمية', numeric: true),
          _field(reference, 'المرجع'),
          _field(notes, 'ملاحظات'),
        ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () async {
                final value = int.tryParse(quantity.text);
                if (productId.text.trim().isEmpty ||
                    value == null ||
                    value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تحقق من رقم المنتج والكمية')));
                  return;
                }
                try {
                  await StockService.recordMovement(
                    productId: productId.text.trim(),
                    type: type,
                    quantity: value,
                    referenceNo: reference.text.trim(),
                    userName: 'المستخدم',
                    notes: notes.text.trim(),
                  );
                  if (mounted) Navigator.pop(context, true);
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error is StateError && type == 'صرف'
                            ? 'لا يمكن صرف كمية أكبر من المخزون'
                            : 'حدث خطأ أثناء تحديث المخزون')));
                  }
                }
              },
              child: const Text('حفظ')),
        ],
      ),
    );
    productId.dispose();
    quantity.dispose();
    reference.dispose();
    notes.dispose();
    if (saved == true && mounted) setState(_reload);
  }

  Widget _field(TextEditingController controller, String label,
      {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
          controller: controller,
          keyboardType: numeric ? TextInputType.number : null,
          decoration: InputDecoration(labelText: label)),
    );
  }
}

class _MovementCard extends StatelessWidget {
  final StockMovementModel movement;
  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final inbound = movement.type == 'وارد';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(inbound ? Icons.arrow_downward : Icons.arrow_upward,
            color: inbound ? AppTheme.successColor : AppTheme.dangerColor),
        title: Text(movement.productName),
        subtitle: Text(
            '${movement.type} - الكمية: ${movement.quantity}\n${movement.date}'),
      ),
    );
  }
}
