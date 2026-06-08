// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Staff Operations';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get waiter => 'Waiter';

  @override
  String get kitchen => 'Kitchen';

  @override
  String get cashier => 'Cashier';

  @override
  String get admin => 'Admin';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get cashierCheckout => 'Cashier - Checkout';

  @override
  String get selectOrder => 'Select an order to view details';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get total => 'Total';

  @override
  String get cash => 'CASH';

  @override
  String get card => 'CARD';

  @override
  String get paymentSuccessful => 'Payment Successful';

  @override
  String processingPayment(String method) {
    return 'Processing $method payment...';
  }

  @override
  String tableNumber(String number) {
    return 'Table $number';
  }

  @override
  String orderId(String id) {
    return 'Order #$id';
  }

  @override
  String get currency => 'SAR';

  @override
  String get waiterMode => 'Waiter Mode - Active Tables';

  @override
  String get available => 'Available';

  @override
  String get kitchenDisplay => 'Kitchen Display (KDS)';

  @override
  String get pending => 'Pending';

  @override
  String get cooking => 'Cooking';

  @override
  String get ready => 'Ready';

  @override
  String get start => 'START';

  @override
  String get readyAction => 'READY';

  @override
  String get bump => 'BUMP';

  @override
  String minutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get newOrder => 'New Order';

  @override
  String get all => 'All';

  @override
  String get noItemsFound => 'No items found in this category';

  @override
  String get currentOrder => 'Current Order';

  @override
  String get dineIn => 'Dine-in';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get vat => 'VAT (15%)';

  @override
  String get orderSent => 'Order sent to kitchen';

  @override
  String get sendToKitchen => 'SEND TO KITCHEN';

  @override
  String addProductToOrder(String name, String price) {
    return 'Add $name to order, price $price';
  }

  @override
  String removeItem(String name) {
    return 'Remove $name';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRefunded => 'Refunded';
}
