import 'package:cafe_automation/screens/inventory_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/module_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openInventory(BuildContext context) {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const InventoryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кафе Апрель')),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        padding: EdgeInsets.all(16),
        children: [
          MenuCard(
            icon: Icons.table_restaurant,
            title: 'Столы',
            onTap:() {
              print('Нажали на столы');
            },
          ),
          MenuCard(
            icon: Icons.restaurant_menu,
            title: 'Меню',
            onTap:() {
              print('Нажали на меню');
            },
          ),
          MenuCard(
            icon: Icons.inventory_2,
            title: 'Склад',
            onTap:() => _openInventory(context),
          ),
          MenuCard(
            icon: Icons.settings,
            title: 'Настройки',
            onTap:() {
              print('Нажали на настройки');
            },
          ),
        ],
      ),
    );
  }
}
