import 'package:flutter/material.dart';
import 'categories_screen.dart';

class SettingsScreen extends StatelessWidget{
  const SettingsScreen({super.key});

  void _openCategories(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoriesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Категории'),
            subtitle: const Text('Места хранения'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openCategories(context),
          ),
        ],
      ),
    );
  }
}