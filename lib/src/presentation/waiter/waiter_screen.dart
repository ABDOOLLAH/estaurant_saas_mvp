import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:staff_ops_app/l10n/app_localizations.dart';

class WaiterScreen extends ConsumerWidget {
  const WaiterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tenantId = ref.watch(tenantIdProvider);
    final branchId = ref.watch(selectedBranchIdProvider);
    
    if (tenantId == null) return const Center(child: Text('Tenant Error'));

    final tablesAsync = ref.watch(tablesStreamProvider((tenantId, branchId)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.waiterMode),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(tablesStreamProvider((tenantId, branchId))),
          )
        ],
      ),
      body: AsyncValueWidget(
        value: tablesAsync,
        data: (tables) {
          if (tables.isEmpty) {
            return const Center(child: Text('No tables configured.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return _TableCard(table: table);
            },
          );
        },
      ),
    );
  }
}

class _TableCard extends ConsumerWidget {
  final RestaurantTable table;
  
  const _TableCard({required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // For real-time total, we would need to watch the active order
    final activeOrderAsync = table.activeOrderId != null 
        ? ref.watch(orderStreamProvider((table.tenantId, table.activeOrderId!)))
        : const AsyncValue<Order?>.data(null);

    return Card(
      elevation: table.status == TableStatus.available ? 2 : 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor(table.status).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(appLoggerProvider).info('Table selected: ${table.number}', data: {
            'tableId': table.id,
            'status': table.status.name,
            'tenantId': table.tenantId,
          });
          // TODO: Open Table Detail / Action Sheet
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: _getStatusColor(table.status),
                child: Center(
                  child: Text(
                    l10n.tableNumber(table.number),
                    style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getStatusLabel(table.status).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _getStatusColor(table.status),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    activeOrderAsync.when(
                      data: (order) => order != null 
                        ? Text(
                            '${order.totalAmount.toStringAsFixed(2)} SR',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          )
                        : const Text('--', style: TextStyle(color: Colors.grey)),
                      loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
                    ),
                    if (table.status == TableStatus.unpaid)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text('PAYMENT PENDING', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),
            if (table.lastStatusUpdate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _formatTimeSince(table.lastStatusUpdate!),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available: return Colors.green;
      case TableStatus.occupied: return Colors.orange;
      case TableStatus.unpaid: return Colors.red;
      case TableStatus.paidElectronic: return Colors.blue;
      case TableStatus.paidCash: return Colors.teal;
      case TableStatus.paidCard: return Colors.indigo;
      case TableStatus.needsWaiter: return Colors.purple;
      case TableStatus.orderReady: return Colors.amber;
      case TableStatus.paymentFailed: return Colors.redAccent;
      case TableStatus.cancelled: return Colors.grey;
    }
  }

  String _getStatusLabel(TableStatus status) {
    switch (status) {
      case TableStatus.available: return 'Available';
      case TableStatus.occupied: return 'Dining';
      case TableStatus.unpaid: return 'Unpaid';
      case TableStatus.paidElectronic: return 'Paid (App)';
      case TableStatus.paidCash: return 'Paid (Cash)';
      case TableStatus.paidCard: return 'Paid (Card)';
      case TableStatus.needsWaiter: return 'Service!';
      case TableStatus.orderReady: return 'Ready';
      case TableStatus.paymentFailed: return 'Pay Error';
      case TableStatus.cancelled: return 'Cancelled';
    }
  }

  String _formatTimeSince(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
