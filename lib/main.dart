import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyC6ja9p82UAKnibW7PvdVcNvJYJ9WOtkMU',
  authDomain: 'watsapp-halat.firebaseapp.com',
  databaseURL: 'https://watsapp-halat.firebaseio.com',
  projectId: 'watsapp-halat',
  storageBucket: 'watsapp-halat.appspot.com',
  messagingSenderId: '115869567267',
  appId: '1:115869567267:web:88209505e63a2e80c3e496',
);

const tenantId = 'demo_tenant';
const branchId = 'demo_branch';
const defaultCurrency = '₺';
const defaultCustomerMenuBaseUrl = 'https://watsapp-halat.web.app';
const uuid = Uuid();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const CashierManagerApp());
}

class CashierManagerApp extends StatefulWidget {
  const CashierManagerApp({super.key});

  @override
  State<CashierManagerApp> createState() => _CashierManagerAppState();
}

class _CashierManagerAppState extends State<CashierManagerApp> {
  Locale _locale = const Locale('ar');

  void setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    final isAr = _locale.languageCode == 'ar';
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9A3412),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashier Manager POS',
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        fontFamily: isAr ? 'Segoe UI' : null,
        scaffoldBackgroundColor: const Color(0xFFF8F4EC),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE7DCCB)),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      ),
      builder: (context, child) =>
          Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
      home: AuthGate(onLocaleChanged: setLocale, locale: _locale),
    );
  }
}

class AuthGate extends StatelessWidget {
  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

  const AuthGate(
      {super.key, required this.onLocaleChanged, required this.locale});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashPage();
        }
        final user = snapshot.data;
        if (user == null || user.isAnonymous) {
          return LoginPage(onLocaleChanged: onLocaleChanged, locale: locale);
        }
        return ManagerShell(
            user: user, onLocaleChanged: onLocaleChanged, locale: locale);
      },
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class AppText {
  static const _strings = {
    'ar': {
      'loginTitle': 'نظام إدارة المطعم',
      'loginSubtitle': 'Cashier Manager POS — نسخة Windows/Web مرتبطة بفايربيس',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'login': 'تسجيل الدخول',
      'createAccount': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'dashboard': 'لوحة التحكم',
      'cashier': 'الكاشير',
      'tables': 'الطاولات',
      'orders': 'الطلبات',
      'kitchen': 'المطبخ',
      'products': 'المنتجات',
      'modifiers': 'الإضافات',
      'inventory': 'المخزون',
      'purchases': 'المشتريات',
      'suppliers': 'الموردين',
      'expenses': 'المصاريف',
      'shift': 'الوردية',
      'reports': 'التقارير',
      'settings': 'الإعدادات',
      'logs': 'سجل العمليات',
      'waiters': 'الجراسين',
      'waiterCalls': 'طلبات النادل',
      'seedDemo': 'تجهيز بيانات تجريبية',
      'newOrder': 'طلب جديد',
      'sendKitchen': 'إرسال للمطبخ',
      'payCash': 'دفع كاش',
      'payCard': 'دفع بطاقة',
      'payMixed': 'دفع مختلط',
      'clear': 'تفريغ',
      'table': 'طاولة',
      'add': 'إضافة',
      'edit': 'تعديل',
      'delete': 'حذف',
      'freeze': 'تجميد',
      'activate': 'تفعيل',
      'copyQr': 'نسخ رابط QR',
      'qr': 'QR',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'search': 'بحث',
      'print': 'طباعة',
      'empty': 'لا توجد بيانات',
      'total': 'الإجمالي',
      'subtotal': 'المجموع الفرعي',
      'discount': 'الخصم',
      'notes': 'ملاحظات',
      'success': 'تمت العملية بنجاح',
      'error': 'حدث خطأ',
      'online': 'متصل',
      'offline': 'غير متصل',
      'language': 'اللغة',
      'liveDashboard': 'مراقبة المطعم الحية',
      'restaurantNow': 'حالة المطعم الآن',
      'availableTables': 'طاولات متاحة',
      'occupiedTables': 'طاولات مشغولة',
      'frozenTables': 'طاولات مجمدة',
      'lateOrders': 'طلبات متأخرة',
      'waiterAlerts': 'طلبات نادل',
    },
    'tr': {
      'loginTitle': 'Restoran Yönetim Sistemi',
      'loginSubtitle': 'Cashier Manager POS — Firebase bağlantılı Windows/Web sürümü',
      'email': 'E-posta',
      'password': 'Şifre',
      'login': 'Giriş yap',
      'createAccount': 'Hesap oluştur',
      'logout': 'Çıkış',
      'dashboard': 'Panel',
      'cashier': 'Kasa',
      'tables': 'Masalar',
      'orders': 'Siparişler',
      'kitchen': 'Mutfak',
      'products': 'Ürünler',
      'modifiers': 'Ekstralar',
      'inventory': 'Stok',
      'purchases': 'Satın alma',
      'suppliers': 'Tedarikçiler',
      'expenses': 'Giderler',
      'shift': 'Kasa vardiyası',
      'reports': 'Raporlar',
      'settings': 'Ayarlar',
      'logs': 'İşlem kayıtları',
      'waiters': 'Garsonlar',
      'waiterCalls': 'Garson çağrıları',
      'seedDemo': 'Demo verisi oluştur',
      'newOrder': 'Yeni sipariş',
      'sendKitchen': 'Mutfağa gönder',
      'payCash': 'Nakit öde',
      'payCard': 'Kart öde',
      'payMixed': 'Karışık ödeme',
      'clear': 'Temizle',
      'table': 'Masa',
      'add': 'Ekle',
      'edit': 'Düzenle',
      'delete': 'Sil',
      'freeze': 'Dondur',
      'activate': 'Aktifleştir',
      'copyQr': 'QR linkini kopyala',
      'qr': 'QR',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'search': 'Ara',
      'print': 'Yazdır',
      'empty': 'Veri yok',
      'total': 'Toplam',
      'subtotal': 'Ara toplam',
      'discount': 'İndirim',
      'notes': 'Notlar',
      'success': 'İşlem başarılı',
      'error': 'Hata oluştu',
      'online': 'Çevrimiçi',
      'offline': 'Çevrimdışı',
      'language': 'Dil',
      'liveDashboard': 'Canlı restoran paneli',
      'restaurantNow': 'Restoran durumu',
      'availableTables': 'Boş masalar',
      'occupiedTables': 'Dolu masalar',
      'frozenTables': 'Dondurulmuş masalar',
      'lateOrders': 'Geciken siparişler',
      'waiterAlerts': 'Garson çağrıları',
    },
    'en': {
      'loginTitle': 'Restaurant Management System',
      'loginSubtitle': 'Cashier Manager POS — Firebase-backed Windows/Web build',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'createAccount': 'Create account',
      'logout': 'Logout',
      'dashboard': 'Dashboard',
      'cashier': 'Cashier',
      'tables': 'Tables',
      'orders': 'Orders',
      'kitchen': 'Kitchen',
      'products': 'Products',
      'modifiers': 'Modifiers',
      'inventory': 'Inventory',
      'purchases': 'Purchases',
      'suppliers': 'Suppliers',
      'expenses': 'Expenses',
      'shift': 'Shift',
      'reports': 'Reports',
      'settings': 'Settings',
      'logs': 'Activity logs',
      'waiters': 'Waiters',
      'waiterCalls': 'Waiter calls',
      'seedDemo': 'Seed demo data',
      'newOrder': 'New order',
      'sendKitchen': 'Send to kitchen',
      'payCash': 'Cash payment',
      'payCard': 'Card payment',
      'payMixed': 'Mixed payment',
      'clear': 'Clear',
      'table': 'Table',
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'freeze': 'Freeze',
      'activate': 'Activate',
      'copyQr': 'Copy QR link',
      'qr': 'QR',
      'save': 'Save',
      'cancel': 'Cancel',
      'search': 'Search',
      'print': 'Print',
      'empty': 'No data',
      'total': 'Total',
      'subtotal': 'Subtotal',
      'discount': 'Discount',
      'notes': 'Notes',
      'success': 'Done successfully',
      'error': 'Error occurred',
      'online': 'Online',
      'offline': 'Offline',
      'language': 'Language',
      'liveDashboard': 'Live restaurant dashboard',
      'restaurantNow': 'Restaurant status now',
      'availableTables': 'Available tables',
      'occupiedTables': 'Occupied tables',
      'frozenTables': 'Frozen tables',
      'lateOrders': 'Late orders',
      'waiterAlerts': 'Waiter calls',
    },
  };

  static String of(BuildContext context, String key) {
    final lang = Localizations
        .localeOf(context)
        .languageCode;
    return _strings[lang]?[key] ?? _strings['en']?[key] ?? key;
  }
}

String t(BuildContext context, String key) => AppText.of(context, key);

class Fs {
  static final db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> get tenant =>
      db.collection('tenants').doc(tenantId);

  static CollectionReference<Map<String, dynamic>> tenantCol(String name) =>
      tenant.collection(name);

  static CollectionReference<Map<String, dynamic>> branchCol(String name) =>
      tenant.collection('branches').doc(branchId).collection(name);

  static CollectionReference<Map<String, dynamic>> get orders =>
      db.collection('orders');

  static CollectionReference<Map<String, dynamic>> get payments =>
      db.collection('payments');

  static String id([String p = 'id']) =>
      '${p}_${uuid.v4().replaceAll('-', '').substring(0, 10)}';

  static String money(num? value, [String currency = defaultCurrency]) {
    final n = (value ?? 0).toDouble();
    return '${intl.NumberFormat.decimalPattern('tr_TR').format(n)} $currency';
  }

  static DateTime? date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String dateText(dynamic value) {
    final d = date(value);
    if (d == null) return '—';
    return intl.DateFormat('yyyy-MM-dd HH:mm').format(d);
  }

  static double numVal(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  static Future<void> log(String action,
      {String? entityType, String? entityId, Map<String,
          dynamic>? details}) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await tenantCol('activity_logs').add({
        'tenantId': tenantId,
        'userId': user?.uid,
        'userEmail': user?.email,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'details': details ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Future<
      QueryDocumentSnapshot<Map<String, dynamic>>?> openShift() async {
    final snap = await tenantCol('cash_sessions')
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first;
  }

  static Map<String, dynamic> paymentShiftDelta(String method, double amount,
      {double cashPart = 0, double cardPart = 0}) {
    if (method == 'cash') {
      return {
        'cashSales': FieldValue.increment(amount),
        'expectedCash': FieldValue.increment(amount)
      };
    }
    if (method == 'card') {
      return {'cardSales': FieldValue.increment(amount)};
    }
    if (method == 'mixed') {
      return {
        'cashSales': FieldValue.increment(cashPart),
        'cardSales': FieldValue.increment(cardPart),
        'expectedCash': FieldValue.increment(cashPart)
      };
    }
    return {};
  }
}

class LoginPage extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

  const LoginPage(
      {super.key, required this.onLocaleChanged, required this.locale});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _auth(bool create) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (create) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text.trim(), password: pass.text);
        await Fs.tenantCol('users').doc(cred.user!.uid).set({
          'id': cred.user!.uid,
          'email': cred.user!.email,
          'name': cred.user!
              .email
              ?.split('@')
              .first,
          'role': 'cashier_manager',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await Fs.log('register', entityType: 'user', entityId: cred.user!.uid);
      } else {
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text.trim(), password: pass.text);
        await Fs.log('login', entityType: 'user', entityId: cred.user?.uid);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? e.code);
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C2D12), Color(0xFFEA580C), Color(0xFFFFFBEB)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: const Color(
                              0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.point_of_sale_rounded,
                              color: Color(0xFF9A3412), size: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t(context, 'loginTitle'),
                                  style: const TextStyle(fontSize: 24,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(t(context, 'loginSubtitle'),
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        LanguageMenu(locale: widget.locale,
                            onLocaleChanged: widget.onLocaleChanged),
                      ],
                    ),
                    const SizedBox(height: 28),
                    TextField(controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: t(context, 'email'))),
                    const SizedBox(height: 14),
                    TextField(controller: pass,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: t(context, 'password'))),
                    if (error != null) ...[
                      const SizedBox(height: 14),
                      ErrorBox(message: error!),
                    ],
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: loading ? null : () => _auth(false),
                      icon: loading
                          ? const SizedBox(width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.login_rounded),
                      label: Text(t(context, 'login')),
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: loading ? null : () => _auth(true),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(t(context, 'createAccount')),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageMenu extends StatelessWidget {
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  const LanguageMenu(
      {super.key, required this.locale, required this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: locale.languageCode,
        items: const [
          DropdownMenuItem(value: 'ar', child: Text('AR')),
          DropdownMenuItem(value: 'tr', child: Text('TR')),
          DropdownMenuItem(value: 'en', child: Text('EN')),
        ],
        onChanged: (v) {
          if (v != null) onLocaleChanged(Locale(v));
        },
      ),
    );
  }
}

