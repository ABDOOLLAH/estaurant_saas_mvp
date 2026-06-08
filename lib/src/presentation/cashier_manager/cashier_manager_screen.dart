import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kTenantId = 'demo_tenant';
const kBranchId = 'demo_branch';
const kCurrency = '₺';

enum ManagerPage {
  dashboard,
  cashier,
  tables,
  orders,
  kitchen,
  products,
  modifiers,
  inventory,
  purchases,
  suppliers,
  expenses,
  shift,
  reports,
  settings,
  logs,
}

class CashierManagerScreen extends StatefulWidget {
  const CashierManagerScreen({super.key});

  @override
  State<CashierManagerScreen> createState() => _CashierManagerScreenState();
}

class _CashierManagerScreenState extends State<CashierManagerScreen> {
  final db = FirebaseFirestore.instance;
  ManagerPage page = ManagerPage.cashier;

  CollectionReference<Map<String, dynamic>> get tenant =>
      db.collection('tenants');

  DocumentReference<Map<String, dynamic>> get tenantDoc =>
      tenant.doc(kTenantId);

  CollectionReference<Map<String, dynamic>> get categories =>
      tenantDoc.collection('categories');

  CollectionReference<Map<String, dynamic>> get products =>
      tenantDoc.collection('menu_items');

  CollectionReference<Map<String, dynamic>> get modifiers =>
      tenantDoc.collection('modifiers');

  CollectionReference<Map<String, dynamic>> get tables =>
      tenantDoc.collection('branches').doc(kBranchId).collection('tables');

  CollectionReference<Map<String, dynamic>> get orders =>
      db.collection('orders');

  CollectionReference<Map<String, dynamic>> get expenses =>
      tenantDoc.collection('expenses');

  CollectionReference<Map<String, dynamic>> get inventory =>
      tenantDoc.collection('inventory_items');

  CollectionReference<Map<String, dynamic>> get purchases =>
      tenantDoc.collection('purchases');

  CollectionReference<Map<String, dynamic>> get suppliers =>
      tenantDoc.collection('suppliers');

  CollectionReference<Map<String, dynamic>> get shifts =>
      tenantDoc.collection('cash_sessions');

  CollectionReference<Map<String, dynamic>> get logs =>
      tenantDoc.collection('activity_logs');

  Future<void> logAction(String action, [Map<String, dynamic>? details]) async {
    final user = FirebaseAuth.instance.currentUser;
    await logs.add({
      'action': action,
      'details': details ?? {},
      'userId': user?.uid,
      'userEmail': user?.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> seedDemoData() async {
    final batch = db.batch();
    batch.set(tenantDoc, {
      'id': kTenantId,
      'name': 'مطعم تجريبي',
      'currency': 'TRY',
      'settings': {'currency': 'TRY', 'taxRate': 0.0},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(tenantDoc.collection('branches').doc(kBranchId), {
      'id': kBranchId,
      'name': 'الفرع الرئيسي',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final cats = [
      ['meals', 'وجبات', 1],
      ['drinks', 'مشروبات', 2],
      ['desserts', 'حلويات', 3],
      ['extras', 'إضافات', 4],
    ];
    for (final c in cats) {
      batch.set(categories.doc(c[0] as String), {
        'id': c[0],
        'tenantId': kTenantId,
        'name': c[1],
        'displayOrder': c[2],
        'isVisible': true
      }, SetOptions(merge: true));
    }
    final items = [
      ['shawarma_chicken', 'شاورما دجاج', 'meals', 120.0],
      ['burger', 'برغر كلاسيك', 'meals', 150.0],
      ['fries', 'بطاطا', 'extras', 50.0],
      ['cola', 'كولا', 'drinks', 30.0],
      ['kunafa', 'كنافة', 'desserts', 90.0],
    ];
    for (final i in items) {
      batch.set(products.doc(i[0] as String), {
        'id': i[0],
        'tenantId': kTenantId,
        'name': i[1],
        'description': 'صنف تجريبي يمكن تعديله من صفحة المنتجات',
        'categoryId': i[2],
        'price': i[3],
        'isAvailable': true,
        'isSoldOut': false,
        'isVisible': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    for (int n = 1; n <= 8; n++) {
      final id = 'table_$n';
      batch.set(tables.doc(id), {
        'id': id,
        'tenantId': kTenantId,
        'branchId': kBranchId,
        'number': '$n',
        'status': 'available',
        'isActive': true,
        'qrCodeUrl': _qrUrl(id),
        'lastStatusUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    batch.set(inventory.doc('chicken'), {
      'id': 'chicken',
      'name': 'دجاج',
      'unit': 'كغ',
      'quantity': 10.0,
      'minQuantity': 3.0,
      'lastPurchasePrice': 80.0,
      'status': 'active'
    }, SetOptions(merge: true));
    batch.set(suppliers.doc('supplier_1'), {
      'id': 'supplier_1',
      'name': 'مورد تجريبي',
      'phone': '',
      'address': '',
      'notes': ''
    }, SetOptions(merge: true));
    await batch.commit();
    await logAction('seed_demo_data');
    if (mounted) _toast('تم تجهيز بيانات تجريبية');
  }

  String _qrUrl(String tableId) {
    final base = Uri.base.origin;
    return '$base/#/menu/$kTenantId/$kBranchId/$tableId';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final title = _pageTitle(page);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton.icon(onPressed: seedDemoData,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('تجهيز بيانات تجريبية')),
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج'),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: ManagerPage.values.indexOf(page),
            extended: MediaQuery
                .of(context)
                .size
                .width > 1150,
            onDestinationSelected: (i) =>
                setState(() => page = ManagerPage.values[i]),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.dashboard), label: Text('لوحة التحكم')),
              NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale), label: Text('الكاشير')),
              NavigationRailDestination(
                  icon: Icon(Icons.table_restaurant), label: Text('الطاولات')),
              NavigationRailDestination(
                  icon: Icon(Icons.receipt_long), label: Text('الطلبات')),
              NavigationRailDestination(
                  icon: Icon(Icons.kitchen), label: Text('المطبخ')),
              NavigationRailDestination(
                  icon: Icon(Icons.fastfood), label: Text('المنتجات')),
              NavigationRailDestination(
                  icon: Icon(Icons.tune), label: Text('الإضافات')),
              NavigationRailDestination(
                  icon: Icon(Icons.inventory), label: Text('المخزون')),
              NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart), label: Text('المشتريات')),
              NavigationRailDestination(
                  icon: Icon(Icons.local_shipping), label: Text('الموردين')),
              NavigationRailDestination(
                  icon: Icon(Icons.money_off), label: Text('المصاريف')),
              NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet),
                  label: Text('الوردية')),
              NavigationRailDestination(
                  icon: Icon(Icons.analytics), label: Text('التقارير')),
              NavigationRailDestination(
                  icon: Icon(Icons.settings), label: Text('الإعدادات')),
              NavigationRailDestination(
                  icon: Icon(Icons.history), label: Text('السجل')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _page()),
        ],
      ),
    );
  }

