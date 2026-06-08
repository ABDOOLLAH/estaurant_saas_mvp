import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_ops_app/main.dart';

void main() {
  testWidgets('Staff app renders navigation rail and initial waiter screen in RTL', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: StaffOpsApp()));

    // Verify we are in Waiter mode by checking for the AppBar title
    // Note: In real app, this might be localized. Here we check the hardcoded string from WaiterScreen.
    expect(find.text('Waiter Mode - Active Tables'), findsOneWidget);

    // Verify NavigationRail exists
    expect(find.byType(NavigationRail), findsOneWidget);

    // Check for RTL: The NavigationRail should be on the right side in Arabic ('ar')
    final navRailFinder = find.byType(NavigationRail);
    final navRailRect = tester.getRect(navRailFinder);
    final screenWidth = tester.binding.window.physicalSize.width / tester.binding.window.devicePixelRatio;
    
    // In RTL, the navigation rail is typically at the right edge
    expect(navRailRect.left > screenWidth / 2, isTrue);
  });
}