enum PageKey {
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
  waiters,
  waiterCalls,
  logs
}

class ManagerShell extends StatefulWidget {
  final User user;
  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

  const ManagerShell(
      {super.key, required this.user, required this.onLocaleChanged, required this.locale});

  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  PageKey page = PageKey.cashier;
  bool seeding = false;

  final pages = const [
    PageKey.dashboard,
    PageKey.cashier,
    PageKey.tables,
    PageKey.orders,
    PageKey.kitchen,
    PageKey.products,
    PageKey.modifiers,
    PageKey.inventory,
    PageKey.purchases,
    PageKey.suppliers,
    PageKey.expenses,
    PageKey.shift,
    PageKey.reports,
    PageKey.settings,
    PageKey.waiters,
    PageKey.waiterCalls,
    PageKey.logs,
  ];

  String keyName(PageKey p) => p.name;

  Future<void> seedDemo() async {
    setState(() => seeding = true);
    try {
      final batch = Fs.db.batch();
      batch.set(Fs.tenant, {
        'id': tenantId,
        'name': 'Demo Restaurant',
        'currency': 'TRY',
        'updatedAt': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      batch.set(Fs.tenant.collection('branches').doc(branchId), {
        'id': branchId,
        'name': 'Main Branch',
        'updatedAt': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      final cats = [
        ['meals', 'وجبات', 'Yemekler', 'Meals', 1],
        ['drinks', 'مشروبات', 'İçecekler', 'Drinks', 2],
        ['desserts', 'حلويات', 'Tatlılar', 'Desserts', 3],
        ['extras', 'إضافات', 'Ekstralar', 'Extras', 4],
      ];
      for (final c in cats) {
        batch.set(Fs.tenantCol('categories').doc('${c[0]}'), {
          'id': c[0],
          'tenantId': tenantId,
          'name': c[1],
          'nameTr': c[2],
          'nameEn': c[3],
          'displayOrder': c[4],
          'isVisible': true,
        }, SetOptions(merge: true));
      }
      final items = [
        [
          'shawarma_chicken',
          'شاورما دجاج',
          'Tavuk döner',
          'Chicken Shawarma',
          'meals',
          120,
          'ساندويش شاورما دجاج مع صوص خاص'
        ],
        [
          'burger',
          'برغر كلاسيك',
          'Klasik burger',
          'Classic Burger',
          'meals',
          150,
          'برغر لحم مع جبنة وخضار'
        ],
        [
          'fries',
          'بطاطا محمرة',
          'Patates kızartması',
          'French Fries',
          'extras',
          50,
          'بطاطا مقرمشة'
        ],
        ['cola', 'كولا', 'Kola', 'Cola', 'drinks', 30, 'مشروب غازي'],
        [
          'juice',
          'عصير طازج',
          'Taze meyve suyu',
          'Fresh Juice',
          'drinks',
          45,
          'عصير موسمي'
        ],
        ['kunafa', 'كنافة', 'Künefe', 'Kunafa', 'desserts', 90, 'حلويات ساخنة'],
      ];
      for (final i in items) {
        batch.set(Fs.tenantCol('menu_items').doc('${i[0]}'), {
          'id': i[0],
          'tenantId': tenantId,
          'name': i[1],
          'nameTr': i[2],
          'nameEn': i[3],
          'categoryId': i[4],
          'price': i[5],
          'description': i[6],
          'isVisible': true,
          'isAvailable': true,
          'isSoldOut': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      for (var i = 1; i <= 10; i++) {
        final id = 'table_$i';
        batch.set(Fs.branchCol('tables').doc(id), {
          'id': id,
          'tenantId': tenantId,
          'branchId': branchId,
          'number': '$i',
          'status': 'available',
          'isActive': true,
          'qrCodeUrl': '$defaultCustomerMenuBaseUrl/#/menu/$tenantId/$branchId/$id',
          'lastStatusUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      final inv = [
        ['chicken', 'دجاج', 'كغ', 12, 3, 80],
        ['meat', 'لحم', 'كغ', 8, 2, 120],
        ['bread', 'خبز', 'قطعة', 60, 15, 3],
        ['cola_stock', 'كولا', 'علبة', 48, 12, 15],
      ];
      for (final i in inv) {
        batch.set(Fs.tenantCol('inventory_items').doc('${i[0]}'), {
          'id': i[0],
          'name': i[1],
          'unit': i[2],
          'quantity': i[3],
          'minQuantity': i[4],
          'lastPurchasePrice': i[5],
          'status': 'active',
        }, SetOptions(merge: true));
      }
      batch.set(Fs.tenantCol('suppliers').doc('supplier_1'), {
        'id': 'supplier_1',
        'name': 'مورد المواد الرئيسي',
        'phone': '0500000000',
        'address': 'السوق',
        'status': 'active'
      }, SetOptions(merge: true));
      batch.set(Fs.tenantCol('settings').doc('main'), {
        'restaurantName': 'Demo Restaurant',
        'currency': '₺',
        'taxRate': 0,
        'customerMenuBaseUrl': defaultCustomerMenuBaseUrl
      }, SetOptions(merge: true));
      await batch.commit();
      await Fs.log('seed_demo_data');
      if (mounted) toast(context, t(context, 'success'));
    } catch (e) {
      if (mounted) toast(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = pages.indexOf(page);
    final wide = MediaQuery
        .sizeOf(context)
        .width >= 960;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: Row(
        children: [
          if (wide) _rail(selectedIndex, extended: MediaQuery
              .sizeOf(context)
              .width > 1250),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  title: t(context, keyName(page)),
                  user: widget.user,
                  seeding: seeding,
                  onSeed: seedDemo,
                  locale: widget.locale,
                  onLocaleChanged: widget.onLocaleChanged,
                ),
                Expanded(child: PageSurface(child: _bodyFor(page))),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
        selectedIndex: min(selectedIndex, 4),
        onDestinationSelected: (i) => setState(() => page = pages[i]),
        destinations: pages
            .take(5)
            .map((p) =>
            NavigationDestination(
                icon: Icon(iconFor(p)), label: t(context, keyName(p))))
            .toList(),
      ),
      drawer: wide
          ? null
          : Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: pages.map((p) =>
                ListTile(
                  selected: p == page,
                  leading: Icon(iconFor(p)),
                  title: Text(t(context, keyName(p))),
                  onTap: () {
                    setState(() => page = p);
                    Navigator.pop(context);
                  },
                )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _rail(int selectedIndex, {required bool extended}) {
    // Windows-safe custom side navigation.
    // Do NOT wrap NavigationRail in SingleChildScrollView: it causes
    // "RenderFlex children have non-zero flex but incoming height constraints are unbounded".
    return Container(
      width: extended ? 260 : 92,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE7DCCB))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                        Icons.restaurant_rounded, color: Color(0xFF9A3412)),
                  ),
                  if (extended) ...[
                    const SizedBox(height: 8),
                    const Text('Cashier Manager', maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    const Text('Firebase live POS', maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final p = pages[index];
                  final selected = index == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: selected ? const Color(0xFFFFEDD5) : Colors
                          .transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => page = p),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: extended ? 14 : 0, vertical: 12),
                          child: Row(
                            mainAxisAlignment: extended ? MainAxisAlignment
                                .start : MainAxisAlignment.center,
                            children: [
                              Icon(iconFor(p), color: selected
                                  ? const Color(0xFF9A3412)
                                  : const Color(0xFF6B7280)),
                              if (extended) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t(context, keyName(p)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                      color: selected
                                          ? const Color(0xFF9A3412)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyFor(PageKey p) {
    switch (p) {
      case PageKey.dashboard:
        return const DashboardPage();
      case PageKey.cashier:
        return const CashierPage();
      case PageKey.tables:
        return const TablesPage();
      case PageKey.orders:
        return const OrdersPage();
      case PageKey.kitchen:
        return const KitchenPage();
      case PageKey.products:
        return const ProductsPage();
      case PageKey.modifiers:
        return const ModifiersPage();
      case PageKey.inventory:
        return const InventoryPage();
      case PageKey.purchases:
        return const PurchasesPage();
      case PageKey.suppliers:
        return const SuppliersPage();
      case PageKey.expenses:
        return const ExpensesPage();
      case PageKey.shift:
        return const ShiftPage();
      case PageKey.reports:
        return const ReportsPage();
      case PageKey.settings:
        return const SettingsPage();
      case PageKey.logs:
        return const LogsPage();
      case PageKey.waiters:
        return const WaitersPage();
      case PageKey.waiterCalls:
        return const WaiterCallsPage();
    }
  }
}

IconData iconFor(PageKey p) {
  switch (p) {
    case PageKey.dashboard:
      return Icons.dashboard_rounded;
    case PageKey.cashier:
      return Icons.point_of_sale_rounded;
    case PageKey.tables:
      return Icons.table_restaurant_rounded;
    case PageKey.orders:
      return Icons.receipt_long_rounded;
    case PageKey.kitchen:
      return Icons.soup_kitchen_rounded;
    case PageKey.products:
      return Icons.restaurant_menu_rounded;
    case PageKey.modifiers:
      return Icons.tune_rounded;
    case PageKey.inventory:
      return Icons.inventory_2_rounded;
    case PageKey.purchases:
      return Icons.shopping_cart_checkout_rounded;
    case PageKey.suppliers:
      return Icons.local_shipping_rounded;
    case PageKey.expenses:
      return Icons.payments_rounded;
    case PageKey.shift:
      return Icons.work_history_rounded;
    case PageKey.reports:
      return Icons.analytics_rounded;
    case PageKey.settings:
      return Icons.settings_rounded;
    case PageKey.logs:
      return Icons.manage_search_rounded;
    case PageKey.waiters:
      return Icons.groups_rounded;
    case PageKey.waiterCalls:
      return Icons.notifications_active_rounded;
  }
}

class TopBar extends StatelessWidget {
  final String title;
  final User user;
  final bool seeding;
  final VoidCallback onSeed;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  const TopBar(
      {super.key, required this.title, required this.user, required this.seeding, required this.onSeed, required this.locale, required this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE7DCCB)))),
      child: Row(
        children: [
          Builder(builder: (context) =>
              IconButton(
                  icon: const Icon(Icons.menu_rounded), onPressed: Scaffold
                  .maybeOf(context)
                  ?.openDrawer)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w900))),
          LanguageMenu(locale: locale, onLocaleChanged: onLocaleChanged),
          const SizedBox(width: 10),
          // Production/MVP mode: no automatic fake/demo data button in the main toolbar.
          // Tables, products, expenses, and inventory must be managed from their real pages and saved in Firestore.

          Text(user.email ?? '',
              style: const TextStyle(color: Color(0xFF6B7280))),
          IconButton(tooltip: t(context, 'logout'), onPressed: () async {
            await Fs.log('logout');
            await FirebaseAuth.instance.signOut();
          }, icon: const Icon(Icons.logout_rounded)),
        ],
      ),
    );
  }
}

class PageSurface extends StatelessWidget {
  final Widget child;

  const PageSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(18), child: child);
}

class ErrorBox extends StatelessWidget {
  final String message;

  const ErrorBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFCA5A5))),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
        const SizedBox(width: 8),
        Expanded(child: Text(
            message, style: const TextStyle(color: Color(0xFF991B1B))))
      ]),
    );
  }
}

void toast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),
      backgroundColor: error ? const Color(0xFFDC2626) : const Color(
          0xFF059669)));
}

