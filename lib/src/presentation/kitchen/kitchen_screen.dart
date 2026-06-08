import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:staff_ops_app/l10n/app_localizations.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.kitchenDisplay)),
      body: AsyncValueWidget(
        value: ordersAsync,
        data: (orders) => Row(
          children: [
            _buildLane(
              context,
              ref,
              l10n.statusPending,
              Colors.orange[100]!,
              orders.where((o) => o.status == OrderStatus.pending).toList(),
              OrderStatus.preparing,
              l10n.start,
            ),
            const VerticalDivider(),
            _buildLane(
              context,
              ref,
              l10n.statusPreparing,
              Colors.blue[100]!,
              orders.where((o) => o.status == OrderStatus.preparing).toList(),
              OrderStatus.ready,
              l10n.readyAction,
            ),
            const VerticalDivider(),
            _buildLane(
              context,
              ref,
              l10n.statusReady,
              Colors.green[100]!,
              orders.where((o) => o.status == OrderStatus.ready).toList(),
              OrderStatus.delivered,
              l10n.bump,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLane(
    BuildContext context,
    WidgetRef ref,
    String title,
    Color color,
    List<Order> orders,
    OrderStatus nextStatus,
    String actionLabel,
  ) {
    return Expanded(
      child: Container(
        color: color,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$title (${orders.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _KitchenOrderCard(
                    order: order,
                    actionLabel: actionLabel,
                    onAction: () async {
                      final tenantId = ref.read(tenantIdProvider);
                      final logger = ref.read(appLoggerProvider);
                      final analytics = ref.read(analyticsTrackerProvider);

                      if (tenantId == null) {
                        logger.error('Kitchen action failed: No tenantId');
                        return;
                      }

                      try {
                        logger.info('Updating order status', data: {
                          'orderId': order.id,
                          'newStatus': nextStatus.name,
                          'tenantId': tenantId,
                        });

                        await ref
                            .read(orderRepositoryProvider)
                            .updateOrderStatus(tenantId, order.id, nextStatus);

                        await analytics.logEvent(
                          AnalyticsEvents.orderStatusChanged,
                          parameters: {
                            AnalyticsParams.orderId: order.id,
                            AnalyticsParams.status: nextStatus.name,
                          },
                          tenantId: tenantId,
                        );
                      } catch (e, st) {
                        logger.error('Failed to update order status', error: e, st: st, tenantId: tenantId);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final Order order;
  final String actionLabel;
  final VoidCallback onAction;

  const _KitchenOrderCard({
    required this.order,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeElapsed = DateTime.now().difference(order.createdAt).inMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.tableNumber((order.tableNumber ?? 0).toString()),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: timeElapsed > 15 ? Colors.red : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.minutesShort(timeElapsed),
                    style: TextStyle(
                      color: timeElapsed > 15 ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '#${order.id.substring(order.id.length - 4)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Expanded(child: Text(item.productName, style: const TextStyle(fontSize: 18))),
                    ],
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0, top: 2),
                      child: Text(
                        'Note: ${item.notes}',
                        style: const TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(actionLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
