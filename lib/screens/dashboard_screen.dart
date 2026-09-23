import 'package:flutter/material.dart';
import 'package:inventory_manager/models/user.dart';
import 'package:inventory_manager/screens/products_screen.dart';
import 'package:inventory_manager/screens/reports_screen.dart';
import 'package:inventory_manager/screens/stock_movement_screen.dart';
import 'package:inventory_manager/services/product_service.dart';
import 'package:inventory_manager/services/stock_service.dart';
import 'package:inventory_manager/theme/app_theme.dart';
import 'package:inventory_manager/widgets/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;
  const DashboardScreen({super.key, required this.user});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> summary;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => summary = Future.wait(
      [ProductService.getAllProducts(), StockService.getMovements()]);
  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
        future: summary,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          final products = snapshot.data![0] as List,
              movements = snapshot.data![1] as List;
          final lowStock = products.where((item) => item.isLowStock).length;
          final inbound = movements.where((item) => item.type == 'وارد').length;
          final outbound = movements.where((item) => item.type == 'صرف').length;
          return Scaffold(
            appBar: AppBar(
              title: const Text('لوحة التحكم'),
              actions: [
                IconButton(
                  tooltip: 'تسجيل الخروج',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.logout),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final content = ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    Text('نظرة عامة',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                        'مرحباً ${widget.user.displayName}، إليك ملخص نشاط المستودع اليوم.',
                        style: const TextStyle(color: AppTheme.mutedTextColor)),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.maxWidth > 900 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          DashboardCard(
                              title: 'إجمالي المنتجات',
                              value: '${products.length}',
                              icon: Icons.inventory_2_outlined,
                              color: AppTheme.accentColor),
                          DashboardCard(
                              title: 'منخفض المخزون',
                              value: '$lowStock',
                              icon: Icons.warning_amber_outlined,
                              color: AppTheme.warningColor),
                          DashboardCard(
                              title: 'حركات الوارد',
                              value: '$inbound',
                              icon: Icons.south_west,
                              color: AppTheme.cyanColor),
                          DashboardCard(
                              title: 'حركات الصادر',
                              value: '$outbound',
                              icon: Icons.north_east,
                              color: AppTheme.successColor),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final wide = constraints.maxWidth > 800;
                      final actions = _QuickActions(
                        onProducts: _openProducts,
                        onMovements: _openMovements,
                        onReports: _openReports,
                      );
                      final recent = _RecentMovements(movements: movements);
                      return wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Expanded(child: recent),
                                  const SizedBox(width: 16),
                                  SizedBox(width: 290, child: actions)
                                ])
                          : Column(children: [
                              actions,
                              const SizedBox(height: 16),
                              recent
                            ]);
                    }),
                  ],
                );
                if (constraints.maxWidth < 760) return content;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Sidebar(
                      user: widget.user,
                      onProducts: _openProducts,
                      onMovements: _openMovements,
                      onReports: _openReports,
                    ),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          );
        },
      );

  Future<void> _openProducts() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
    if (mounted) setState(_reload);
  }

  Future<void> _openMovements() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const StockMovementScreen()));
    if (mounted) setState(_reload);
  }

  void _openReports() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
}

class _Sidebar extends StatelessWidget {
  final UserModel user;
  final VoidCallback onProducts;
  final VoidCallback onMovements;
  final VoidCallback onReports;
  const _Sidebar(
      {required this.user,
      required this.onProducts,
      required this.onMovements,
      required this.onReports});

  @override
  Widget build(BuildContext context) => Container(
        width: 230,
        margin: const EdgeInsets.only(right: 18, bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border(left: BorderSide(color: AppTheme.borderColor)),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppTheme.cyanColor)),
            const SizedBox(width: 10),
            const Text('مخزني',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 34),
          const Text('القائمة الرئيسية',
              style: TextStyle(color: AppTheme.mutedTextColor, fontSize: 12)),
          const SizedBox(height: 10),
          _NavItem(
              icon: Icons.dashboard_outlined,
              label: 'الرئيسية',
              selected: true,
              onTap: () {}),
          _NavItem(
              icon: Icons.inventory_2_outlined,
              label: 'المنتجات',
              onTap: onProducts),
          _NavItem(
              icon: Icons.swap_horiz,
              label: 'حركة المخزون',
              onTap: onMovements),
          _NavItem(
              icon: Icons.assessment_outlined,
              label: 'التقارير',
              onTap: onReports),
          const Spacer(),
          Text(user.role,
              style: const TextStyle(
                  color: AppTheme.mutedTextColor, fontSize: 12)),
          const SizedBox(height: 4),
          Text(user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.selected = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          dense: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor:
              selected ? AppTheme.accentColor.withValues(alpha: .16) : null,
          leading: Icon(icon,
              color: selected ? AppTheme.cyanColor : AppTheme.mutedTextColor,
              size: 20),
          title: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppTheme.mutedTextColor)),
          onTap: onTap,
        ),
      );
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onProducts;
  final VoidCallback onMovements;
  final VoidCallback onReports;
  const _QuickActions(
      {required this.onProducts,
      required this.onMovements,
      required this.onReports});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('إجراءات سريعة',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                      onPressed: onProducts,
                      icon: const Icon(Icons.add_box_outlined),
                      label: const Text('إدارة المنتجات')),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                      onPressed: onMovements,
                      icon: const Icon(Icons.move_down),
                      label: const Text('تسجيل حركة')),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                      onPressed: onReports,
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('فتح التقارير')),
                ])),
      );
}

class _RecentMovements extends StatelessWidget {
  final List movements;
  const _RecentMovements({required this.movements});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('آخر الحركات',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (movements.isEmpty)
                const Text('لا توجد حركات مسجلة بعد',
                    style: TextStyle(color: AppTheme.mutedTextColor)),
              ...movements.take(5).map((movement) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                        movement.type == 'وارد'
                            ? Icons.south_west
                            : Icons.north_east,
                        color: movement.type == 'وارد'
                            ? AppTheme.cyanColor
                            : AppTheme.warningColor),
                    title: Text(movement.productName),
                    subtitle: Text(movement.type,
                        style: const TextStyle(color: AppTheme.mutedTextColor)),
                    trailing: Text(movement.quantityText,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
            ])),
      );
}