Future<bool> confirm(BuildContext context, String message) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) =>
        AlertDialog(
          title: const Text('تأكيد'),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
                child: Text(t(context, 'cancel'))),
            FilledButton(onPressed: () => Navigator.pop(context, true),
                child: const Text('نعم')),
          ],
        ),
  ) ?? false;
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppCard(
      {super.key, required this.child, this.padding = const EdgeInsets.all(
          18)});

  @override
  Widget build(BuildContext context) =>
      Card(child: Padding(padding: padding, child: child));
}

class DataStream<T> extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final Widget Function(List<Map<String, dynamic>> docs) builder;

  const DataStream({super.key, required this.stream, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorBox(message: '${snapshot.error}');
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.map((d) =>
        {
          ...d.data(),
          '_docId': d.id,
          'id': d.data()['id'] ?? d.id
        }).toList();
        return builder(docs);
      },
    );
  }
}

// ───────────────────────── Dashboard ─────────────────────────
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: Fs.orders.where('tenantId', isEqualTo: tenantId).snapshots(),
      builder: (context, ordersSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Fs.branchCol('tables').snapshots(),
          builder: (context, tablesSnap) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: Fs.tenantCol('expenses').snapshots(),
              builder: (context, expensesSnap) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: Fs.tenantCol('inventory_items').snapshots(),
                  builder: (context, inventorySnap) {
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: Fs.tenantCol('waiter_calls').snapshots(),
                      builder: (context, callsSnap) {
                        final orders = (ordersSnap.data?.docs ?? []).map((
                            d) => {...d.data(), 'id': d.id}).toList();
                        final tables = (tablesSnap.data?.docs ?? []).map((
                            d) => {...d.data(), 'id': d.id}).toList();
                        final expenses = (expensesSnap.data?.docs ?? []).map((
                            d) => {...d.data(), 'id': d.id}).toList();
                        final inventory = (inventorySnap.data?.docs ?? []).map((
                            d) => {...d.data(), 'id': d.id}).toList();
                        final calls = (callsSnap.data?.docs ?? []).map((d) =>
                        {
                          ...d.data(),
                          'id': d.id
                        }).toList();

                        final today = DateTime.now();
                        final start = DateTime(
                            today.year, today.month, today.day);
                        bool isToday(dynamic v) {
                          final d = Fs.date(v);
                          return d != null && !d.isBefore(start);
                        }

                        final todayOrders = orders.where((o) =>
                            isToday(o['createdAt'])).toList();
                        final paid = todayOrders.where((o) =>
                        o['status'] == 'paid' || o['isPaid'] == true).toList();
                        final sales = paid.fold<double>(0, (s, o) =>
                        s + Fs.numVal(o['totalAmount'] ?? o['total']));
                        final cash = paid.where((o) =>
                            '${o['paymentMethod']}'.contains('cash')).fold<
                            double>(0, (s, o) =>
                        s + Fs.numVal(o['totalAmount'] ?? o['total']));
                        final card = paid.where((o) =>
                            '${o['paymentMethod']}'.contains('card')).fold<
                            double>(0, (s, o) =>
                        s + Fs.numVal(o['totalAmount'] ?? o['total']));
                        final exp = expenses.where((e) =>
                        isToday(e['createdAt']) && e['status'] != 'cancelled' &&
                            e['deleted'] != true).fold<double>(
                            0, (s, e) => s + Fs.numVal(e['amount']));
                        final openOrders = orders.where((o) =>
                        ![
                          'paid',
                          'cancelled',
                          'refunded'
                        ].contains('${o['status']}')).toList();
                        final kitchenOrders = orders.where((o) =>
                            ['sent_to_kitchen', 'pending', 'preparing']
                                .contains('${o['status']}')).toList();
                        final readyOrders = orders.where((
                            o) => '${o['status']}' == 'ready').toList();
                        final lateOrders = kitchenOrders.where((o) {
                          final d = Fs.date(o['createdAt']);
                          return d != null && DateTime
                              .now()
                              .difference(d)
                              .inMinutes >= 20;
                        }).toList();
                        final availableTables = tables
                            .where((t) =>
                        '${t['status']}' == 'available' &&
                            t['isActive'] != false)
                            .length;
                        final occupiedTables = tables
                            .where((t) =>
                            [
                              'occupied',
                              'in_kitchen',
                              'ready',
                              'waiting_payment'
                            ].contains('${t['status']}'))
                            .length;
                        final frozenTables = tables
                            .where((t) =>
                        ['frozen', 'suspended', 'inactive'].contains(
                            '${t['status']}') || t['isActive'] == false)
                            .length;
                        final waiterAlerts = calls
                            .where((c) =>
                            ['new', 'seen', 'assigned'].contains(
                                '${c['status'] ?? 'new'}'))
                            .length;
                        final lowStock = inventory.where((i) =>
                        Fs.numVal(i['quantity']) <=
                            Fs.numVal(i['minQuantity']) &&
                            i['status'] != 'deleted').toList();

                        final loading = ordersSnap.connectionState ==
                            ConnectionState.waiting ||
                            tablesSnap.connectionState ==
                                ConnectionState.waiting;
                        if (loading && orders.isEmpty && tables.isEmpty)
                          return const Center(
                              child: CircularProgressIndicator());

                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .stretch, children: [
                                Row(children: [
                                  Expanded(child: Text(
                                      t(context, 'liveDashboard'),
                                      style: const TextStyle(fontSize: 24,
                                          fontWeight: FontWeight.w900))),
                                  LivePill(label: 'LIVE',
                                      color: const Color(0xFF059669)),
                                ]),
                                const SizedBox(height: 14),
                                LayoutBuilder(builder: (context, c) {
                                  final cross = c.maxWidth > 1300 ? 5 : c
                                      .maxWidth > 900 ? 4 : 2;
                                  return GridView.count(
                                    crossAxisCount: cross,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 2.25,
                                    children: [
                                      StatCard(label: 'مبيعات اليوم',
                                          value: Fs.money(sales),
                                          icon: Icons.trending_up_rounded,
                                          color: const Color(0xFF059669)),
                                      StatCard(label: 'إجمالي الكاش',
                                          value: Fs.money(cash),
                                          icon: Icons.payments_rounded,
                                          color: const Color(0xFF16A34A)),
                                      StatCard(label: 'إجمالي البطاقة',
                                          value: Fs.money(card),
                                          icon: Icons.credit_card_rounded,
                                          color: const Color(0xFF7C3AED)),
                                      StatCard(label: 'المصاريف',
                                          value: Fs.money(exp),
                                          icon: Icons.money_off_rounded,
                                          color: const Color(0xFFDC2626)),
                                      StatCard(label: 'صافي الصندوق',
                                          value: Fs.money(cash - exp),
                                          icon: Icons
                                              .account_balance_wallet_rounded,
                                          color: const Color(0xFF0F766E)),
                                      StatCard(label: 'طاولات متاحة',
                                          value: '$availableTables',
                                          icon: Icons.event_seat_rounded,
                                          color: const Color(0xFF059669)),
                                      StatCard(label: 'طاولات مشغولة',
                                          value: '$occupiedTables',
                                          icon: Icons.table_restaurant_rounded,
                                          color: const Color(0xFFEA580C)),
                                      StatCard(label: 'طاولات مجمدة',
                                          value: '$frozenTables',
                                          icon: Icons.pause_circle_rounded,
                                          color: const Color(0xFF6B7280)),
                                      StatCard(label: 'طلبات المطبخ',
                                          value: '${kitchenOrders.length}',
                                          icon: Icons.soup_kitchen_rounded,
                                          color: const Color(0xFF2563EB)),
                                      StatCard(label: 'طلبات جاهزة',
                                          value: '${readyOrders.length}',
                                          icon: Icons.task_alt_rounded,
                                          color: const Color(0xFF16A34A)),
                                      StatCard(label: 'طلبات متأخرة',
                                          value: '${lateOrders.length}',
                                          icon: Icons.warning_rounded,
                                          color: const Color(0xFFDC2626)),
                                      StatCard(label: 'طلبات نادل',
                                          value: '$waiterAlerts',
                                          icon: Icons
                                              .notifications_active_rounded,
                                          color: const Color(0xFF9333EA)),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 16),
                              ]),
                            ),
                            SliverLayoutBuilder(
                                builder: (context, constraints) {
                                  return SliverToBoxAdapter(
                                      child: LayoutBuilder(
                                          builder: (context, c) {
                                            final twoCols = c.maxWidth > 1000;
                                            final left = _LiveTablesPanel(
                                                tables: tables, orders: orders);
                                            final right = Column(children: [
                                              _KitchenNowPanel(
                                                  orders: kitchenOrders,
                                                  lateOrders: lateOrders),
                                              const SizedBox(height: 14),
                                              _AlertsPanel(waiterCalls: calls,
                                                  lowStock: lowStock),
                                            ]);
                                            return twoCols
                                                ? Row(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Expanded(
                                                      flex: 3, child: left),
                                                  const SizedBox(width: 14),
                                                  Expanded(
                                                      flex: 2, child: right)
                                                ])
                                                : Column(children: [
                                              left,
                                              const SizedBox(height: 14),
                                              right
                                            ]);
                                          }));
                                }),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class LivePill extends StatelessWidget {
  final String label;
  final Color color;

  const LivePill({super.key, required this.label, required this.color});

  @override Widget build(BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(.3))),
        child: Text(
            label, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
      );
}

class _LiveTablesPanel extends StatelessWidget {
  final List<Map<String, dynamic>> tables;
  final List<Map<String, dynamic>> orders;

  const _LiveTablesPanel({required this.tables, required this.orders});

  @override Widget build(BuildContext context) {
    final sorted = [...tables]
      ..sort((a, b) =>
          Fs.numVal(a['number']).compareTo(Fs.numVal(b['number'])));
    return AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('حالة الطاولات المباشرة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (sorted.isEmpty) Center(child: Text(t(context, 'empty'))) else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 230,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.45),
              itemBuilder: (context, i) {
                final tab = sorted[i];
                final active = orders
                    .where((o) =>
                '${o['tableId']}' == '${tab['id']}' &&
                    !['paid', 'cancelled', 'refunded'].contains(
                        '${o['status']}'))
                    .firstOrNull;
                final status = '${tab['status'] ?? 'available'}';
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: statusColor(status).withOpacity(.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: statusColor(status).withOpacity(.28))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(
                          'طاولة ${tab['number'] ?? tab['id']}',
                          style: const TextStyle(fontWeight: FontWeight.w900))),
                      Icon(Icons.table_restaurant_rounded, color: statusColor(
                          status))
                    ]),
                    const Spacer(),
                    Text(statusLabel(status), style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.w900)),
                    if (active != null) Text(
                        '${active['orderNumber'] ?? active['id']} • ${Fs.money(
                            Fs.numVal(
                                active['totalAmount'] ?? active['total']))}',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (active == null) const Text(
                        'لا يوجد طلب نشط', style: TextStyle(color: Color(
                        0xFF6B7280))),
                  ]),
                );
              },
            ),
        ]));
  }
}

