import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кафе Апрель')),
      //body: const Center(child: Text('Главный экран')),
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
            onTap:() {
              print('Нажали на склад');
            },
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
