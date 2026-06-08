import 'package:flutter/material.dart';
import 'package:staff_ops_app/l10n/app_localizations.dart';

/// A semantic status chip with consistent padding and typography.
class StaffStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StaffStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// A large, accessible touch target for product selection.
class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String? imageUrl;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.addProductToOrder(name, price),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: imageUrl != null
                    ? Image.network(imageUrl!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      price,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A line item in the order summary sidebar.
class OrderLineItem extends StatelessWidget {
  final String name;
  final int quantity;
  final String price;
  final VoidCallback onRemove;

  const OrderLineItem({
    super.key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(price),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
            onPressed: onRemove,
            tooltip: l10n.removeItem(name),
          ),
        ],
      ),
    );
  }
}
