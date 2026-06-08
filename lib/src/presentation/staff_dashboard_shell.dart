import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_ops_app/l10n/app_localizations.dart';

class StaffDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StaffDashboardShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 900,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Image.asset('assets/logo.png', height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 40)),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: IconButton(
                    icon: const Icon(Icons.health_and_safety_outlined),
                    tooltip: 'System Diagnostics',
                    onPressed: () => context.push('/admin/diagnostics'),
                  ),
                ),
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.restaurant),
                label: Text(l10n.waiter),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.kitchen),
                label: Text(l10n.kitchen),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.point_of_sale),
                label: Text(l10n.cashier),
              ),
            ],
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