  String _pageTitle(ManagerPage p) =>
      switch (p) {
        ManagerPage.dashboard => 'لوحة التحكم',
        ManagerPage.cashier => 'الكاشير / المدير',
        ManagerPage.tables => 'إدارة الطاولات و QR',
        ManagerPage.orders => 'إدارة الطلبات',
        ManagerPage.kitchen => 'طلبات المطبخ',
        ManagerPage.products => 'المنتجات والمنيو',
        ManagerPage.modifiers => 'الإضافات',
        ManagerPage.inventory => 'المخزون البسيط',
        ManagerPage.purchases => 'المشتريات',
        ManagerPage.suppliers => 'الموردين',
        ManagerPage.expenses => 'المصاريف',
        ManagerPage.shift => 'الصندوق والوردية',
        ManagerPage.reports => 'التقارير',
        ManagerPage.settings => 'الإعدادات',
        ManagerPage.logs => 'سجل العمليات',
      };

  Widget _page() =>
      switch (page) {
        ManagerPage.dashboard => DashboardPage(parent: this),
        ManagerPage.cashier => PosPage(parent: this),
        ManagerPage.tables => TablesPage(parent: this),
        ManagerPage.orders => OrdersPage(parent: this),
        ManagerPage.kitchen => KitchenPage(parent: this),
        ManagerPage.products => ProductsPage(parent: this),
        ManagerPage.modifiers =>
            SimpleCollectionPage(parent: this,
                title: 'الإضافات',
                collection: modifiers,
                fields: const ['name', 'extraPrice', 'productId', 'status']),
        ManagerPage.inventory => InventoryPage(parent: this),
        ManagerPage.purchases => PurchasesPage(parent: this),
        ManagerPage.suppliers =>
            SimpleCollectionPage(parent: this,
                title: 'الموردين',
                collection: suppliers,
                fields: const ['name', 'phone', 'address', 'notes']),
        ManagerPage.expenses => ExpensesPage(parent: this),
        ManagerPage.shift => ShiftPage(parent: this),
        ManagerPage.reports => ReportsPage(parent: this),
        ManagerPage.settings => SettingsPage(parent: this),
        ManagerPage.logs => LogsPage(parent: this),
      };
}

class DashboardPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const DashboardPage({required this.parent});

  @override
  Widget build(BuildContext context) {
    final todayStart = DateTime(DateTime
        .now()
        .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: parent.orders
          .where('tenantId', isEqualTo: kTenantId)
          .where(
          'createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .snapshots(),
      builder: (context, ordersSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: parent.expenses
              .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
              .snapshots(),
          builder: (context, expensesSnap) {
            final orders = ordersSnap.data?.docs
                .map((d) => d.data())
                .toList() ?? [];
            final expenses = expensesSnap.data?.docs
                .map((d) => d.data())
                .toList() ?? [];
            final paid = orders.where((o) =>
            o['status'] == 'paid' || o['isPaid'] == true).toList();
            final sales = paid.fold<double>(
                0, (s, o) => s + _num(o['totalAmount'] ?? o['total']));
            final cash = paid.where((o) =>
                (o['paymentMethod'] ?? '').toString().toLowerCase().contains(
                    'cash')).fold<double>(
                0, (s, o) => s + _num(o['totalAmount']));
            final card = paid.where((o) =>
                (o['paymentMethod'] ?? '').toString().toLowerCase().contains(
                    'card')).fold<double>(
                0, (s, o) => s + _num(o['totalAmount']));
            final exp = expenses.fold<double>(
                0, (s, e) => s + _num(e['amount']));
            final open = orders
                .where((o) =>
            !['paid', 'cancelled', 'refunded'].contains(o['status']))
                .length;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Wrap(spacing: 14, runSpacing: 14, children: [
                  StatCard('مبيعات اليوم', _money(sales), Icons.payments),
                  StatCard(
                      'عدد الطلبات', '${orders.length}', Icons.receipt_long),
                  StatCard('إجمالي الكاش', _money(cash), Icons.money),
                  StatCard('إجمالي البطاقة', _money(card), Icons.credit_card),
                  StatCard('المصاريف اليومية', _money(exp), Icons.money_off),
                  StatCard('صافي الصندوق', _money(cash - exp),
                      Icons.account_balance_wallet),
                  StatCard('طلبات مفتوحة', '$open', Icons.timelapse),
                ]),
                const SizedBox(height: 22),
                FilledButton.icon(onPressed: () =>
                    parent.setState(() => parent.page = ManagerPage.cashier),
                    icon: const Icon(Icons.point_of_sale),
                    label: const Text('فتح شاشة الكاشير')),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: () =>
                    parent.setState(() => parent.page = ManagerPage.reports),
                    icon: const Icon(Icons.analytics),
                    label: const Text('عرض تقرير اليوم')),
              ],
            );
          },
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard(this.title, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey)),
                  Text(value, style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900))
                ])),
          ]),
        ),
      ),
    );
  }
}

class PosPage extends StatefulWidget {
  final _CashierManagerScreenState parent;

  const PosPage({required this.parent, super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  String? selectedCategory;
  String orderType = 'dine-in';
  String? tableId;
  String? tableNumber;
  final notes = TextEditingController();
  final discount = TextEditingController(text: '0');
  final List<Map<String, dynamic>> cart = [];

  @override
  void dispose() {
    notes.dispose();
    discount.dispose();
    super.dispose();
  }

  void addItem(Map<String, dynamic> item) {
    final index = cart.indexWhere((e) =>
    e['productId'] == item['id'] && (e['notes'] ?? '') == '');
    setState(() {
      if (index >= 0) {
        cart[index]['quantity'] = (cart[index]['quantity'] as int) + 1;
      } else {
        cart.add({
          'productId': item['id'],
          'productName': item['name'],
          'quantity': 1,
          'unitPrice': _num(item['price']),
          'notes': null
        });
      }
    });
  }

  double get subtotal =>
      cart.fold(0, (s, i) => s + _num(i['unitPrice']) * (i['quantity'] as int));

  double get discountValue => _num(discount.text);

  double get total => max(0, subtotal - discountValue);

  Future<void> sendToKitchen({String status = 'pending'}) async {
    if (cart.isEmpty) return widget.parent._toast('السلة فارغة');
    if (orderType == 'dine-in' && tableId == null)
      return widget.parent._toast('اختر طاولة أولًا');
    final ref = widget.parent.orders.doc();
    final data = {
      'id': ref.id,
      'tenantId': kTenantId,
      'branchId': kBranchId,
      'source': 'cashier',
      'customerId': FirebaseAuth.instance.currentUser?.uid ?? 'cashier',
      'orderType': orderType,
      'tableId': tableId,
      'tableNumber': tableNumber != null ? int.tryParse(tableNumber!) ??
          tableNumber : null,
      'items': cart.map((e) =>
      {
        ...e,
        'lineTotal': _num(e['unitPrice']) * (e['quantity'] as int)
      }).toList(),
      'subtotal': subtotal,
      'discount': discountValue,
      'totalAmount': total,
      'total': total,
      'status': status,
      'paymentStatus': 'unpaid',
      'isPaid': false,
      'notes': notes.text.trim(),
      'createdBy': FirebaseAuth.instance.currentUser?.email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'orderNumber': 'ORD-${DateTime
          .now()
          .millisecondsSinceEpoch}',
    };
    final batch = FirebaseFirestore.instance.batch();
    batch.set(ref, data);
    if (tableId != null) {
      batch.set(widget.parent.tables.doc(tableId), {
        'status': 'occupied',
        'activeOrderId': ref.id,
        'isOccupied': true,
        'lastStatusUpdate': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }
    await batch.commit();
    await widget.parent.logAction(
        'create_order', {'orderId': ref.id, 'total': total});
    setState(() {
      cart.clear();
      notes.clear();
      discount.text = '0';
    });
    widget.parent._toast('تم إرسال الطلب للمطبخ');
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 250, child: _categories()),
      const VerticalDivider(width: 1),
      Expanded(flex: 2, child: _products()),
      const VerticalDivider(width: 1),
      SizedBox(width: 390, child: _ticket()),
    ]);
  }

