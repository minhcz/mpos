import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../screens/salescreen/sale_screen.dart' as sale;
import '../screens/product/product_management_screen.dart' as product;
import '../screens/invoice/invoice_screen.dart';
import 'category_management_screen.dart';
import 'user_management_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<_MenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = [
      _MenuItem(
        label: 'Bán hàng',
        icon: Icons.point_of_sale,
        builder: () => const sale.SaleScreen(),
      ),
      _MenuItem(
        label: 'Sản phẩm',
        icon: Icons.inventory,
        builder: () => product.ProductManagementScreen(),
      ),
      _MenuItem(
        label: 'Hóa đơn',
        icon: Icons.receipt_long,
        builder: () => const InvoiceScreen(),
      ),
      _MenuItem(
        label: 'Nhóm hàng',
        icon: Icons.category,
        builder: () => const CategoryManagementScreen(),
      ),
    ];

    if (widget.currentUser.role == 'admin') {
      _menuItems.add(
        _MenuItem(
          label: 'Người dùng',
          icon: Icons.people,
          builder: () => const UserManagementScreen(),
        ),
      );
    }

    _menuItems.add(
      _MenuItem(
        label: 'Cài đặt',
        icon: Icons.settings,
        builder: () => const SettingsScreen(),
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedScreen = _menuItems[_selectedIndex].builder();

    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Row(
        children: [
          Container(
            width: 100,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _selectedIndex = index),
                    labelType: NavigationRailLabelType.all,
                    destinations: _menuItems
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(
                              item.icon,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text(item.label),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: InkWell(
                    onTap: _logout,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          'Thoát',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: selectedScreen),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Widget Function() builder;

  _MenuItem({
    required this.label,
    required this.icon,
    required this.builder,
  });
}