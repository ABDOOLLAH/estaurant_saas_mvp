import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../widgets/staff_shared_widgets.dart';
import '../widgets/category_selector.dart';
import 'package:staff_ops_app/l10n/app_localizations.dart';

class WaiterOrderingScreen extends ConsumerWidget {
  final int tableNumber;
  const WaiterOrderingScreen({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final items = ref.watch(filteredMenuItemsProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.tableNumber(tableNumber.toString())} - ${l10n.newOrder}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Row(
        children: [
          // Left: Product Selection
          Expanded(
            flex: 3,
            child: Column(
              children: [
                AsyncValueWidget(
                  value: categoriesAsync,
                  data: (categories) => CategorySelector(
                    categories: [l10n.all, ...categories.map((c) => c.name)],
                    selectedCategory: selectedCategoryId ?? l10n.all,
                    onCategorySelected: (cat) => ref
                        .read(selectedCategoryIdProvider.notifier)
                        .state = cat,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text(l10n.noItemsFound))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ProductCard(
                              name: item.name,
                              price: '${item.price.toStringAsFixed(2)} ${l10n.currency}',
                              onTap: () => ref.read(cartProvider.notifier).addItem(
                                OrderItem(
                                  productId: item.id,
                                  productName: item.name,
                                  quantity: 1,
                                  unitPrice: item.price,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right: Order Summary Sidebar
          SizedBox(
            width: 350,
            child: OrderSummarySidebar(tableNumber: tableNumber),
          ),
        ],
      ),
    );
  }
}

class OrderSummarySidebar extends ConsumerWidget {
  final int tableNumber;
  const OrderSummarySidebar({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cart = ref.watch(cartProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.currentOrder, style: Theme.of(context).textTheme.titleLarge),
              StaffStatusChip(label: l10n.dineIn, color: Colors.blue),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: cart.items.isEmpty
              ? Center(child: Text(l10n.cartEmpty))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    return OrderLineItem(
                      name: cartItem.productName,
                      quantity: cartItem.quantity,
                      price: '${(cartItem.unitPrice * cartItem.quantity).toStringAsFixed(2)} ${l10n.currency}',
                      onRemove: () =>
                          ref.read(cartProvider.notifier).updateQuantity(
                                cartItem.productId,
                                cartItem.quantity - 1,
                              ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        _OrderTotalsFooter(tableNumber: tableNumber),
      ],
    );
  }
}

class _OrderTotalsFooter extends ConsumerWidget {
  final int tableNumber;
  const _OrderTotalsFooter({required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cart = ref.watch(cartProvider);
    final subtotal = cart.totalAmount;
    final vat = subtotal * 0.15;
    final total = subtotal + vat;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[50],
      child: Column(
        children: [
          _TotalRow(label: l10n.subtotal, value: '${subtotal.toStringAsFixed(2)} ${l10n.currency}'),
          const SizedBox(height: 8),
          _TotalRow(label: l10n.vat, value: '${vat.toStringAsFixed(2)} ${l10n.currency}'),
          const Divider(height: 24),
          _TotalRow(
            label: l10n.total,
            value: '${total.toStringAsFixed(2)} ${l10n.currency}',
            isBold: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: subtotal > 0
                  ? () async {
                      final tenantId = ref.read(tenantIdProvider);
                      // In a real app, branchId would come from a branch selection provider
                      const branchId = 'main-branch'; 
                      final cart = ref.read(cartProvider);
                      
                      if (tenantId == null) return;

                      final order = Order(
                        id: '', // Firestore will generate this
                        tenantId: tenantId,
                        branchId: branchId,
                        customerId: 'walk-in',
                        tableNumber: tableNumber,
                        orderType: 'dine-in',
                        status: OrderStatus.pending,
                        items: cart.items,
                        totalAmount: total,
                        createdAt: DateTime.now(),
                        // Per Audit: Idempotency to prevent double-submissions
                        idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(),
                      );

                      try {
                        await ref.read(orderRepositoryProvider).submitOrder(order);
                        ref.read(cartProvider.notifier).clearCart();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.orderSent)),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${l10n.errorOccurred}: $e')),
                          );
                        }
                      }
                    }
                  : null,
              child: Text(
                l10n.sendToKitchen,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 20 : 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
