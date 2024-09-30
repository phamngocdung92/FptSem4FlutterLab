// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// void main() {
//   runApp(TodoApp2());
// }
//
// class TodoApp extends StatelessWidget {
//   const TodoApp ({super.key});
//   @override
//   Widget build(BuildContext context){
//     return ChangeNotifierProvider(
//       create: (context) => TodoAppState(),
//       child: MaterialApp(
//         title: 'Todo App',
//         theme: ThemeData(
//           useMaterial3: true,
//           colorScheme: ColorScheme.fromSeed(seedColor: Color(0x2497C2FF)),
//         ),
//         home: TodoHomePage(),
//       ),
//     );
//   }
// }
//
// class TodoAppState extends ChangeNotifier {
//   var todos = <String>[];
//   var worksDone = <String>[];
//   var worksDeleted = <String>[];
//   String notification = '';
//   var inputBox = TextEditingController();
//   void add(String todo){
//     //check if input is empty
//     if(todo.isEmpty){
//       return;
//     }
//     todos.add(todo);
//     notifyListeners();
//   }
//   void remove(String todo){
//     todos.remove(todo);
//     worksDone.remove(todo);
//     worksDeleted.add(todo + ' (deleted)');
//     notifyListeners();
//   }
//   void markAsDone(String todo){
//     todos.remove(todo);
//     worksDone.add(todo + ' (done)');
//     notifyListeners();
//   }
//   void permentlyDelete(String todo){
//     worksDeleted.remove(todo);
//     notifyListeners();
//   }
// }
// class TodoHomePage extends StatefulWidget {
//   @override
//   _TodoHomePageState createState() => _TodoHomePageState();
// }
// class _TodoHomePageState extends State<TodoHomePage>{
//   var selectedIndex = 0;
//   var inputBox = TextEditingController();
//   @override
//   Widget build(BuildContext context){
//     Widget page;
//
//     switch(selectedIndex){
//       case 0:
//         page = TodoListPage();
//         break;
//       case 1:
//         page = WorksDonePage();
//         break;
//       case 2:
//         page = removeTodoPage();
//         break;
//       default:
//         page = TodoListPage();
//     }
//     return LayoutBuilder(
//       builder: (context, constraints){
//         return Scaffold (
//           body: Row (
//             children: [
//               SafeArea(
//                 child: NavigationRail(
//                   extended: constraints.maxWidth >= 600,
//                   destinations: [
//                     NavigationRailDestination(
//                       icon: Icon(Icons.home),
//                       label: Text('Home'),
//                     ),
//                     NavigationRailDestination(
//                       icon: Icon(Icons.assignment_turned_in_outlined),
//                       label: Text('Works done'),
//                     ),
//                     NavigationRailDestination(
//                       icon: Icon(Icons.delete),
//                       label: Text('Works deleted'),
//                     ),
//                   ],
//                   selectedIndex: selectedIndex,
//                   onDestinationSelected: (value) {
//                     setState(() {
//                       selectedIndex = value;
//                     });
//                   },
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   color: Theme.of(context).colorScheme.primaryContainer,
//                   child: page,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class TodoListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context){
//     return Column(
//       children: [
//         SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: context.read<TodoAppState>().inputBox,
//               decoration: InputDecoration(
//                 labelText: 'Add Todo',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () {
//                     final todoAppState = context.read<TodoAppState>();
//                     todoAppState.add(todoAppState.inputBox.text);
//                     //add to database
//
//                     todoAppState.inputBox.clear();
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         IconButton(
//           icon: Icon(Icons.save),
//           onPressed: (){
//             List<String> todos = context.read<TodoAppState>().todos;
//             saveTodosToFile(context, todos);
//           },
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: context.watch<TodoAppState>().todos.length,
//             itemBuilder: (context, index){
//               return ListTile(
//                 title: Text(context.watch<TodoAppState>().todos[index]),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.check),
//                       onPressed: () {
//                         context.read<TodoAppState>().markAsDone(context.read<TodoAppState>().todos[index]);
//                       },
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete),
//                       onPressed: () {
//                         context.read<TodoAppState>().remove(context.read<TodoAppState>().todos[index]);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class WorksDonePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context){
//     return ListView.builder(
//       itemCount: context.watch<TodoAppState>().worksDone.length,
//       itemBuilder: (context, index){
//         return ListTile(
//           title: Text(context.watch<TodoAppState>().worksDone[index]),
//           trailing: IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () {
//               context.read<TodoAppState>().remove(context.read<TodoAppState>().worksDone[index]);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// class removeTodoPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context){
//     return ListView.builder(
//       itemCount: context.watch<TodoAppState>().worksDeleted.length,
//       itemBuilder: (context, index){
//         return ListTile(
//           title: Text(context.watch<TodoAppState>().worksDeleted[index]),
//           trailing: IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () {
//               context.read<TodoAppState>().permentlyDelete(context.read<TodoAppState>().worksDeleted[index]);
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// Future<void> saveTodosToFile(BuildContext context, List<String>todos) async {
//   try{
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/todos.txt');
//     await file.writeAsString(todos.join('\n'));
//
//     //set notification /data/user/0/com.example.todolist/app_flutter/todos.txt
//     context.read<TodoAppState>().notification = 'Todos saved to ${directory.path}';
//     context.read<TodoAppState>().notifyListeners();
//     print(context.read<TodoAppState>().notification);
//
//   } catch(e){
//     context.read<TodoAppState>().notification = 'Failed to save. Error: $e';
//     context.read<TodoAppState>().notifyListeners();
//     print(context.read<TodoAppState>().notification);
//   }
// }
//
// class Todo {
//   final int? id;
//   final String todoName;
//   final bool isCompleted;
//
//   Todo({
//     this.id,
//     required this.todoName,
//     this.isCompleted = false,
//   });
//
//   // Convert a Todo into a Map. The keys must match the column names in the database.
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'todoName': todoName,
//       'isCompleted': isCompleted ? 1 : 0,
//     };
//   }
//
//   // Create a Todo from a Map.
//   factory Todo.fromMap(Map<String, dynamic> map) {
//     return Todo(
//       id: map['id'],
//       todoName: map['todoName'],
//       isCompleted: map['isCompleted'] == 1,
//     );
//   }
// }
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;
//
//   factory DatabaseHelper() {
//     return _instance;
//   }
//
//   DatabaseHelper._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'todo_list.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE todos(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         todoName TEXT,
//         isCompleted INTEGER
//       )
//     ''');
//   }
//
//   Future<int> insertTodo(Todo todo) async {
//     final db = await database;
//     return await db.insert('todos', todo.toMap());
//   }
//
//   Future<List<Todo>> getTodos() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('todos');
//     return List.generate(maps.length, (i) {
//       return Todo.fromMap(maps[i]);
//     });
//   }
//
//   Future<int> updateTodo(Todo todo) async {
//     final db = await database;
//     return await db.update(
//       'todos',
//       todo.toMap(),
//       where: 'id = ?',
//       whereArgs: [todo.id],
//     );
//   }
//
//   Future<int> deleteTodo(int id) async {
//     final db = await database;
//     return await db.delete(
//       'todos',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }
//
// //ver2
// class TodoApp2 extends StatefulWidget {
//   @override
//   _TodoAppState createState() => _TodoAppState();
// }
//
// class _TodoAppState extends State<TodoApp2> {
//   final _dbHelper = DatabaseHelper();
//   final _formKey = GlobalKey<FormState>();
//   final _todoNameController = TextEditingController();
//
//   List<Todo> _todos = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchTodos();
//   }
//
//   Future<void> _fetchTodos() async {
//     final todos = await _dbHelper.getTodos();
//     setState(() {
//       _todos = todos;
//     });
//   }
//
//   void _addTodo() async {
//     if (_formKey.currentState!.validate()) {
//       final todo = Todo(
//         todoName: _todoNameController.text,
//       );
//       await _dbHelper.insertTodo(todo);
//       _todoNameController.clear();
//       _fetchTodos();
//     }
//   }
//
//   void _toggleCompletion(Todo todo) async {
//     final updatedTodo = Todo(
//       id: todo.id,
//       todoName: todo.todoName,
//       isCompleted: !todo.isCompleted,
//     );
//     await _dbHelper.updateTodo(updatedTodo);
//     _fetchTodos();
//   }
//
//   void _deleteTodo(int id) async {
//     await _dbHelper.deleteTodo(id);
//     _fetchTodos();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('To-Do List')),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       decoration: InputDecoration(labelText: 'Title'),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a title';
//                         }
//                         return null;
//                       },
//                     ),
//                     TextFormField(
//                       controller: _todoNameController,
//                       decoration: InputDecoration(labelText: 'Description'),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a description';
//                         }
//                         return null;
//                       },
//                     ),
//                     ElevatedButton(
//                       onPressed: _addTodo,
//                       child: Text('Add To-Do'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _todos.length,
//                 itemBuilder: (context, index) {
//                   final todo = _todos[index];
//                   return ListTile(
//                     title: Text(todo.todoName),
//                     trailing: Checkbox(
//                       value: todo.isCompleted,
//                       onChanged: (value) {
//                         _toggleCompletion(todo);
//                       },
//                     ),
//                     onLongPress: () {
//                       _deleteTodo(todo.id!);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }