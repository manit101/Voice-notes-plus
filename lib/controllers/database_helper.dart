import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'voice_notes.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        dateTime TEXT,
        isPinned INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db
          .execute('ALTER TABLE notes ADD COLUMN isPinned INTEGER DEFAULT 0');
    }
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
    Database db = await database;
    return await db.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    Database db = await database;
    return await db.query('notes', orderBy: 'isPinned DESC, dateTime DESC');
  }

  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNote(Map<String, dynamic> note) async {
    Database db = await database;
    return await db.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }
}