class _KitchenNowPanel extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> lateOrders;

  const _KitchenNowPanel({required this.orders, required this.lateOrders});

  @override Widget build(BuildContext context) =>
      AppCard(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Expanded(child: Text('حالة المطبخ الحالية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          Icon(Icons.soup_kitchen_rounded, color: Color(0xFFEA580C))
        ]),
        const SizedBox(height: 10),
        if (orders.isEmpty) const Text('لا توجد طلبات في المطبخ الآن') else
          ...orders.take(8).map((o) =>
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.receipt_long_rounded,
                    color: lateOrders.any((l) => l['id'] == o['id'])
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF2563EB)),
                title: Text('${o['orderNumber'] ?? o['id']} • ${statusLabel(
                    '${o['status']}')}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(o['tableNumber'] == null ? orderTypeLabel(
                    '${o['orderType']}') : 'طاولة ${o['tableNumber']}'),
                trailing: Text(Fs.dateText(o['createdAt'])),
              )),
      ]));
}

class _AlertsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> waiterCalls;
  final List<Map<String, dynamic>> lowStock;

  const _AlertsPanel({required this.waiterCalls, required this.lowStock});

  @override Widget build(BuildContext context) {
    final activeCalls = waiterCalls
        .where((c) =>
        ['new', 'seen', 'assigned'].contains('${c['status'] ?? 'new'}'))
        .toList();
    return AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('التنبيهات المهمة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (activeCalls.isEmpty && lowStock.isEmpty) const Text(
              'لا توجد تنبيهات حرجة الآن'),
          ...activeCalls.take(5).map((c) =>
              ListTile(contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_rounded,
                      color: Color(0xFF9333EA)),
                  title: Text(
                      'طلب نادل من طاولة ${c['tableNumber'] ?? c['tableId'] ??
                          '—'}'),
                  subtitle: Text(statusLabel('${c['status'] ?? 'new'}')))),
          ...lowStock.take(6).map((i) =>
              ListTile(contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                      Icons.inventory_2_rounded, color: Color(0xFFDC2626)),
                  title: Text('مخزون منخفض: ${i['name']}'),
                  subtitle: Text('${i['quantity']} ${i['unit'] ??
                      ''} / الحد ${i['minQuantity']}'))),
        ]));
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard(
      {super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) =>
      AppCard(
        child: Row(children: [
          Container(width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 6),
                Text(value, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.w900))
              ])),
        ]),
      );
}

class InventoryLowStockPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('تنبيهات المخزون الناقص',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Expanded(child: DataStream(
              stream: Fs.tenantCol('inventory_items').snapshots(),
              builder: (items) {
                final low = items
                    .where((i) =>
                Fs.numVal(i['quantity']) <= Fs.numVal(i['minQuantity']))
                    .toList();
                if (low.isEmpty)
                  return const Center(child: Text('لا توجد تنبيهات مخزون'));
                return ListView.separated(itemCount: low.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final item = low[i];
                      return ListTile(leading: const Icon(
                          Icons.warning_rounded, color: Color(0xFFEA580C)),
                          title: Text('${item['name']}'),
                          subtitle: Text(
                              'الكمية: ${item['quantity']} ${item['unit'] ??
                                  ''} — حد التنبيه: ${item['minQuantity']}'));
                    });
              })),
        ]),
      );
}

// ───────────────────────── Cashier ─────────────────────────
class PosLine {
  final String productId;
  final String productName;
  final double unitPrice;
  int quantity;
  String notes;

  PosLine(
      {required this.productId, required this.productName, required this.unitPrice, this.quantity = 1, this.notes = ''});

  double get total => unitPrice * quantity;

  Map<String, dynamic> toMap() =>
      {
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'notes': notes,
        'lineTotal': total
      };
}

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  final cart = <PosLine>[];
  String? selectedCategory;
  String orderType = 'dine_in';
  String? tableId;
  String? tableNumber;
  final discount = TextEditingController(text: '0');
  final notes = TextEditingController();

  @override
  void dispose() {
    discount.dispose();
    notes.dispose();
    super.dispose();
  }

  double get subtotal => cart.fold(0, (s, i) => s + i.total);

  double get discountValue => Fs.numVal(discount.text);

  double get total => max(0, subtotal - discountValue);

  void addProduct(Map<String, dynamic> p) {
    final id = '${p['id']}';
    final current = cart
        .where((l) => l.productId == id)
        .firstOrNull;
    setState(() {
      if (current != null)
        current.quantity += 1;
      else
        cart.add(PosLine(productId: id,
            productName: '${p['name'] ?? p['nameAr'] ?? id}',
            unitPrice: Fs.numVal(p['price'])));
    });
  }

  Future<bool> validate() async {
    if (cart.isEmpty) {
      toast(context, 'السلة فارغة', error: true);
      return false;
    }
    if (orderType == 'dine_in' && tableId == null) {
      toast(context, 'اختر الطاولة أولًا', error: true);
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> buildOrder(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    return {
      'tenantId': tenantId,
      'branchId': branchId,
      'source': 'cashier',
      'customerId': user?.uid ?? 'cashier',
      'orderType': orderType,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'items': cart.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discountValue,
      'totalAmount': total,
      'total': total,
      'status': status,
      'paymentStatus': status == 'paid' ? 'paid' : 'unpaid',
      'isPaid': status == 'paid',
      'notes': notes.text.trim(),
      'createdBy': user?.email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'orderNumber': 'ORD-${DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()
          .substring(7)}',
    };
  }

  Future<void> sendToKitchen() async {
    if (!await validate()) return;
    try {
      final data = await buildOrder('sent_to_kitchen');
      final orderRef = Fs.orders.doc();
      await Fs.db.runTransaction((tx) async {
        if (tableId != null) {
          final tableRef = Fs.branchCol('tables').doc(tableId);
          final tableSnap = await tx.get(tableRef);
          final tableData = tableSnap.data() ?? {};
          final status = '${tableData['status'] ?? 'available'}';
          if (tableData['isActive'] == false ||
              ['frozen', 'suspended', 'inactive'].contains(status)) {
            throw Exception('هذه الطاولة غير متاحة الآن');
          }
          if (tableData['activeOrderId'] != null &&
              '${tableData['activeOrderId']}'.isNotEmpty &&
              status != 'available') {
            throw Exception('هذه الطاولة مرتبطة بطلب نشط بالفعل');
          }
          tx.set(tableRef, {
            'status': 'in_kitchen',
            'activeOrderId': orderRef.id,
            'isOccupied': true,
            'lastStatusUpdate': FieldValue.serverTimestamp()
          }, SetOptions(merge: true));
        }
        tx.set(orderRef, data);
      });
      await Fs.log('send_to_kitchen', entityType: 'order',
          entityId: orderRef.id,
          details: {'total': total, 'tableId': tableId});
      clearAll(silent: true);
      toast(context, 'تم إرسال الطلب للمطبخ');
    } catch (e) {
      toast(context, '$e', error: true);
    }
  }

  Future<void> pay(String method) async {
    if (!await validate()) return;
    double cashPart = 0;
    double cardPart = 0;
    if (method == 'mixed') {
      final v = await promptNumber(context, title: 'الدفع المختلط',
          label: 'المبلغ كاش من أصل ${Fs.money(total)}');
      if (v == null) return;
      if (v < 0 || v > total) {
        toast(context, 'المبلغ غير صحيح', error: true);
        return;
      }
      cashPart = v;
      cardPart = total - v;
    }
    try {
      final data = await buildOrder('paid');
      data['paymentMethod'] = method;
      data['paidAt'] = FieldValue.serverTimestamp();
      if (method == 'mixed') {
        data['cashAmount'] = cashPart;
        data['cardAmount'] = cardPart;
      }
      final orderRef = Fs.orders.doc();
      final shift = await Fs.openShift();
      if (shift != null) data['shiftId'] = shift.id;
      await Fs.db.runTransaction((tx) async {
        if (tableId != null) {
          final tableRef = Fs.branchCol('tables').doc(tableId);
          final tableSnap = await tx.get(tableRef);
          final tableData = tableSnap.data() ?? {};
          final status = '${tableData['status'] ?? 'available'}';
          if (tableData['isActive'] == false ||
              ['frozen', 'suspended', 'inactive'].contains(status)) {
            throw Exception('هذه الطاولة غير متاحة الآن');
          }
          tx.set(tableRef, {
            'status': 'available',
            'activeOrderId': null,
            'isOccupied': false,
            'lastStatusUpdate': FieldValue.serverTimestamp()
          }, SetOptions(merge: true));
        }
        tx.set(orderRef, data);
        if (method == 'mixed') {
          tx.set(Fs.payments.doc(), {
            'tenantId': tenantId,
            'orderId': orderRef.id,
            'shiftId': shift?.id,
            'paymentMethod': 'cash',
            'amount': cashPart,
            'paidAt': FieldValue.serverTimestamp()
          });
          tx.set(Fs.payments.doc(), {
            'tenantId': tenantId,
            'orderId': orderRef.id,
            'shiftId': shift?.id,
            'paymentMethod': 'card',
            'amount': cardPart,
            'paidAt': FieldValue.serverTimestamp()
          });
        } else {
          tx.set(Fs.payments.doc(), {
            'tenantId': tenantId,
            'orderId': orderRef.id,
            'shiftId': shift?.id,
            'paymentMethod': method,
            'amount': total,
            'paidAt': FieldValue.serverTimestamp()
          });
        }
        if (shift != null) tx.set(shift.reference, Fs.paymentShiftDelta(
            method, total, cashPart: cashPart, cardPart: cardPart),
            SetOptions(merge: true));
      });
      await Fs.log('payment', entityType: 'order',
          entityId: orderRef.id,
          details: {'method': method, 'total': total, 'shiftId': shift?.id});
      clearAll(silent: true);
      toast(context, 'تم الدفع بنجاح');
    } catch (e) {
      toast(context, '$e', error: true);
    }
  }

  void clearAll({bool silent = false}) {
    setState(() {
      cart.clear();
      tableId = null;
      tableNumber = null;
      discount.text = '0';
      notes.clear();
    });
    if (!silent) toast(context, 'تم تفريغ الطلب');
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery
        .sizeOf(context)
        .width > 1050;
    final content = wide ? Row(children: [
      _categories(),
      const SizedBox(width: 12),
      Expanded(flex: 3, child: _products()),
      const SizedBox(width: 12),
      SizedBox(width: 390, child: _ticket())
    ]) : Column(children: [
      SizedBox(height: 74, child: _categories()),
      Expanded(child: _products()),
      SizedBox(height: 420, child: _ticket())
    ]);
    return content;
  }

  Widget _categories() =>
      AppCard(padding: const EdgeInsets.all(10),
          child: DataStream(stream: Fs
              .tenantCol('categories')
              .orderBy('displayOrder')
              .snapshots(), builder: (cats) =>
              ListView(
                scrollDirection: MediaQuery
                    .sizeOf(context)
                    .width > 1050 ? Axis.vertical : Axis.horizontal,
                children: [
                  CategoryButton(label: 'الكل',
                      selected: selectedCategory == null,
                      onTap: () => setState(() => selectedCategory = null)),
                  ...cats.map((c) =>
                      CategoryButton(label: '${c['name']}',
                          selected: selectedCategory == c['id'],
                          onTap: () =>
                              setState(() => selectedCategory = '${c['id']}'))),
                ],
              )));

  Widget _products() =>
      AppCard(child: DataStream(
          stream: Fs.tenantCol('menu_items').snapshots(), builder: (items) {
        final filtered = items
            .where((p) =>
        p['isVisible'] != false && p['isAvailable'] != false &&
            p['isSoldOut'] != true &&
            (selectedCategory == null || p['categoryId'] == selectedCategory))
            .toList();
        if (filtered.isEmpty) return Center(child: Text(t(context, 'empty')));
        return GridView.builder(
          itemCount: filtered.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 190,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: MediaQuery
                  .sizeOf(context)
                  .width > 900 ? 1.05 : .95),
          itemBuilder: (context, i) {
            final p = filtered[i];
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => addProduct(p),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFFBF5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE7DCCB))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.fastfood_rounded, color: Color(0xFFEA580C),
                      size: 34),
                  const Spacer(),
                  Text('${p['name']}', maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(Fs.money(Fs.numVal(p['price'])), style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF9A3412),
                      fontSize: 16)),
                ]),
              ),
            );
          },
        );
      }));

  Widget _ticket() =>
      AppCard(child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Expanded(child: Text('الفاتورة الحالية',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20))),
          IconButton(
              onPressed: clearAll, icon: const Icon(Icons.delete_sweep_rounded))
        ]),
        SegmentedButton<String>(segments: const [
          ButtonSegment(value: 'dine_in', label: Text('داخلي')),
          ButtonSegment(value: 'takeaway', label: Text('سفري')),
          ButtonSegment(value: 'delivery', label: Text('توصيل'))
        ],
            selected: {orderType},
            onSelectionChanged: (v) => setState(() => orderType = v.first)),
        const SizedBox(height: 10),
        if (orderType == 'dine_in') StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: Fs
              .branchCol('tables')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snap) {
            final tables = snap.data?.docs
                .map((d) => {...d.data(), 'id': d.id})
                .toList() ?? [];
            return DropdownButtonFormField<String>(
              value: tableId,
              decoration: const InputDecoration(labelText: 'الطاولة'),
              items: tables.map((t) =>
                  DropdownMenuItem(value: '${t['id']}',
                      child: Text('طاولة ${t['number']} — ${statusLabel(
                          '${t['status']}')}'))).toList(),
              onChanged: (v) {
                final tab = tables.firstWhere((e) => e['id'] == v);
                setState(() {
                  tableId = v;
                  tableNumber = '${tab['number']}';
                });
              },
            );
          },
        ),
        const SizedBox(height: 12),
        Expanded(child: cart.isEmpty
            ? const Center(child: Text('السلة فارغة'))
            : ListView.separated(itemCount: cart.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final line = cart[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(line.productName,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(Fs.money(line.unitPrice)),
                trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center, children: [
                  IconButton(onPressed: () =>
                      setState(() {
                        if (line.quantity > 1)
                          line.quantity--;
                        else
                          cart.removeAt(i);
                      }), icon: const Icon(Icons.remove_circle_outline)),
                  Text('${line.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  IconButton(onPressed: () => setState(() => line.quantity++),
                      icon: const Icon(Icons.add_circle_outline)),
                ]),
              );
            })),
        TextField(controller: notes,
            decoration: InputDecoration(labelText: t(context, 'notes'))),
        const SizedBox(height: 8),
        TextField(controller: discount,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: t(context, 'discount'))),
        const SizedBox(height: 12),
        TotalRows(subtotal: subtotal, discount: discountValue, total: total),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: sendToKitchen,
            icon: const Icon(Icons.send_rounded),
            label: Text(t(context, 'sendKitchen'))),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => pay('cash'),
              child: Text(t(context, 'payCash')))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(
              onPressed: () => pay('card'), child: Text(t(context, 'payCard'))))
        ]),
        const SizedBox(height: 8),
        OutlinedButton(
            onPressed: () => pay('mixed'), child: Text(t(context, 'payMixed'))),
      ]));
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryButton(
      {super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(4),
          child: FilledButton.tonal(onPressed: onTap,
              style: FilledButton.styleFrom(
                  backgroundColor: selected ? const Color(0xFFFFEDD5) : null),
              child: Text(label)));
}

