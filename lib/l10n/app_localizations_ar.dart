// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'عمليات الموظفين';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get waiter => 'نادل';

  @override
  String get kitchen => 'مطبخ';

  @override
  String get cashier => 'صراف';

  @override
  String get admin => 'مدير';

  @override
  String get diagnostics => 'التشخيص';

  @override
  String get errorOccurred => 'حدث خطأ ما';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cashierCheckout => 'الصراف - الدفع';

  @override
  String get selectOrder => 'اختر طلباً لعرض التفاصيل';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get total => 'المجموع';

  @override
  String get cash => 'نقدي';

  @override
  String get card => 'بطاقة';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح';

  @override
  String processingPayment(String method) {
    return 'جاري معالجة الدفع بـ $method...';
  }

  @override
  String tableNumber(String number) {
    return 'طاولة $number';
  }

  @override
  String orderId(String id) {
    return 'طلب رقم $id';
  }

  @override
  String get currency => 'ر.س';

  @override
  String get waiterMode => 'وضع النادل - الطاولات النشطة';

  @override
  String get available => 'متاح';

  @override
  String get kitchenDisplay => 'شاشة المطبخ (KDS)';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get cooking => 'قيد الطبخ';

  @override
  String get ready => 'جاهز';

  @override
  String get start => 'بدء';

  @override
  String get readyAction => 'جاهز';

  @override
  String get bump => 'إكمال';

  @override
  String minutesShort(int minutes) {
    return '$minutes د';
  }

  @override
  String get printReceipt => 'طباعة الفاتورة';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get all => 'الكل';

  @override
  String get noItemsFound => 'لم يتم العثور على أصناف في هذه الفئة';

  @override
  String get currentOrder => 'الطلب الحالي';

  @override
  String get dineIn => 'تناول داخلي';

  @override
  String get cartEmpty => 'السلة فارغة';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get vat => 'الضريبة (15%)';

  @override
  String get orderSent => 'تم إرسال الطلب للمطبخ';

  @override
  String get sendToKitchen => 'إرسال للمطبخ';

  @override
  String addProductToOrder(String name, String price) {
    return 'إضافة $name للطلب، السعر $price';
  }

  @override
  String removeItem(String name) {
    return 'إزالة $name';
  }

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusPreparing => 'قيد التحضير';

  @override
  String get statusReady => 'جاهز';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusPaid => 'تم الدفع';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusRefunded => 'مسترجع';
}