  Widget _categories() =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.parent.categories.orderBy('displayOrder').snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(padding: const EdgeInsets.all(12), children: [
            ChoiceChip(label: const Text('الكل'),
                selected: selectedCategory == null,
                onSelected: (_) => setState(() => selectedCategory = null)),
            const SizedBox(height: 8),
            ...docs.map((d) =>
                Padding(padding: const EdgeInsets.only(bottom: 8),
                    child: ChoiceChip(label: Text(d.data()['name'] ?? d.id),
                        selected: selectedCategory == d.id,
                        onSelected: (_) =>
                            setState(() => selectedCategory = d.id)))),
          ]);
        },
      );

  Widget _products() =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.parent.products.snapshots(),
        builder: (context, snap) {
          final all = snap.data?.docs
              .map((d) => {...d.data(), 'id': d.id})
              .where((p) =>
          p['isVisible'] != false && p['isAvailable'] != false &&
              p['isSoldOut'] != true)
              .toList() ?? [];
          final items = selectedCategory == null ? all : all.where((
              p) => p['categoryId'] == selectedCategory).toList();
          if (items.isEmpty) return const Center(child: Text(
              'لا توجد منتجات متاحة. أضف منتجات من صفحة المنتجات.'));
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 1.05,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12),
            itemCount: items.length,
            itemBuilder: (_, i) =>
                Card(
                  child: InkWell(
                    onTap: () => addItem(items[i]),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fastfood, size: 34,
                                color: Color(0xFFB45309)),
                            const SizedBox(height: 8),
                            Text(items[i]['name'] ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(_money(_num(items[i]['price'])),
                                style: const TextStyle(color: Color(0xFFB45309),
                                    fontWeight: FontWeight.bold)),
                          ]),
                    ),
                  ),
                ),
          );
        },
      );

  Widget _ticket() =>
      ListView(padding: const EdgeInsets.all(16), children: [
        const Text('الفاتورة الحالية',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        SegmentedButton<String>(segments: const [
          ButtonSegment(value: 'dine-in', label: Text('داخل')),
          ButtonSegment(value: 'takeaway', label: Text('سفري')),
          ButtonSegment(value: 'delivery', label: Text('توصيل')),
          ButtonSegment(value: 'pickup', label: Text('استلام'))
        ],
            selected: {orderType},
            onSelectionChanged: (s) => setState(() => orderType = s.first)),
        if (orderType == 'dine-in') ...[
          const SizedBox(height: 12),
          _tablePicker()
        ],
        const Divider(height: 24),
        if (cart.isEmpty) const Center(child: Padding(
            padding: EdgeInsets.all(24), child: Text('السلة فارغة'))),
        ...cart
            .asMap()
            .entries
            .map((e) =>
            ListTile(
              title: Text(e.value['productName']),
              subtitle: Text(_money(_num(e.value['unitPrice']))),
              leading: Text('${e.value['quantity']}x'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    onPressed: () => setState(() => e.value['quantity']++),
                    icon: const Icon(Icons.add)),
                IconButton(onPressed: () =>
                    setState(() =>
                    e.value['quantity'] > 1 ? e.value['quantity']-- : cart
                        .removeAt(e.key)),
                    icon: const Icon(Icons.remove)),
              ]),
            )),
        TextField(controller: notes,
            decoration: const InputDecoration(labelText: 'ملاحظة الطلب')),
        const SizedBox(height: 8),
        TextField(controller: discount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'خصم مبلغ ثابت')),
        const Divider(height: 24),
        _row('المجموع', _money(subtotal)),
        _row('الخصم', _money(discountValue)),
        _row('الإجمالي النهائي', _money(total), bold: true),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () => sendToKitchen(status: 'pending'),
            icon: const Icon(Icons.kitchen),
            label: const Text('إرسال للمطبخ')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => setState(() => cart.clear()),
            icon: const Icon(Icons.delete_outline),
            label: const Text('إلغاء الطلب')),
      ]);

  Widget _tablePicker() =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.parent.tables
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          return DropdownButtonFormField<String>(
            value: tableId,
            decoration: const InputDecoration(labelText: 'اختيار طاولة'),
            items: docs.map((d) =>
                DropdownMenuItem(value: d.id,
                    child: Text('طاولة ${d.data()['number'] ?? d.id} - ${d
                        .data()['status'] ?? ''}'))).toList(),
            onChanged: (v) =>
                setState(() {
                  tableId = v;
                  final doc = docs.firstWhere((d) => d.id == v);
                  tableNumber = '${doc.data()['number'] ?? doc.id}';
                }),
          );
        },
      );

  Widget _row(String a, String b, {bool bold = false}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Text(a, style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.normal)),
            const Spacer(),
            Text(b, style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.bold))
          ]));
}

class TablesPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const TablesPage({required this.parent});

  Future<void> addTable(BuildContext context) async {
    final number = await _ask(context, 'رقم الطاولة');
    if (number == null || number.isEmpty) return;
    final id = 'table_${number.replaceAll(RegExp(r'\s+'), '_')}';
    await parent.tables.doc(id).set({
      'id': id,
      'tenantId': kTenantId,
      'branchId': kBranchId,
      'number': number,
      'status': 'available',
      'isActive': true,
      'qrCodeUrl': parent._qrUrl(id),
      'lastStatusUpdate': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
    await parent.logAction('upsert_table', {'tableId': id});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(12),
          child: Row(children: [
            FilledButton.icon(onPressed: () => addTable(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة طاولة'))
          ])),
      Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: parent.tables.snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text(
              'لا توجد طاولات. اضغط إضافة أو تجهيز بيانات تجريبية.'));
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data();
              final active = data['isActive'] != false;
              final qr = data['qrCodeUrl'] ?? parent._qrUrl(d.id);
              return Card(child: Padding(padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('طاولة ${data['number'] ?? d.id}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      _statusChip('${data['status'] ?? ''}')
                    ]),
                    const SizedBox(height: 8),
                    SelectableText(qr, maxLines: 2),
                    const Spacer(),
                    Wrap(spacing: 6, children: [
                      IconButton(onPressed: () {
                        Clipboard.setData(ClipboardData(text: qr));
                        parent._toast('تم نسخ رابط QR');
                      }, icon: const Icon(Icons.copy)),
                      IconButton(onPressed: () =>
                          parent.tables.doc(d.id).set({
                            'isActive': !active,
                            'status': active ? 'cancelled' : 'available'
                          }, SetOptions(merge: true)),
                          icon: Icon(
                              active ? Icons.pause_circle : Icons.play_circle)),
                      IconButton(onPressed: () =>
                          parent.tables.doc(d.id).set({
                            'status': 'available',
                            'activeOrderId': null,
                            'isOccupied': false
                          }, SetOptions(merge: true)),
                          icon: const Icon(Icons.cleaning_services)),
                      IconButton(onPressed: () =>
                          parent.tables.doc(d.id).set({
                            'deleted': true,
                            'isActive': false,
                            'status': 'cancelled'
                          }, SetOptions(merge: true)),
                          icon: const Icon(
                              Icons.delete_outline, color: Colors.red)),
                    ])
                  ])));
            },
          );
        },
      )),
    ]);
  }
}

class OrdersPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const OrdersPage({required this.parent});

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: parent.orders.where('tenantId', isEqualTo: kTenantId).orderBy(
            'createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView.separated(padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => OrderCard(parent: parent, doc: docs[i]));
        },
      );
}

class OrderCard extends StatelessWidget {
  final _CashierManagerScreenState parent;
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  const OrderCard({required this.parent, required this.doc, super.key});

  @override
  Widget build(BuildContext context) {
    final d = doc.data();
    final items = (d['items'] as List?) ?? [];
    return Card(child: ExpansionTile(
      title: Row(children: [
        Text('${d['orderNumber'] ?? doc.id}',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(width: 8),
        _statusChip('${d['status'] ?? ''}'),
        if (d['tableNumber'] != null) Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('طاولة ${d['tableNumber']}'))
      ]),
      subtitle: Text('${_money(
          _num(d['totalAmount'] ?? d['total']))} • ${d['paymentMethod'] ??
          'غير مدفوع'}'),
      children: [
        ...items.map((e) =>
            ListTile(title: Text('${e['quantity']}x ${e['productName']}'),
                subtitle: e['notes'] == null ? null : Text('${e['notes']}'),
                trailing: Text(_money(_num(e['lineTotal'] ??
                    (_num(e['unitPrice']) * _num(e['quantity']))))))),
        Wrap(spacing: 8, children: [
          OutlinedButton(onPressed: () => _setStatus('preparing'),
              child: const Text('قيد التحضير')),
          OutlinedButton(
              onPressed: () => _setStatus('ready'), child: const Text('جاهز')),
          FilledButton(onPressed: () => _pay(context, 'cash'),
              child: const Text('دفع كاش')),
          FilledButton(onPressed: () => _pay(context, 'card'),
              child: const Text('دفع بطاقة')),
          TextButton(onPressed: () => _setStatus('cancelled'),
              child: const Text('إلغاء', style: TextStyle(color: Colors.red))),
        ]),
        const SizedBox(height: 10),
      ],
    ));
  }

  Future<void> _setStatus(String status) async {
    final d = doc.data();
    final batch = FirebaseFirestore.instance.batch();
    batch.set(doc.reference, {
      'status': status,
      'orderStatus': status,
      'updatedAt': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
    if (d['tableId'] != null) {
      batch.set(parent.tables.doc('${d['tableId']}'), {
        'status': status == 'ready' ? 'orderReady' : (status == 'cancelled'
            ? 'available'
            : 'occupied'),
        'lastStatusUpdate': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }
    await batch.commit();
    await parent.logAction(
        'update_order_status', {'orderId': doc.id, 'status': status});
  }

  Future<void> _pay(BuildContext context, String method) async {
    final d = doc.data();
    final batch = FirebaseFirestore.instance.batch();
    batch.set(doc.reference, {
      'status': 'paid',
      'paymentStatus': 'paid',
      'isPaid': true,
      'paymentMethod': method,
      'paidAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
    if (d['tableId'] != null) {
      batch.set(parent.tables.doc('${d['tableId']}'), {
        'status': method == 'cash' ? 'paidCash' : 'paidCard',
        'paymentStatus': 'paid',
        'activeOrderId': null,
        'isOccupied': false,
        'lastStatusUpdate': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }
    await batch.commit();
    await parent.logAction('payment',
        {'orderId': doc.id, 'method': method, 'amount': d['totalAmount']});
  }
}

class KitchenPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const KitchenPage({required this.parent});

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: parent.orders.where('tenantId', isEqualTo: kTenantId).where(
            'status', whereIn: ['pending', 'preparing', 'ready']).snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          return Row(children: ['pending', 'preparing', 'ready']
              .map((s) =>
              Expanded(child: _lane(context, s,
                  docs.where((d) => d.data()['status'] == s).toList())))
              .toList());
        },
      );

  Widget _lane(BuildContext context, String status,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) =>
      Container(
        color: status == 'pending' ? Colors.orange.shade50 : status ==
            'preparing' ? Colors.blue.shade50 : Colors.green.shade50,
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(12),
              child: Text(_statusAr(status), style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900))),
          Expanded(child: ListView(
              children: docs
                  .map((d) => OrderCard(parent: parent, doc: d))
                  .toList()))
        ]),
      );
}

class ProductsPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const ProductsPage({required this.parent});

  Future<void> addOrEdit(BuildContext context,
      [QueryDocumentSnapshot<Map<String, dynamic>>? doc]) async {
    final data = doc?.data() ?? {};
    final name = TextEditingController(text: data['name'] ?? '');
    final desc = TextEditingController(text: data['description'] ?? '');
    final price = TextEditingController(text: '${data['price'] ?? ''}');
    String categoryId = data['categoryId'] ?? '';
    final ok = await showDialog<bool>(context: context, builder: (_) =>
        AlertDialog(title: Text(doc == null ? 'إضافة منتج' : 'تعديل منتج'),
            content: SizedBox(width: 420,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(controller: name,
                      decoration: const InputDecoration(
                          labelText: 'اسم المنتج')),
                  TextField(controller: desc,
                      decoration: const InputDecoration(labelText: 'الوصف')),
                  TextField(controller: price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السعر')),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: parent.categories.snapshots(),
                      builder: (context, snap) {
                        final cats = snap.data?.docs ?? [];
                        if (cats.isNotEmpty && categoryId.isEmpty)
                          categoryId = cats.first.id;
                        return DropdownButtonFormField<String>(
                            value: categoryId.isEmpty ? null : categoryId,
                            items: cats
                                .map((c) =>
                                DropdownMenuItem(value: c.id,
                                    child: Text(c.data()['name'] ?? c.id)))
                                .toList(),
                            onChanged: (v) => categoryId = v ?? '',
                            decoration: const InputDecoration(
                                labelText: 'التصنيف'));
                      }),
                ])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء')),
              FilledButton(onPressed: () => Navigator.pop(context, true),
                  child: const Text('حفظ'))
            ]));
    if (ok == true && name.text
        .trim()
        .isNotEmpty) {
      final ref = doc?.reference ?? parent.products.doc();
      await ref.set({
        'id': ref.id,
        'tenantId': kTenantId,
        'name': name.text.trim(),
        'description': desc.text.trim(),
        'price': _num(price.text),
        'categoryId': categoryId,
        'isAvailable': true,
        'isSoldOut': false,
        'isVisible': true,
        'updatedAt': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      await parent.logAction('upsert_product', {'productId': ref.id});
    }
  }

  Future<void> addCategory(BuildContext context) async {
    final name = await _ask(context, 'اسم التصنيف');
    if (name == null || name.isEmpty) return;
    final ref = parent.categories.doc();
    await ref.set({
      'id': ref.id,
      'tenantId': kTenantId,
      'name': name,
      'displayOrder': DateTime
          .now()
          .millisecondsSinceEpoch,
      'isVisible': true
    });
  }

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Padding(padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 8,
                children: [
                  FilledButton.icon(onPressed: () => addOrEdit(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة منتج')),
                  OutlinedButton.icon(onPressed: () => addCategory(context),
                      icon: const Icon(Icons.category),
                      label: const Text('إضافة تصنيف'))
                ])),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: parent.products.snapshots(), builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView.separated(padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = docs[i];
                final x = d.data();
                return Card(child: ListTile(title: Text(x['name'] ?? ''),
                    subtitle: Text('${_money(_num(
                        x['price']))} • ${x['isAvailable'] == false
                        ? 'مجمّد'
                        : 'متاح'} • ${x['isVisible'] == false
                        ? 'مخفي'
                        : 'ظاهر'}'),
                    leading: const Icon(Icons.fastfood),
                    trailing: Wrap(children: [
                      Switch(value: x['isAvailable'] != false, onChanged: (v) =>
                          d.reference.set({'isAvailable': v, 'isSoldOut': !v},
                              SetOptions(merge: true))),
                      IconButton(onPressed: () => addOrEdit(context, d),
                          icon: const Icon(Icons.edit)),
                      IconButton(onPressed: () =>
                          d.reference.set(
                              {'isVisible': false, 'isAvailable': false},
                              SetOptions(merge: true)), icon: const Icon(
                          Icons.delete_outline, color: Colors.red))
                    ])));
                });
          }))
      ]);
}

class ExpensesPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const ExpensesPage({required this.parent});

  Future<void> add(BuildContext context) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(context: context,
        builder: (_) =>
            AlertDialog(title: const Text('إضافة مصروف'),
                content: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: title,
                          decoration: const InputDecoration(
                              labelText: 'نوع المصروف')),
                      TextField(controller: amount,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'المبلغ')),
                      TextField(controller: note,
                          decoration: const InputDecoration(
                              labelText: 'ملاحظة'))
                    ]),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء')),
                  FilledButton(onPressed: () => Navigator.pop(context, true),
                      child: const Text('حفظ'))
                ]));
    if (ok == true) {
      await parent.expenses.add({
        'title': title.text,
        'category': title.text,
        'amount': _num(amount.text),
        'note': note.text,
        'paymentMethod': 'cash',
        'createdBy': FirebaseAuth.instance.currentUser?.email,
        'createdAt': FieldValue.serverTimestamp()
      });
      await parent.logAction('add_expense', {'amount': _num(amount.text)});
    }
  }

  @override
  Widget build(BuildContext context) =>
      _moneyCollection(parent: parent,
          title: 'المصاريف',
          collection: parent.expenses,
          onAdd: () => add(context));
}

class InventoryPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const InventoryPage({required this.parent});

  @override
  Widget build(BuildContext context) =>
      SimpleCollectionPage(parent: parent,
          title: 'المخزون',
          collection: parent.inventory,
          fields: const [
            'name',
            'unit',
            'quantity',
            'minQuantity',
            'lastPurchasePrice',
            'status'
          ]);
}

class PurchasesPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const PurchasesPage({required this.parent});

  @override
  Widget build(BuildContext context) =>
      SimpleCollectionPage(parent: parent,
          title: 'المشتريات',
          collection: parent.purchases,
          fields: const [
            'supplierName',
            'inventoryItem',
            'quantity',
            'unitPrice',
            'total',
            'paymentMethod'
          ]);
}

class ShiftPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const ShiftPage({required this.parent});

  Future<void> open(BuildContext context) async {
    final amount = await _ask(context, 'رصيد بداية الصندوق');
    if (amount == null) return;
    await parent.shifts.add({
      'openingBalance': _num(amount),
      'status': 'open',
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'openedAt': FieldValue.serverTimestamp()
    });
    await parent.logAction('open_shift', {'openingBalance': _num(amount)});
  }

  Future<void> close(BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final amount = await _ask(context, 'المبلغ الفعلي في الصندوق');
    if (amount == null) return;
    await doc.reference.set({
      'actualCash': _num(amount),
      'status': 'closed',
      'closedAt': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
    await parent.logAction(
        'close_shift', {'shiftId': doc.id, 'actualCash': _num(amount)});
  }

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Padding(padding: const EdgeInsets.all(12),
            child: FilledButton.icon(onPressed: () => open(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('فتح وردية'))),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: parent.shifts
                .orderBy('openedAt', descending: true)
                .snapshots(), builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(children: docs.map((d) {
            final x = d.data();
            return Card(child: ListTile(title: Text('وردية ${x['status'] ??
                ''}'),
                subtitle: Text('رصيد البداية: ${_money(
                    _num(x['openingBalance']))} | فعلي: ${_money(
                    _num(x['actualCash']))}'),
                trailing: x['status'] == 'open' ? FilledButton(onPressed: () =>
                    close(context, d), child: const Text('إغلاق')) : null));
          }).toList());
        }))
      ]);
}

class ReportsPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const ReportsPage({required this.parent});

  @override
  Widget build(BuildContext context) => DashboardPage(parent: parent);
}

class SettingsPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const SettingsPage({required this.parent});

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: parent.tenantDoc.snapshots(), builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        return ListView(padding: const EdgeInsets.all(16), children: [
          Card(child: ListTile(title: const Text('اسم المطعم'),
              subtitle: Text('${data['name'] ?? 'مطعم تجريبي'}'),
              trailing: IconButton(
                  icon: const Icon(Icons.edit), onPressed: () async {
                final v = await _ask(context, 'اسم المطعم');
                if (v != null) parent.tenantDoc.set(
                    {'name': v}, SetOptions(merge: true));
              }))),
          Card(child: ListTile(
              title: const Text('العملة'), subtitle: const Text('TRY / ₺'))),
          const Card(child: ListTile(title: Text('إعدادات الطباعة'),
              subtitle: Text(
                  'MVP: الطباعة من المتصفح Ctrl+P أو زر Print لاحقًا'))),
        ]);
        });
}

