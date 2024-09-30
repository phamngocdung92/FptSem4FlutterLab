import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist/todoModel.dart';

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
    String path = join(await getDatabasesPath(), 'todo_list.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todoName TEXT,
        isCompleted INTEGER DEFAULT 0,
        status INTEGER DEFAULT 1
      )
    ''');
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> getTodos() async {
   //get all todo with status = 1
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos', where: 'status = 1');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }
  Future<int> markDone(int id) async {
    final db = await database;
    return await db.update(
      'todos',
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //restore todo with status = 1
  Future<int> restoreDeleted(int id) async {
    final db = await database;
    return await db.update(
      'todos',
      {'status': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //restore todo with incompleted = 0
  Future<int> markIncomplete(int id) async {
    final db = await database;
    return await db.update(
      'todos',
      {'isCompleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.update(
      'todos',
      {'status': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<List<Todo>> getDeletedTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos', where: 'status = 0');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }
  Future<List<Todo>> getCompletedTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos', where: 'isCompleted = 1 AND status = 1');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }
//get all incomplete todos with isCompleted = 0 and status = 1
  Future<List<Todo>> getIncompleteTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos', where: 'isCompleted = 0 AND status = 1');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  //export all todos to txt file
  Future<void> exportTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    final List<Todo> todos = List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
    String todoString = '';
    todos.forEach((todo) {
      todoString += '${todo.todoName} - ${todo.isCompleted == 1 ? 'Completed' : 'Incomplete'}\n';
    });
    //write to file
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/todos.txt');
    await file.writeAsString(todoString);
  }
}