class TotalRows extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;

  const TotalRows(
      {super.key, required this.subtotal, required this.discount, required this.total});

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(t(context, 'subtotal')), Text(Fs.money(subtotal))]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t(context, 'discount')),
              Text('- ${Fs.money(discount)}')
            ]),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t(context, 'total'), style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 18)),
              Text(Fs.money(total), style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color(0xFF9A3412)))
            ]),
      ]);
}

extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

// ───────────────────────── Tables ─────────────────────────
class TablesPage extends StatelessWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        FilledButton.icon(onPressed: () => showTableDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة طاولة')),
        const Spacer()
      ]),
      const SizedBox(height: 12),
      Expanded(child: DataStream(
          stream: Fs.branchCol('tables').snapshots(), builder: (tables) {
        final active = tables.where((t) => t['deleted'] != true).toList()
          ..sort((a, b) =>
              Fs.numVal(a['number']).compareTo(Fs.numVal(b['number'])));
        if (active.isEmpty) return const Center(child: Text('لا توجد طاولات'));
        return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05),
            itemCount: active.length,
            itemBuilder: (context, i) => TableCard(data: active[i]));
      })),
    ]);
  }

  static Future<void> showTableDialog(BuildContext context,
      [Map<String, dynamic>? data]) async {
    final number = TextEditingController(
        text: data?['number']?.toString() ?? '');
    final section = TextEditingController(
        text: data?['section']?.toString() ?? '');
    await showDialog(context: context, builder: (context) =>
        AlertDialog(
          title: Text(data == null ? 'إضافة طاولة' : 'تعديل طاولة'),
          content: Column(mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: number,
                    decoration: const InputDecoration(
                        labelText: 'رقم/اسم الطاولة')),
                const SizedBox(height: 10),
                TextField(controller: section,
                    decoration: const InputDecoration(labelText: 'القسم'))
              ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            FilledButton(onPressed: () async {
              if (number.text
                  .trim()
                  .isEmpty) return;
              final id = data?['id'] ??
                  'table_${number.text.trim().replaceAll(RegExp(r'\s+'), '_')}';
              final baseUrl = await getMenuBaseUrl();
              await Fs.branchCol('tables').doc(id).set({
                'id': id,
                'tenantId': tenantId,
                'branchId': branchId,
                'number': number.text.trim(),
                'section': section.text.trim(),
                'status': data?['status'] ?? 'available',
                'isActive': true,
                'qrCodeUrl': '$baseUrl/#/menu/$tenantId/$branchId/$id',
                'updatedAt': FieldValue.serverTimestamp()
              }, SetOptions(merge: true));
              await Fs.log(data == null ? 'add_table' : 'edit_table',
                  entityType: 'table', entityId: '$id');
              if (context.mounted) Navigator.pop(context);
            }, child: const Text('حفظ'))
          ],
        ));
  }
}

class TableCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const TableCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final status = '${data['status'] ?? 'available'}';
    final id = '${data['id']}';
    final qr = '${data['qrCodeUrl'] ??
        '$defaultCustomerMenuBaseUrl/#/menu/$tenantId/$branchId/$id'}';
    final color = statusColor(status);
    return AppCard(child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(width: 54,
            height: 54,
            decoration: BoxDecoration(color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(Icons.table_restaurant_rounded, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('طاولة ${data['number']}', style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 20)),
              Text(statusLabel(status),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold))
            ])),
        PopupMenuButton<String>(onSelected: (v) async {
          if (v == 'edit') TablesPage.showTableDialog(context, data);
          if (v == 'copy') {
            await Clipboard.setData(ClipboardData(text: qr));
            if (context.mounted) toast(context, 'تم نسخ الرابط');
          }
          if (v == 'freeze') await Fs.branchCol('tables').doc(id).set(
              {'status': 'frozen', 'isActive': false}, SetOptions(merge: true));
          if (v == 'activate') await Fs.branchCol('tables').doc(id).set(
              {'status': 'available', 'isActive': true},
              SetOptions(merge: true));
          if (v == 'clear') await Fs.branchCol('tables').doc(id).set({
            'status': 'available',
            'activeOrderId': null,
            'isOccupied': false
          }, SetOptions(merge: true));
          if (v == 'delete' && context.mounted &&
              await confirm(context, 'تعطيل هذه الطاولة؟')) await Fs.branchCol(
              'tables').doc(id).set(
              {'deleted': true, 'isActive': false, 'status': 'inactive'},
              SetOptions(merge: true));
        }, itemBuilder: (context) =>
        const [
          PopupMenuItem(value: 'edit', child: Text('تعديل')),
          PopupMenuItem(value: 'copy', child: Text('نسخ QR')),
          PopupMenuItem(value: 'freeze', child: Text('تجميد')),
          PopupMenuItem(value: 'activate', child: Text('تفعيل')),
          PopupMenuItem(value: 'clear', child: Text('تنظيف/إفراغ')),
          PopupMenuItem(value: 'delete', child: Text('حذف منطقي')),
        ]),
      ]),
      const SizedBox(height: 12),
      Expanded(child: Center(child: QrImageView(data: qr,
          version: QrVersions.auto,
          size: 128,
          backgroundColor: Colors.white))),
      const SizedBox(height: 8),
      SelectableText(qr, maxLines: 1,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
    ]));
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'available':
      return const Color(0xFF059669);
    case 'occupied':
    case 'in_kitchen':
      return const Color(0xFFEA580C);
    case 'ready':
    case 'orderReady':
      return const Color(0xFF2563EB);
    case 'waiting_payment':
    case 'unpaid':
      return const Color(0xFFDC2626);
    case 'needs_waiter':
    case 'needsWaiter':
      return const Color(0xFF7C3AED);
    case 'frozen':
    case 'inactive':
      return const Color(0xFF6B7280);
    default:
      return const Color(0xFF9A3412);
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'available':
      return 'فارغة';
    case 'occupied':
      return 'مشغولة';
    case 'in_kitchen':
      return 'في المطبخ';
    case 'sent_to_kitchen':
      return 'مرسل للمطبخ';
    case 'preparing':
      return 'قيد التحضير';
    case 'ready':
    case 'orderReady':
      return 'جاهز';
    case 'waiting_payment':
    case 'unpaid':
      return 'بانتظار الدفع';
    case 'paid':
      return 'مدفوع';
    case 'cancelled':
      return 'ملغي';
    case 'frozen':
      return 'مجمدة';
    case 'inactive':
      return 'غير فعالة';
    case 'needs_waiter':
    case 'needsWaiter':
      return 'طلب نادل';
    case 'pending_cashier_approval':
      return 'ينتظر موافقة الكاشير';
    default:
      return status;
  }
}

