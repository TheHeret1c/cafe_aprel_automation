import 'package:flutter/material.dart';
import '../data/mock_ingredients.dart';
import '../models/ingredient.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late List<Ingredient> _ingredients;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(mockIngredients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _editQuantity(Ingredient ingredient) {
    final controller = TextEditingController(
        text: ingredient.quantity.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + 16
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ingredient.name, style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Количество',
                        suffixText: ingredient.unit,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _stepButton(controller, -10),
                  _stepButton(controller, -1),
                  _stepButton(controller, 1),
                  _stepButton(controller, 10),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newValue = double.tryParse(controller.text);
                    if (newValue != null) {
                      setState(() {
                        final index = _ingredients.indexWhere((i) =>
                        i.id == ingredient.id);
                        _ingredients[index] = ingredient.copyWith(
                            quantity: newValue);
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Сохранить'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _stepButton(TextEditingController controller, double step) {
    return OutlinedButton(
      onPressed: () {
        final current = double.tryParse(controller.text) ?? 0;
        final updated = (current + step).clamp(0, double.infinity);
        controller.text = updated.toString();
      },
      child: Text(step > 0 ? '+$step' : '$step'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;
    final filteredIngredients = isSearching ? _filterIngredients(_searchQuery) : [];
    final grouped = _groupByCategory(_ingredients);
    final categories = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Остатки')),
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
            child: isSearching
                ? ListView.builder(
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
            )
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
                      trailing: Text(
                          '${ingredient.quantity} ${ingredient.unit}'),
                      onTap: () => _editQuantity(ingredient),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