class LogsPage extends StatelessWidget {
  final _CashierManagerScreenState parent;

  const LogsPage({required this.parent});

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: parent.logs
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots(), builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        return ListView.separated(padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final x = docs[i].data();
              return ListTile(leading: const Icon(Icons.history),
                  title: Text('${x['action']}'),
                  subtitle: Text(
                      '${x['userEmail'] ?? x['userId'] ?? ''}\n${x['details'] ??
                          {}}'));
            });
      });
}

class SimpleCollectionPage extends StatelessWidget {
  final _CashierManagerScreenState parent;
  final String title;
  final CollectionReference<Map<String, dynamic>> collection;
  final List<String> fields;

  const SimpleCollectionPage(
      {required this.parent, required this.title, required this.collection, required this.fields, super.key});

  Future<void> addOrEdit(BuildContext context,
      [QueryDocumentSnapshot<Map<String, dynamic>>? doc]) async {
    final data = doc?.data() ?? {};
    final controllers = {
      for (final f in fields) f: TextEditingController(text: '${data[f] ?? ''}')
    };
    final ok = await showDialog<bool>(context: context,
        builder: (_) =>
            AlertDialog(
                title: Text(doc == null ? 'إضافة $title' : 'تعديل $title'),
                content: SizedBox(width: 420,
                    child: ListView(shrinkWrap: true,
                        children: fields
                            .map((f) =>
                            Padding(padding: const EdgeInsets.only(bottom: 8),
                                child: TextField(controller: controllers[f],
                                    decoration: InputDecoration(labelText: f))))
                            .toList())),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء')),
                  FilledButton(onPressed: () => Navigator.pop(context, true),
                      child: const Text('حفظ'))
                ]));
    if (ok == true) {
      final ref = doc?.reference ?? collection.doc();
      final payload = <String, dynamic>{
        'id': ref.id,
        'tenantId': kTenantId,
        'updatedAt': FieldValue.serverTimestamp()
      };
      for (final f in fields) {
        final text = controllers[f]!.text.trim();
        payload[f] = double.tryParse(text) ?? text;
      }
      await ref.set(payload, SetOptions(merge: true));
      await parent.logAction('upsert_$title', {'id': ref.id});
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Padding(padding: const EdgeInsets.all(12),
            child: FilledButton.icon(onPressed: () => addOrEdit(context),
                icon: const Icon(Icons.add),
                label: Text('إضافة $title'))),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: collection.snapshots(), builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView.separated(padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = docs[i];
                final x = d.data();
                return Card(child: ListTile(
                    title: Text('${x['name'] ?? x['title'] ?? d.id}'),
                    subtitle: Text(fields.map((f) => '$f: ${x[f] ?? ''}').join(
                        '  |  ')),
                    trailing: Wrap(children: [
                      IconButton(onPressed: () => addOrEdit(context, d),
                          icon: const Icon(Icons.edit)),
                      IconButton(onPressed: () =>
                          d.reference.set(
                              {'status': 'inactive', 'deleted': true},
                              SetOptions(merge: true)), icon: const Icon(
                          Icons.delete_outline, color: Colors.red))
                    ])));
              });
        }))
      ]);
}

Widget _moneyCollection(
    {required _CashierManagerScreenState parent, required String title, required CollectionReference<
        Map<String, dynamic>> collection, required VoidCallback onAdd}) =>
    Column(children: [
      Padding(padding: const EdgeInsets.all(12),
          child: FilledButton.icon(onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text('إضافة $title'))),
      Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: collection.orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];
            return ListView.separated(padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final x = docs[i].data();
                  return Card(child: ListTile(title: Text(
                      '${x['title'] ?? x['category'] ?? docs[i].id}'),
                      subtitle: Text('${x['note'] ?? ''}'),
                      trailing: Text(_money(_num(x['amount'])))));
                });
          }))
    ]);

Future<String?> _ask(BuildContext context, String title) async {
  final c = TextEditingController();
  final res = await showDialog<String>(context: context,
      builder: (_) =>
          AlertDialog(title: Text(title),
              content: TextField(controller: c, autofocus: true),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, c.text.trim()),
                    child: const Text('حفظ'))
              ]));
  return res;
}

double _num(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? 0}'.replaceAll(',', '.')) ?? 0.0;
}

String _money(double v) => '${v.toStringAsFixed(2)} $kCurrency';

String _statusAr(String s) =>
    switch (s) {
      'pending' => 'جديد', 'preparing' => 'قيد التحضير', 'ready' => 'جاهز', 'paid' => 'مدفوع', 'cancelled' => 'ملغي', 'occupied' => 'مشغولة', 'available' => 'فارغة', 'unpaid' => 'بانتظار الدفع', 'needsWaiter' => 'طلب نادل', 'orderReady' => 'الطلب جاهز', _ => s
    };

Widget _statusChip(String s) =>
    Chip(label: Text(_statusAr(s)), visualDensity: VisualDensity.compact);