String orderTypeLabel(String type) {
  switch (type) {
    case 'dine_in':
      return 'داخل المطعم';
    case 'takeaway':
      return 'سفري';
    case 'delivery':
      return 'توصيل';
    case 'pickup':
      return 'استلام';
    default:
      return type;
  }
}

Future<String> getMenuBaseUrl() async {
  final doc = await Fs.tenantCol('settings').doc('main').get();
  return '${doc.data()?['customerMenuBaseUrl'] ?? defaultCustomerMenuBaseUrl}'
      .trim();
}

// ───────────────────────── Orders/Kitchen ─────────────────────────
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) => OrderList(mode: 'orders');
}

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) => OrderList(mode: 'kitchen');
}

class OrderList extends StatelessWidget {
  final String mode;

  const OrderList({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final kitchen = mode == 'kitchen';
    Query<Map<String, dynamic>> q = Fs.orders.where(
        'tenantId', isEqualTo: tenantId);
    return DataStream(stream: q.snapshots(), builder: (orders) {
      var rows = orders;
      rows.sort((a, b) =>
          (Fs.date(b['createdAt']) ?? DateTime(1970)).compareTo(
              Fs.date(a['createdAt']) ?? DateTime(1970)));
      if (kitchen) rows = rows
          .where((o) =>
          ['sent_to_kitchen', 'pending', 'preparing'].contains(o['status']))
          .toList();
      if (rows.isEmpty) return Center(child: Text(t(context, 'empty')));
      return ListView.separated(itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              OrderCard(data: rows[i], kitchen: kitchen));
    });
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool kitchen;

  const OrderCard({super.key, required this.data, required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final id = '${data['id']}';
    final status = '${data['status'] ?? 'open'}';
    final items = ((data['items'] as List?) ?? const [])
        .whereType<Map>()
        .toList();
    return AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${data['orderNumber'] ?? id}', style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(width: 8),
            Chip(label: Text(statusLabel(status)),
                backgroundColor: statusColor(status).withOpacity(.12),
                side: BorderSide(color: statusColor(status).withOpacity(.3))),
            if (data['tableNumber'] != null) Chip(
                label: Text('طاولة ${data['tableNumber']}')),
            Chip(label: Text(orderTypeLabel('${data['orderType'] ?? ''}'))),
            const Spacer(),
            Text(Fs.money(Fs.numVal(data['totalAmount'] ?? data['total'])),
                style: const TextStyle(fontWeight: FontWeight.w900,
                    color: Color(0xFF9A3412),
                    fontSize: 18)),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8,
              runSpacing: 8,
              children: items
                  .map((it) =>
                  Chip(label: Text('${it['quantity']}× ${it['productName']}')))
                  .toList()),
          if ('${data['notes'] ?? ''}'
              .trim()
              .isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8),
              child: Text('📝 ${data['notes']}')),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (status == 'pending_cashier_approval') FilledButton.icon(
                onPressed: () =>
                    updateOrderStatus(context, id, 'sent_to_kitchen',
                        tableId: data['tableId']),
                icon: const Icon(Icons.check_rounded),
                label: const Text('قبول وإرسال للمطبخ')),
            if (status == 'sent_to_kitchen' ||
                status == 'pending') OutlinedButton(onPressed: () =>
                updateOrderStatus(
                    context, id, 'preparing', tableId: data['tableId']),
                child: const Text('بدء التحضير')),
            if (status == 'preparing') FilledButton(onPressed: () =>
                updateOrderStatus(
                    context, id, 'ready', tableId: data['tableId']),
                child: const Text('جاهز')),
            if (!['paid', 'cancelled'].contains(status)) OutlinedButton(
                onPressed: () => payExisting(context, id, 'cash', data),
                child: const Text('دفع كاش')),
            if (!['paid', 'cancelled'].contains(status)) OutlinedButton(
                onPressed: () => payExisting(context, id, 'card', data),
                child: const Text('دفع بطاقة')),
            if (!['paid', 'cancelled'].contains(status)) TextButton(
                onPressed: () => cancelOrder(context, id, data),
                child: const Text('إلغاء')),
          ]),
        ]));
  }
}

Future<void> updateOrderStatus(BuildContext context, String id, String status,
    {dynamic tableId}) async {
  try {
    await Fs.db.runTransaction((tx) async {
      final orderRef = Fs.orders.doc(id);
      final orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) throw Exception('الطلب غير موجود');
      final old = orderSnap.data() ?? {};
      if (['paid', 'cancelled', 'refunded'].contains('${old['status']}') &&
          status != '${old['status']}') {
        throw Exception('لا يمكن تعديل طلب مغلق');
      }
      tx.update(orderRef,
          {'status': status, 'updatedAt': FieldValue.serverTimestamp()});
      if (tableId != null && '$tableId'.isNotEmpty) {
        final tableStatus = {
          'sent_to_kitchen': 'in_kitchen',
          'preparing': 'in_kitchen',
          'ready': 'waiting_payment',
          'paid': 'available',
          'cancelled': 'available'
        }[status] ?? 'occupied';
        tx.set(Fs.branchCol('tables').doc('$tableId'), {
          'status': tableStatus,
          'lastStatusUpdate': FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
      }
    });
    await Fs.log('update_order_status', entityType: 'order',
        entityId: id,
        details: {'status': status});
    if (context.mounted) toast(context, 'تم تحديث الحالة');
  } catch (e) {
    if (context.mounted) toast(context, '$e', error: true);
  }
}

Future<void> payExisting(BuildContext context, String id, String method,
    Map<String, dynamic> order) async {
  try {
    final total = Fs.numVal(order['totalAmount'] ?? order['total']);
    final shift = await Fs.openShift();
    await Fs.db.runTransaction((tx) async {
      final orderRef = Fs.orders.doc(id);
      final snap = await tx.get(orderRef);
      if (!snap.exists) throw Exception('الطلب غير موجود');
      final current = snap.data() ?? {};
      if (current['isPaid'] == true ||
          '${current['status']}' == 'paid') throw Exception(
          'هذا الطلب مدفوع مسبقًا');
      tx.update(orderRef, {
        'status': 'paid',
        'isPaid': true,
        'paymentStatus': 'paid',
        'paymentMethod': method,
        'shiftId': shift?.id,
        'paidAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp()
      });
      tx.set(Fs.payments.doc(), {
        'tenantId': tenantId,
        'orderId': id,
        'shiftId': shift?.id,
        'paymentMethod': method,
        'amount': total,
        'paidAt': FieldValue.serverTimestamp()
      });
      final tableId = current['tableId'] ?? order['tableId'];
      if (tableId != null && '$tableId'.isNotEmpty) tx.set(
          Fs.branchCol('tables').doc('$tableId'), {
        'status': 'available',
        'activeOrderId': null,
        'isOccupied': false,
        'lastStatusUpdate': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      if (shift != null) tx.set(
          shift.reference, Fs.paymentShiftDelta(method, total),
          SetOptions(merge: true));
    });
    await Fs.log('payment', entityType: 'order',
        entityId: id,
        details: {'method': method, 'total': total, 'shiftId': shift?.id});
    if (context.mounted) toast(context, 'تم الدفع');
  } catch (e) {
    if (context.mounted) toast(context, '$e', error: true);
  }
}

Future<void> cancelOrder(BuildContext context, String id,
    Map<String, dynamic> order) async {
  final reason = await promptText(
      context, title: 'سبب الإلغاء', label: 'السبب');
  if (reason == null) return;
  try {
    await Fs.db.runTransaction((tx) async {
      final orderRef = Fs.orders.doc(id);
      final snap = await tx.get(orderRef);
      if (!snap.exists) throw Exception('الطلب غير موجود');
      final current = snap.data() ?? {};
      if (current['isPaid'] == true ||
          '${current['status']}' == 'paid') throw Exception(
          'الطلب مدفوع؛ استخدم الاسترجاع بدل الإلغاء');
      tx.update(orderRef, {
        'status': 'cancelled',
        'cancelReason': reason,
        'updatedAt': FieldValue.serverTimestamp()
      });
      final tableId = current['tableId'] ?? order['tableId'];
      if (tableId != null && '$tableId'.isNotEmpty) tx.set(
          Fs.branchCol('tables').doc('$tableId'), {
        'status': 'available',
        'activeOrderId': null,
        'isOccupied': false,
        'lastStatusUpdate': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    });
    await Fs.log('cancel_order', entityType: 'order',
        entityId: id,
        details: {'reason': reason});
    if (context.mounted) toast(context, 'تم إلغاء الطلب');
  } catch (e) {
    if (context.mounted) toast(context, '$e', error: true);
  }
}

// ───────────────────────── Products / Categories / Modifiers ─────────────────────────
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Row(children: [
          FilledButton.icon(onPressed: () => showProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج')),
          const SizedBox(width: 8),
          OutlinedButton.icon(onPressed: () => showCategoryDialog(context),
              icon: const Icon(Icons.category_rounded),
              label: const Text('إضافة تصنيف')),
          const Spacer()
        ]),
        const SizedBox(height: 12),
        Expanded(child: DataStream(
            stream: Fs.tenantCol('menu_items').snapshots(), builder: (items) {
          items.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
          if (items.isEmpty) return Center(child: Text(t(context, 'empty')));
          return DataTableView(columns: const [
            'المنتج',
            'التصنيف',
            'السعر',
            'الحالة',
            'إجراءات'
          ], rows: items.map((p) =>
          [
            Text('${p['name']}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            Text('${p['categoryId'] ?? 'uncategorized'}'),
            Text(Fs.money(Fs.numVal(p['price']))),
            Chip(label: Text(
                (p['isAvailable'] != false && p['isSoldOut'] != true)
                    ? 'متاح'
                    : 'غير متاح')),
            Wrap(spacing: 4,
                children: [
                  IconButton(onPressed: () =>
                      showProductDialog(context, p), icon: const Icon(Icons
                      .edit)),
                  IconButton(onPressed: () => toggleProduct(p),
                      icon: Icon((p['isAvailable'] != false &&
                          p['isSoldOut'] != true) ? Icons.pause : Icons
                          .play_arrow)),
                  IconButton(onPressed: () => softDeleteProduct(context, p),
                      icon: const Icon(Icons.delete_outline, color: Color(
                          0xFFDC2626)))
                ])
          ]).toList());
        })),
      ]);
}

Future<void> showCategoryDialog(BuildContext context) async {
  final name = TextEditingController();
  await showDialog(context: context, builder: (context) =>
      AlertDialog(
        title: const Text('إضافة تصنيف'),
        content: TextField(controller: name,
            decoration: const InputDecoration(labelText: 'اسم التصنيف')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(onPressed: () async {
            if (name.text
                .trim()
                .isEmpty) return;
            final id = 'cat_${uuid.v4().substring(0, 8)}';
            await Fs.tenantCol('categories').doc(id).set({
              'id': id,
              'tenantId': tenantId,
              'name': name.text.trim(),
              'displayOrder': DateTime
                  .now()
                  .millisecondsSinceEpoch,
              'isVisible': true
            });
            await Fs.log('add_category', entityType: 'category', entityId: id);
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('حفظ'))
        ],
      ));
}

Future<void> showProductDialog(BuildContext context,
    [Map<String, dynamic>? p]) async {
  final name = TextEditingController(text: p?['name']?.toString() ?? '');
  final price = TextEditingController(text: p?['price']?.toString() ?? '');
  final desc = TextEditingController(text: p?['description']?.toString() ?? '');
  String? cat = p?['categoryId']?.toString();
  bool visible = p?['isVisible'] != false;
  await showDialog(context: context, builder: (context) =>
      StatefulBuilder(builder: (context, setState) =>
          AlertDialog(
            title: Text(p == null ? 'إضافة منتج' : 'تعديل منتج'),
            content: SizedBox(width: 420,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(controller: name,
                      decoration: const InputDecoration(
                          labelText: 'اسم المنتج')),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: Fs.tenantCol('categories').snapshots(),
                      builder: (context, snap) {
                        final cats = snap.data?.docs.map((d) =>
                        {
                          ...d.data(),
                          'id': d.id
                        }).toList() ?? [];
                        return DropdownButtonFormField<String>(value: cat,
                            decoration: const InputDecoration(
                                labelText: 'التصنيف'),
                            items: cats.map((c) =>
                                DropdownMenuItem(value: '${c['id']}',
                                    child: Text('${c['name']}'))).toList(),
                            onChanged: (v) => setState(() => cat = v));
                      }),
                  const SizedBox(height: 10),
                  TextField(controller: price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السعر')),
                  const SizedBox(height: 10),
                  TextField(controller: desc,
                      decoration: const InputDecoration(labelText: 'الوصف')),
                  CheckboxListTile(value: visible,
                      title: const Text('يظهر في الكاشير و QR'),
                      onChanged: (v) => setState(() => visible = v ?? true)),
                ])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              FilledButton(onPressed: () async {
                final n = name.text.trim();
                final pr = Fs.numVal(price.text);
                if (n.isEmpty || pr < 0) return;
                final id = p?['id'] ??
                    'p_${uuid.v4().replaceAll('-', '').substring(0, 8)}';
                await Fs.tenantCol('menu_items').doc('$id').set({
                  'id': id,
                  'tenantId': tenantId,
                  'name': n,
                  'description': desc.text.trim(),
                  'price': pr,
                  'categoryId': cat ?? 'uncategorized',
                  'isVisible': visible,
                  'isAvailable': true,
                  'isSoldOut': false,
                  'updatedAt': FieldValue.serverTimestamp()
                }, SetOptions(merge: true));
                await Fs.log(p == null ? 'add_product' : 'edit_product',
                    entityType: 'product', entityId: '$id');
                if (context.mounted) Navigator.pop(context);
              }, child: const Text('حفظ'))
            ],
          )));
}

Future<void> toggleProduct(Map<String, dynamic> p) async {
  final active = p['isAvailable'] != false && p['isSoldOut'] != true;
  await Fs.tenantCol('menu_items').doc('${p['id']}').set({
    'isAvailable': !active,
    'isSoldOut': active,
    'updatedAt': FieldValue.serverTimestamp()
  }, SetOptions(merge: true));
  await Fs.log('toggle_product', entityType: 'product',
      entityId: '${p['id']}',
      details: {'active': !active});
}

Future<void> softDeleteProduct(BuildContext context,
    Map<String, dynamic> p) async {
  if (!await confirm(context, 'حذف المنتج من البيع؟')) return;
  await Fs.tenantCol('menu_items').doc('${p['id']}').set(
      {'deleted': true, 'isVisible': false, 'isAvailable': false},
      SetOptions(merge: true));
  await Fs.log('delete_product', entityType: 'product', entityId: '${p['id']}');
}

class ModifiersPage extends StatelessWidget {
  const ModifiersPage({super.key});

  @override
  Widget build(BuildContext context) =>
      SimpleCrudPage(
        title: 'الإضافات',
        collection: 'modifiers',
        fields: const [
          CrudField('name', 'اسم الإضافة'),
          CrudField('extraPrice', 'السعر الإضافي', number: true),
          CrudField('productId', 'معرّف المنتج/اختياري')
        ],
        columns: const ['name', 'extraPrice', 'productId'],
      );
}

// ───────────────────────── Inventory Purchases Suppliers Expenses ─────────────────────────
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) =>
      SimpleCrudPage(
        title: 'المخزون',
        collection: 'inventory_items',
        fields: const [
          CrudField('name', 'اسم المادة'),
          CrudField('unit', 'الوحدة'),
          CrudField('quantity', 'الكمية', number: true),
          CrudField('minQuantity', 'حد التنبيه', number: true),
          CrudField('lastPurchasePrice', 'آخر سعر شراء', number: true)
        ],
        columns: const ['name', 'unit', 'quantity', 'minQuantity'],
        statusField: 'status',
      );
}

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) =>
      SimpleCrudPage(title: 'الموردين',
          collection: 'suppliers',
          fields: const [
            CrudField('name', 'اسم المورد'),
            CrudField('phone', 'الهاتف'),
            CrudField('address', 'العنوان'),
            CrudField('notes', 'ملاحظات')
          ],
          columns: const ['name', 'phone', 'address', 'notes']);
}

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) =>
      SimpleCrudPage(title: 'المصاريف',
          collection: 'expenses',
          fields: const [
            CrudField('title', 'نوع المصروف'),
            CrudField('amount', 'المبلغ', number: true),
            CrudField('paymentMethod', 'طريقة الدفع'),
            CrudField('note', 'ملاحظة')
          ],
          columns: const ['title', 'amount', 'paymentMethod', 'createdAt'],
          logAction: 'expense');
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Row(children: [
          FilledButton.icon(onPressed: () => showPurchaseDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة فاتورة شراء'))
        ]),
        const SizedBox(height: 12),
        Expanded(child: DataStream(
            stream: Fs.tenantCol('purchases').snapshots(), builder: (items) {
          items.sort((a, b) =>
              (Fs.date(b['createdAt']) ?? DateTime(1970)).compareTo(
                  Fs.date(a['createdAt']) ?? DateTime(1970)));
          return DataTableView(columns: const [
            'المادة',
            'الكمية',
            'سعر الوحدة',
            'الإجمالي',
            'الدفع'
          ],
              rows: items.map((p) =>
              [
                Text('${p['inventoryItemName'] ?? p['inventoryItemId']}'),
                Text('${p['quantity']}'),
                Text(Fs.money(Fs.numVal(p['unitPrice']))),
                Text(Fs.money(Fs.numVal(p['total']))),
                Text('${p['paymentMethod']}')
              ]).toList());
        })),
      ]);
}

