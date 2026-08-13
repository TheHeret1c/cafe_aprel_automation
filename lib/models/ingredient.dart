class Ingredient {
  final String id;
  final String name;
  final String unit; // кг, л, шт
  final String category; // место хранения
  final double quantity;

  Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.quantity,
  });

  Ingredient copyWith({double? quantity}) {
    return Ingredient(
      id: id,
      name: name,
      unit: unit,
      category: category,
      quantity: quantity ?? this.quantity,
    );
  }
}