import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:staff_ops_app/l10n/app_localizations.dart';

final selectedOrderIdProvider = StateProvider<String?>((ref) => null);

class CashierScreen extends ConsumerWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(ordersStreamProvider);
    final selectedOrderId = ref.watch(selectedOrderIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cashierCheckout)),
      body: AsyncValueWidget(
        value: ordersAsync,
        data: (orders) {
          final activeOrders = orders
              .where((o) => o.status != OrderStatus.paid && o.status != OrderStatus.cancelled)
              .toList();

          return Row(
            children: [
              // Active Orders List
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = activeOrders[index];
                    return ListTile(
                      selected: selectedOrderId == order.id,
                      title: Text(order.tableNumber != null
                          ? l10n.tableNumber(order.tableNumber!.toString())
                          : l10n.orderId(order.id.substring(order.id.length - 4))),
                      subtitle: Text('${l10n.total}: ${order.totalAmount.toStringAsFixed(2)} ${l10n.currency}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => ref.read(selectedOrderIdProvider.notifier).state = order.id,
                    );
                  },
                ),
              ),
              const VerticalDivider(),
              // Payment Panel
              Expanded(
                flex: 2,
                child: selectedOrderId == null
                    ? Center(child: Text(l10n.selectOrder))
                    : _PaymentDetailPanel(
                        order: activeOrders.firstWhere((o) => o.id == selectedOrderId),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentDetailPanel extends ConsumerWidget {
  final Order order;
  const _PaymentDetailPanel({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.orderSummary, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  title: Text(item.productName),
                  trailing: Text('x${item.quantity}  ${(item.unitPrice * item.quantity).toStringAsFixed(2)} ${l10n.currency}'),
                );
              },
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total, style: Theme.of(context).textTheme.titleLarge),
              Text('${order.totalAmount.toStringAsFixed(2)} ${l10n.currency}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _processPayment(context, ref, 'CASH'),
                  icon: const Icon(Icons.money),
                  label: Text(l10n.cash),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _processPayment(context, ref, 'CARD'),
                  icon: const Icon(Icons.credit_card),
                  label: Text(l10n.card),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Receipt Printing Button (Conditional via Feature Flag)
          if (ref.watch(featureFlagsProvider).isEnabled('printer_integration'))
            OutlinedButton.icon(
              onPressed: () => _printReceipt(context, ref),
              icon: const Icon(Icons.print),
              label: const Text('Print Receipt'), 
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, WidgetRef ref, String method) async {
    final l10n = AppLocalizations.of(context)!;
    final tenantId = ref.read(tenantIdProvider);
    final logger = ref.read(appLoggerProvider);
    final analytics = ref.read(analyticsTrackerProvider);

    if (tenantId == null) {
      logger.error('Payment failed: No tenantId found in context');
      return;
    }
    final repo = ref.read(orderRepositoryProvider);

    logger.info('Processing $method payment for order: ${order.id}', data: {
      'orderId': order.id,
      'amount': order.totalAmount,
      'method': method,
      'tenantId': tenantId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.processingPayment(method))),
    );

    try {
      await repo.processPayment(tenantId, order.id, method);
      
      // Log analytics event
      await analytics.logEvent(
        AnalyticsEvents.paymentProcessed,
        parameters: {
          AnalyticsParams.orderId: order.id,
          AnalyticsParams.amount: order.totalAmount,
          AnalyticsParams.status: 'success',
          'method': method,
        },
        tenantId: tenantId,
      );

      // Auto-print receipt on successful payment if enabled
      final flags = ref.read(featureFlagsProvider);
      if (flags.isEnabled('printer_integration')) {
        await _printReceipt(context, ref);
      }

      ref.read(selectedOrderIdProvider.notifier).state = null;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentSuccessful)),
        );
      }
    } catch (e, st) {
      logger.error('Payment failed for order ${order.id}', error: e, st: st, tenantId: tenantId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorOccurred}: $e')),
        );
      }
    }
  }

  Future<void> _printReceipt(BuildContext context, WidgetRef ref) async {
    final printer = ref.read(printerServiceProvider);
    try {
      final receiptData = {
        'restaurant_name': 'My Restaurant', // Should come from tenant context ideally
        'total': order.totalAmount.toStringAsFixed(2),
        'items': order.items.map((i) => {
          'name': i.productName,
          'price': i.unitPrice * i.quantity,
        }).toList(),
      };
      await printer.printReceipt(receiptData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printer Error: $e')),
        );
      }
    }
  }
}