Future<void> showPurchaseDialog(BuildContext context) async {
  String? invId;
  String? invName;
  final qty = TextEditingController(text: '1');
  final unit = TextEditingController(text: '0');
  String method = 'cash';
  await showDialog(context: context, builder: (context) =>
      StatefulBuilder(builder: (context, setState) =>
          AlertDialog(
            title: const Text('إضافة فاتورة شراء'),
            content: SizedBox(width: 420,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: Fs.tenantCol('inventory_items').snapshots(),
                      builder: (context, snap) {
                        final inv = snap.data?.docs.map((d) =>
                        {
                          ...d.data(),
                          'id': d.id
                        }).toList() ?? [];
                        return DropdownButtonFormField<String>(value: invId,
                            decoration: const InputDecoration(
                                labelText: 'المادة'),
                            items: inv
                                .map((i) =>
                                DropdownMenuItem(value: '${i['id']}',
                                    child: Text(
                                        '${i['name']} (${i['unit'] ?? ''})')))
                                .toList(),
                            onChanged: (v) {
                              final item = inv.firstWhere((e) => e['id'] == v);
                              setState(() {
                                invId = v;
                                invName = '${item['name']}';
                              });
                            });
                      }),
                  const SizedBox(height: 10),
                  TextField(controller: qty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الكمية')),
                  const SizedBox(height: 10),
                  TextField(controller: unit,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'سعر الوحدة')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(value: method,
                      decoration: const InputDecoration(
                          labelText: 'طريقة الدفع'),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('كاش')),
                        DropdownMenuItem(value: 'card', child: Text('بطاقة')),
                        DropdownMenuItem(value: 'credit', child: Text('آجل'))
                      ],
                      onChanged: (v) => setState(() => method = '$v')),
                ])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              FilledButton(onPressed: () async {
                if (invId == null) return;
                final q = Fs.numVal(qty.text);
                final u = Fs.numVal(unit.text);
                if (q <= 0 || u < 0) return;
                final total = q * u;
                final id = Fs.id('purchase');
                final batch = Fs.db.batch();
                batch.set(Fs.tenantCol('purchases').doc(id), {
                  'id': id,
                  'tenantId': tenantId,
                  'inventoryItemId': invId,
                  'inventoryItemName': invName,
                  'quantity': q,
                  'unitPrice': u,
                  'total': total,
                  'paymentMethod': method,
                  'createdAt': FieldValue.serverTimestamp()
                });
                batch.set(Fs.tenantCol('inventory_items').doc(invId), {
                  'quantity': FieldValue.increment(q),
                  'lastPurchasePrice': u,
                  'updatedAt': FieldValue.serverTimestamp()
                }, SetOptions(merge: true));
                await batch.commit();
                await Fs.log('add_purchase', entityType: 'purchase',
                    entityId: id,
                    details: {'invId': invId, 'qty': q, 'total': total});
                if (context.mounted) Navigator.pop(context);
              }, child: const Text('حفظ'))
            ],
          )));
}

// ───────────────────────── Shift Reports Settings Logs Waiters ─────────────────────────
class ShiftPage extends StatelessWidget {
  const ShiftPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Row(children: [
          FilledButton.icon(onPressed: () => openShift(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('فتح وردية')),
          const SizedBox(width: 8),
          OutlinedButton.icon(onPressed: () => closeShift(context),
              icon: const Icon(Icons.stop),
              label: const Text('إغلاق وردية'))
        ]),
        const SizedBox(height: 12),
        Expanded(child: DataStream(
            stream: Fs.tenantCol('cash_sessions').snapshots(),
            builder: (items) {
              items.sort((a, b) =>
                  (Fs.date(b['openedAt']) ?? DateTime(1970)).compareTo(
                      Fs.date(a['openedAt']) ?? DateTime(1970)));
              return DataTableView(columns: const [
                'الحالة',
                'رصيد البداية',
                'الفعلي',
                'الفرق',
                'فتح',
                'إغلاق'
              ],
                  rows: items.map((s) =>
                  [
                    Text('${s['status']}'),
                    Text(Fs.money(Fs.numVal(s['openingBalance']))),
                    Text(Fs.money(Fs.numVal(s['actualCash']))),
                    Text(Fs.money(Fs.numVal(s['difference']))),
                    Text(Fs.dateText(s['openedAt'])),
                    Text(Fs.dateText(s['closedAt']))
                  ]).toList());
            })),
      ]);
}

Future<void> openShift(BuildContext context) async {
  final amount = await promptNumber(
      context, title: 'فتح وردية', label: 'رصيد بداية الصندوق');
  if (amount == null) return;
  final id = Fs.id('shift');
  await Fs.tenantCol('cash_sessions').doc(id).set({
    'id': id,
    'tenantId': tenantId,
    'userId': FirebaseAuth.instance.currentUser?.uid,
    'openingBalance': amount,
    'status': 'open',
    'openedAt': FieldValue.serverTimestamp()
  });
  await Fs.log('open_shift', entityType: 'cash_session', entityId: id);
}

