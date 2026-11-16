import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/category.dart';

class CategoriesScreen extends StatefulWidget{
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await DatabaseHelper.instance.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _showNameDialog({Category? category}) async {
    final controller = TextEditingController(text: category?.name ?? '');
    String? error;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(category == null ? 'Новая категория' : 'Переименовать'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Название',
                errorText: error,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isEmpty) {
                    setDialogState(() => error = 'Введите название');
                    return;
                  }
                  final duplicate = _categories.any((c) =>
                      c.id != category?.id &&
                      c.name.toLowerCase() == value.toLowerCase());
                  if (duplicate) {
                    setDialogState(() => error = 'Такая категория уже есть');
                    return;
                  }
                  Navigator.pop(context, value);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
      ),
    );

    if (name == null) return;
    if (category == null) {
      await DatabaseHelper.instance.addCategory(name);
    } else {
      await DatabaseHelper.instance.renameCategory(category.id, name);
    }
    await _load();
  }

  Future<void> _deleteCategory(Category category) async {
    final count =
        await DatabaseHelper.instance.countIngredientsCategory(category.id);
    if (!mounted) return;

    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('В категории ингредиентов: $count. Сначала перенесите их в другую.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text('«${category.name}» будет удалена.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteCategory(category.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNameDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category.name),
            onTap: () => _showNameDialog(category: category),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteCategory(category),
            ),
          );
        },
      ),
    );
  }
}