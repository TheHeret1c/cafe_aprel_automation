import 'dart:convert';

import 'package:cafe_automation/data/database_helper.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/category.dart';
import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Ingredient> _ingredients = [];
  List<Category> _categories = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exportToCsv() async {
    final rows = <List<dynamic>>[
      ['Категория', 'Название', 'Количество', 'Единица'],
    ];

    for (final ingredient in _ingredients) {
      rows.add([
        ingredient.category,
        ingredient.name,
        ingredient.quantity,
        ingredient.unit,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final now = DateTime.now();
    final fileName = 'ostatki_${now.year}-${now.month}-${now.day}.csv';
    final file = File('${directory.path}/$fileName');
    final bom = '\uFEFF';
    await file.writeAsString(bom + csvData, encoding: const Utf8Codec());

    if (mounted) {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Остатки на ${now.day}.${now.month}.${now.year}',
      );
    }
  }

  Future<void> _loadIngredients() async {
    await Future.delayed(Duration(seconds: 1));

    final categories = await DatabaseHelper.instance.getCategories();
    final categoryNames = {for (final c in categories) c.id: c.name};

    final ingredientsRows = await DatabaseHelper.instance.getAllIngredients();
    setState(() {
      _categories = categories;
      _ingredients = ingredientsRows.map((row) => Ingredient(
          id: row['id'] as String,
          name: row['name'] as String,
          unit: row['unit'] as String,
          category: categoryNames[row['category_id']] ?? 'Без категории',
          quantity: row['quantity'] as double,
      )).toList();
      _isLoading = false;
    });
  }

  Map<String, List<Ingredient>> _groupByCategory(List<Ingredient> ingredients) {
    final Map<String, List<Ingredient>> grouped = {};
    for (final ingredient in ingredients) {
      grouped.putIfAbsent(ingredient.category, () => []).add(ingredient);
    }
    return grouped;
  }

  List<Ingredient> _filterIngredients(String query) {
    return _ingredients
        .where((ingredient) =>
        ingredient.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Изменение количества ингредиента
  void _editQuantity(Ingredient ingredient) {
    final controller = TextEditingController(text: ingredient.quantity.toString());
    final piecesController = TextEditingController();
    final weightPerPieceController = TextEditingController();
    bool showCalculator = false;
    bool addMode = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void recalculate() {
              final pieces = double.tryParse(piecesController.text.replaceAll(',', '.')) ?? 0;
              final weightPerPiece = double.tryParse(weightPerPieceController.text.replaceAll(',', '.')) ?? 0;
              final totalKg = (pieces * weightPerPiece) / 1000;
              controller.text = totalKg.toStringAsFixed(3);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ingredient.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Задать итог')),
                        ButtonSegment(value: true, label: Text('Добавить')),
                      ],
                      selected: {addMode},
                      onSelectionChanged: (selection) {
                        setModalState(() {
                          addMode = selection.first;
                          controller.text =
                          addMode ? '' : _round3(ingredient.quantity).toString();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: addMode ? 'Сколько добавить' : 'Количество',
                              suffixText: ingredient.unit,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (addMode)
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller,
                        builder: (context, value, _) {
                          final total = _round3(ingredient.quantity + _parseNumber(value.text));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Было ${_round3(ingredient.quantity)} → станет $total ${ingredient.unit}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() {
                          showCalculator = !showCalculator;
                        });
                      },
                      icon: const Icon(Icons.calculate_outlined),
                      label: Text(showCalculator ? 'Скрыть калькулятор' : 'Посчитать по количеству'),
                    ),
                    if (showCalculator) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: piecesController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Кол-во шт.', border: OutlineInputBorder()),
                              onChanged: (_) => setModalState(recalculate),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: weightPerPieceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Вес 1 шт. (г)', border: OutlineInputBorder()),
                              onChanged: (_) => setModalState(recalculate),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        final current = double.tryParse(value.text.replaceAll(',', '.')) ?? 0;
                        return Wrap(
                          spacing: 8,
                          children: _stepsFor(current)
                              .map((step) => _stepButton(controller, step))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Удалить ингредиент?'),
                                  content: Text('«${ingredient.name}» будет удалён из списка.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await DatabaseHelper.instance.deleteIngredient(ingredient.id);
                                await _loadIngredients();
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            child: const Text('Удалить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final input = double.tryParse(controller.text.replaceAll(',', '.').trim());
                              if (input != null) {
                                final newValue = addMode ? _round3(ingredient.quantity + input) : input;
                                await DatabaseHelper.instance
                                    .updateIngredientQuantity(ingredient.id, newValue);
                                await _loadIngredients();
                              }
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Добавление нового ингредиента
  void _addIngredient() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '0');
    String selectedUnit = 'кг';
    String? selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
    String? nameError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Новый ингредиент', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 16,),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Название',
                      errorText: nameError,
                    ),
                  ),
                  const SizedBox(height: 12,),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Категория',
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12,),
                  DropdownButtonFormField<String>(
                    initialValue: selectedUnit,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Единица измерения',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'кг', child: Text('кг')),
                      DropdownMenuItem(value: 'л', child: Text('л')),
                      DropdownMenuItem(value: 'шт', child: Text('шт')),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedUnit = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12,),
                  TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Начальное количество',
                    ),
                  ),
                  const SizedBox(height: 16,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();

                          if (name.isEmpty) {
                            setModalState(() {
                              nameError = 'Введите название';
                            });
                            return;
                          }
                          if (selectedCategoryId == null) return;

                          final quantity = double.tryParse(quantityController.text.replaceAll(',', '.').trim()) ?? 0;

                          final newIngredient = {
                            'id': const Uuid().v4(),
                            'name': name,
                            'unit': selectedUnit,
                            'category_id': selectedCategoryId,
                            'quantity': quantity,
                            'revision': 0,
                            'updated_at': DateTime.now().toIso8601String(),
                            'is_synced': 0,
                          };

                          await DatabaseHelper.instance.insertIngredient(newIngredient);
                          await _loadIngredients();

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Добавить')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepButton(TextEditingController controller, double step) {
    final label = step == step.roundToDouble()
        ? step.toInt().toString()
        : step.toString();

    return OutlinedButton(
      onPressed: () {
        final current = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
        final updated = (current + step).clamp(0, double.infinity);
        controller.text = double.parse(updated.toStringAsFixed(3)).toString();
      },
      child: Text(step > 0 ? '+$label' : label),
    );
  }

  List<double> _stepsFor(double value) {
    return value < 5 ? [-1, -0.1, 0.1, 1] : [-10, -1, 1, 10];
  }

  double _parseNumber(String text) =>
      double.tryParse(text.replaceAll(',', '.').trim()) ?? 0;

  double _round3(double v) => double.parse(v.toStringAsFixed(3));

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;
    final filteredIngredients = isSearching ? _filterIngredients(_searchQuery) : [];
    final grouped = _groupByCategory(_ingredients);
    final categories = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Остатки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: _exportToCsv,
            tooltip: 'Экспорт в CSV',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIngredient,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                  labelText: 'Поиск',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  suffixIcon: isSearching
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (isSearching
                ? (filteredIngredients.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Ничего не найдено',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
                : ListView.builder(
              itemCount: filteredIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = filteredIngredients[index];
                return ListTile(
                  title: Text(ingredient.name),
                  subtitle: Text(ingredient.category),
                  trailing: Text('${ingredient.quantity} ${ingredient.unit}'),
                  onTap: () => _editQuantity(ingredient),
                );
              },
            ))
                : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final items = grouped[category]!;

                return ExpansionTile(
                  title: Text(category),
                  children: items.map((ingredient) {
                    return ListTile(
                      title: Text(ingredient.name),
                      trailing: Text('${ingredient.quantity} ${ingredient.unit}'),
                      onTap: () => _editQuantity(ingredient),
                    );
                  }).toList(),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