Future<void> closeShift(BuildContext context) async {
  final actual = await promptNumber(
      context, title: 'إغلاق وردية', label: 'المبلغ الفعلي في الصندوق');
  if (actual == null) return;
  final snap = await Fs.tenantCol('cash_sessions').where(
      'status', isEqualTo: 'open').limit(1).get();
  if (snap.docs.isEmpty) {
    if (context.mounted) toast(context, 'لا توجد وردية مفتوحة', error: true);
    return;
  }
  final shift = snap.docs.first;
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day);
  final payments = await Fs.payments
      .where('tenantId', isEqualTo: tenantId)
      .get();
  final cash = payments.docs.where((d) {
    final data = d.data();
    final paidAt = Fs.date(data['paidAt']);
    return data['paymentMethod'] == 'cash' && paidAt != null &&
        !paidAt.isBefore(start);
  }).fold<double>(0, (s, d) => s + Fs.numVal(d.data()['amount']));
  final expenses = await Fs.tenantCol('expenses').get();
  final exp = expenses.docs.where((d) {
    final data = d.data();
    final createdAt = Fs.date(data['createdAt']);
    return data['paymentMethod'] == 'cash' && createdAt != null &&
        !createdAt.isBefore(start);
  }).fold<double>(0, (s, d) => s + Fs.numVal(d.data()['amount']));
  final opening = Fs.numVal(shift.data()['openingBalance']);
  final expected = opening + cash - exp;
  await shift.reference.set({
    'status': 'closed',
    'actualCash': actual,
    'cashSales': cash,
    'expensesTotal': exp,
    'expectedCash': expected,
    'difference': actual - expected,
    'closedAt': FieldValue.serverTimestamp()
  }, SetOptions(merge: true));
  await Fs.log('close_shift', entityType: 'cash_session',
      entityId: shift.id,
      details: {'expected': expected, 'actual': actual});
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) => const DashboardPage();
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => SettingsForm();
}

class SettingsForm extends StatefulWidget {
  @override State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final restaurant = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final currency = TextEditingController(text: '₺');
  final base = TextEditingController(text: defaultCustomerMenuBaseUrl);
  final tax = TextEditingController(text: '0');
  bool loaded = false;

  @override Widget build(BuildContext context) =>
      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: loaded ? null : Fs.tenantCol('settings').doc('main').get(),
          builder: (context, snap) {
            if (!loaded && snap.hasData) {
              final d = snap.data!.data() ?? {};
              restaurant.text = '${d['restaurantName'] ?? ''}';
              phone.text = '${d['phone'] ?? ''}';
              address.text = '${d['address'] ?? ''}';
              currency.text = '${d['currency'] ?? '₺'}';
              base.text =
              '${d['customerMenuBaseUrl'] ?? defaultCustomerMenuBaseUrl}';
              tax.text = '${d['taxRate'] ?? 0}';
              loaded = true;
            }
            return AppCard(child: ListView(children: [
              TextField(controller: restaurant,
                  decoration: const InputDecoration(labelText: 'اسم المطعم')),
              const SizedBox(height: 10),
              TextField(controller: phone,
                  decoration: const InputDecoration(labelText: 'الهاتف')),
              const SizedBox(height: 10),
              TextField(controller: address,
                  decoration: const InputDecoration(labelText: 'العنوان')),
              const SizedBox(height: 10),
              TextField(controller: currency,
                  decoration: const InputDecoration(labelText: 'العملة')),
              const SizedBox(height: 10),
              TextField(controller: tax,
                  decoration: const InputDecoration(labelText: 'نسبة الضريبة')),
              const SizedBox(height: 10),
              TextField(controller: base,
                  decoration: const InputDecoration(
                      labelText: 'رابط تطبيق QR للعميل')),
              const SizedBox(height: 14),
              FilledButton(onPressed: () async {
                await Fs.tenantCol('settings').doc('main').set({
                  'restaurantName': restaurant.text.trim(),
                  'phone': phone.text.trim(),
                  'address': address.text.trim(),
                  'currency': currency.text.trim(),
                  'taxRate': Fs.numVal(tax.text),
                  'customerMenuBaseUrl': base.text.trim()
                }, SetOptions(merge: true));
                await Fs.log('update_settings');
                if (context.mounted) toast(context, 'تم حفظ الإعدادات');
              }, child: const Text('حفظ'))
            ]));
          });
}

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      DataStream(
          stream: Fs.tenantCol('activity_logs').snapshots(), builder: (logs) {
        logs.sort((a, b) =>
            (Fs.date(b['createdAt']) ?? DateTime(1970)).compareTo(
                Fs.date(a['createdAt']) ?? DateTime(1970)));
        return DataTableView(
            columns: const ['العملية', 'المستخدم', 'الكيان', 'التاريخ'],
            rows: logs.map((l) =>
            [
              Text('${l['action']}'),
              Text('${l['userEmail'] ?? ''}'),
              Text('${l['entityType'] ?? ''} ${l['entityId'] ?? ''}'),
              Text(Fs.dateText(l['createdAt']))
            ]).toList());
      });
}

class WaitersPage extends StatelessWidget {
  const WaitersPage({super.key});

  @override
  Widget build(BuildContext context) =>
      SimpleCrudPage(title: 'الجراسين',
          collection: 'waiters',
          fields: const [
            CrudField('name', 'الاسم'),
            CrudField('phone', 'الهاتف'),
            CrudField('isOnline', 'متصل؟ true/false')
          ],
          columns: const ['name', 'phone', 'isOnline', 'lastSeenAt']);
}

class WaiterCallsPage extends StatelessWidget {
  const WaiterCallsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      DataStream(
          stream: Fs.tenantCol('waiter_calls').snapshots(), builder: (calls) {
        calls.sort((a, b) =>
            (Fs.date(b['requestedAt']) ?? DateTime(1970)).compareTo(
                Fs.date(a['requestedAt']) ?? DateTime(1970)));
        if (calls.isEmpty)
          return const Center(child: Text('لا توجد طلبات نادل'));
        return ListView.separated(itemCount: calls.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final c = calls[i];
              return AppCard(child: Row(children: [
                const Icon(Icons.notifications_active_rounded,
                    color: Color(0xFF7C3AED)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('طاولة ${c['tableNumber'] ?? c['tableId']}',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      Text('الحالة: ${c['status']} — ${Fs.dateText(
                          c['requestedAt'])}')
                    ])),
                FilledButton.tonal(onPressed: () async {
                  await Fs.tenantCol('waiter_calls').doc('${c['id']}').set({
                    'status': 'done',
                    'doneAt': FieldValue.serverTimestamp()
                  }, SetOptions(merge: true));
                  final table = c['tableId'];
                  if (table != null) await Fs
                      .branchCol('tables')
                      .doc('$table')
                      .set({'status': 'occupied'}, SetOptions(merge: true));
                }, child: const Text('تمت المعالجة'))
              ]));
            });
      });
}

// ───────────────────────── Simple CRUD ─────────────────────────
class CrudField {
  final String key;
  final String label;
  final bool number;

  const CrudField(this.key, this.label, {this.number = false});
}

class SimpleCrudPage extends StatelessWidget {
  final String title;
  final String collection;
  final List<CrudField> fields;
  final List<String> columns;
  final String? statusField;
  final String? logAction;

  const SimpleCrudPage(
      {super.key, required this.title, required this.collection, required this.fields, required this.columns, this.statusField, this.logAction});

  @override
  Widget build(BuildContext context) =>
      Column(children: [
        Row(children: [
          FilledButton.icon(onPressed: () => showCrudDialog(context),
              icon: const Icon(Icons.add),
              label: Text('إضافة $title'))
        ]),
        const SizedBox(height: 12),
        Expanded(child: DataStream(
            stream: Fs.tenantCol(collection).snapshots(), builder: (items) {
          final active = items.where((i) =>
          i['deleted'] != true && i['status'] != 'deleted').toList();
          if (active.isEmpty) return Center(child: Text(t(context, 'empty')));
          return DataTableView(
              columns: [...columns, 'إجراءات'], rows: active.map((d) =>
          [
            ...columns.map((c) =>
                Text(c.toLowerCase().contains('amount') || c
                    .toLowerCase()
                    .contains('price') ? Fs.money(Fs.numVal(d[c])) : c
                    .toLowerCase()
                    .contains('at') ? Fs.dateText(d[c]) : '${d[c] ?? ''}')),
            Wrap(spacing: 4,
                children: [
                  IconButton(onPressed: () =>
                      showCrudDialog(context, d), icon: const Icon(Icons.edit)),
                  IconButton(onPressed: () => softDelete(context, d),
                      icon: const Icon(Icons.delete_outline, color: Color(
                          0xFFDC2626)))
                ])
          ]).toList());
        })),
      ]);

  Future<void> showCrudDialog(BuildContext context,
      [Map<String, dynamic>? data]) async {
    final ctrls = {
      for (final f in fields) f.key: TextEditingController(
          text: data?[f.key]?.toString() ?? '')
    };
    await showDialog(context: context, builder: (context) =>
        AlertDialog(
          title: Text(data == null ? 'إضافة $title' : 'تعديل $title'),
          content: SizedBox(width: 440,
              child: SingleChildScrollView(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: fields
                      .map((f) =>
                      Padding(padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(controller: ctrls[f.key],
                              keyboardType: f.number
                                  ? TextInputType.number
                                  : null,
                              decoration: InputDecoration(labelText: f.label))))
                      .toList()))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            FilledButton(onPressed: () async {
              final id = data?['id'] ?? Fs.id(collection);
              final map = <String, dynamic>{
                'id': id,
                'tenantId': tenantId,
                'updatedAt': FieldValue.serverTimestamp()
              };
              for (final f in fields) {
                map[f.key] =
                f.number ? Fs.numVal(ctrls[f.key]!.text) : ctrls[f.key]!.text
                    .trim();
              }
              if (data == null) map['createdAt'] = FieldValue.serverTimestamp();
              if (statusField != null && data == null)
                map[statusField!] = 'active';
              await Fs.tenantCol(collection).doc('$id').set(
                  map, SetOptions(merge: true));
              await Fs.log(logAction ??
                  (data == null ? 'add_$collection' : 'edit_$collection'),
                  entityType: collection, entityId: '$id');
              if (context.mounted) Navigator.pop(context);
            }, child: const Text('حفظ'))
          ],
        ));
  }

  Future<void> softDelete(BuildContext context,
      Map<String, dynamic> data) async {
    if (!await confirm(context, 'تعطيل/حذف هذا السجل؟')) return;
    await Fs.tenantCol(collection).doc('${data['id']}').set(
        {'deleted': true, 'status': 'deleted'}, SetOptions(merge: true));
    await Fs.log('delete_$collection', entityType: collection,
        entityId: '${data['id']}');
  }
}

class DataTableView extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;

  const DataTableView({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return Center(child: Text(t(context, 'empty')));
    return AppCard(child: Scrollbar(child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(child: DataTable(columns: columns
            .map((c) =>
            DataColumn(label: Text(
                c, style: const TextStyle(fontWeight: FontWeight.w900))))
            .toList(),
            rows: rows.map((r) =>
                DataRow(cells: r.map((w) => DataCell(w)).toList())).toList()))))
    );
    }
}

Future<String?> promptText(BuildContext context,
    {required String title, required String label}) async {
  final c = TextEditingController();
  return showDialog<String>(context: context,
      builder: (context) =>
          AlertDialog(title: Text(title),
              content: TextField(
                  controller: c, decoration: InputDecoration(labelText: label)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, c.text.trim()),
                    child: const Text('تأكيد'))
              ]));
}

Future<double?> promptNumber(BuildContext context,
    {required String title, required String label}) async {
  final v = await promptText(context, title: title, label: label);
  if (v == null) return null;
  return double.tryParse(v.replaceAll(',', '.'));
}
