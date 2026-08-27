import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cafe_automation.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        revision INTEGER,
        updated_at TEXT,
        is_synced INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ingredients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        category_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        revision INTEGER,
        updated_at TEXT,
        is_synced INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    final now = DateTime.now().toIso8601String();
    final initialCategories = [
      'Сухой склад',
      'Мясной гроб',
      'Смешанный гроб',
      'Холодильники кухня',
      'Холодильник пицца',
      'Холодильная камера',
      'Морозильная камера',
      'Стеллаж с овощами',
    ];

    for (final name in initialCategories) {
      await db.insert('categories', {
        'id': name.hashCode.toString(),
        'name': name,
        'revision': 0,
        'updated_at': now,
        'is_synced': 0,
      });
    }
  }

  Future<void> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    await db.insert('categories', category);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<void> insertIngredient(Map<String, dynamic> ingredient) async {
    final db = await database;
    await db.insert('ingredients', ingredient);
  }

  Future<List<Map<String, dynamic>>> getAllIngredients() async {
    final db = await database;
    return await db.query('ingredients');
  }

  Future<void> updateIngredientQuantity(String id, double quantity) async {
    final db = await database;
    await db.update(
      'ingredients',
      {'quantity': quantity, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}