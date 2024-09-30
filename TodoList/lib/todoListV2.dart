import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todolist/todoDatabaseHelper.dart';
import 'package:todolist/todoModel.dart';

void main() {
  runApp(homePage());
}

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}
class _homePageState extends State<homePage>{
  final _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final todos = await _dbHelper.getTodos();
    setState(() {
      _todos = todos;
    });
  }
  void _deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    _fetchTodos();
  }
  Future<void> _fetchDeletedTodos() async {
    final todos = await _dbHelper.getDeletedTodos();
    setState(() {
      _todos = todos;
    });
  }
  Future<void> _fetchCompletedTodos() async {
    final todos = await _dbHelper.getCompletedTodos();
    setState(() {
      _todos = todos;
    });
  }
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context){
    Widget page;

    switch(selectedIndex){
      case 0:
        page = TodoAppV2();
        break;
      case 1:
        page = WorkDone();
        break;
      case 2:
        page = WorkNotDone();
        break;
      case 3:
        page = WorkDeleted();
        break;
      default:
        page = TodoAppV2();
    }
    return LayoutBuilder(
      builder: (context, constraints){
        return MaterialApp (
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0x2497C2FF)),
          ),
          home: Scaffold(
            body: Row (
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.assignment_turned_in_outlined),
                        label: Text('Works done'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.pending),
                        label: Text('Works not done'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.delete),
                        label: Text('Works deleted'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                        print(selectedIndex);
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TodoAppV2 extends StatefulWidget {
  @override
  _TodoAppV2State createState() => _TodoAppV2State();
}
class _TodoAppV2State extends State<TodoAppV2> {
  final _inputController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  @override
  void initState() {
    super.initState();
    _getIncompleteTodos();
  }

  Future<void> _fetchTodos() async {
    final todos = await _dbHelper.getTodos();
    setState(() {
      _todos = todos;
    });
  }
  Future<void> _getIncompleteTodos() async {
    final todos = await _dbHelper.getIncompleteTodos();
    setState(() {
      _todos = todos;
    });
    for (var i = 0; i < _todos.length; i++) {
      print(_todos[i].todoName);
    }
  }
  Future<void> _markDone(int id) async {
    print(id);
    await _dbHelper.markDone(id);
    _getIncompleteTodos();
  }
  void _deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    _getIncompleteTodos();
  }
  Future<void> _fetchDeletedTodos() async {
    final todos = await _dbHelper.getDeletedTodos();
    setState(() {
      _todos = todos;
    });
  }
  Future<void> _fetchCompletedTodos() async {
    final todos = await _dbHelper.getCompletedTodos();
    setState(() {
      _todos = todos;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      //add a text field and a button to add todos
      body: Column(
        children: [
          TextField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: 'Enter a new todo',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_inputController.text.isNotEmpty) {
                await _dbHelper.insertTodo(Todo(
                  todoName: _inputController.text,
                ));
                _inputController.clear();
                _getIncompleteTodos();
              }
            },
            child: Text('Add todo'),
          ),
          //add a list view to display all todos
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return ListTile(
                  title: Text(todo.todoName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTodo(todo.id!);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () async {
                          _markDone(todo.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WorkDone extends StatefulWidget {
  @override
  _WorkDoneState createState() => _WorkDoneState();
}
class _WorkDoneState extends State<WorkDone> {
  final _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  @override
  void initState() {
    super.initState();
    _fetchCompletedTodos();
  }

  Future<void> _fetchCompletedTodos() async {
    final todos = await _dbHelper.getCompletedTodos();
    setState(() {
      _todos = todos;
    });
  }
  void _deleteTodoDone(int id) async {
    await _dbHelper.deleteTodo(id);
    _fetchCompletedTodos();
  }
  void markIncomplete(int id) async {
    await _dbHelper.markIncomplete(id);
    _fetchCompletedTodos();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Works done'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            title: Text(todo.todoName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTodoDone(todo.id!);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () async {
                    markIncomplete(todo.id!);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WorkNotDone extends StatefulWidget {
  @override
  _WorkNotDoneState createState() => _WorkNotDoneState();
}
class _WorkNotDoneState extends State<WorkNotDone> {
  final _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  @override
  void initState() {
    super.initState();
    _fetchIncompleteTodos();
  }

  Future<void> _fetchIncompleteTodos() async {
    final todos = await _dbHelper.getIncompleteTodos();
    setState(() {
      _todos = todos;
    });
  }
  void _deleteTodoNotDone(int id) async {
    await _dbHelper.deleteTodo(id);
    _fetchIncompleteTodos();
  }
  void _markDone(int id) async {
    await _dbHelper.markDone(id);
    _fetchIncompleteTodos();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Works not done'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            title: Text(todo.todoName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTodoNotDone(todo.id!);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () async {
                    _markDone(todo.id!);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
class WorkDeleted extends StatefulWidget {
  @override
  _WorkDeletedState createState() => _WorkDeletedState();
}
class _WorkDeletedState extends State<WorkDeleted> {
  final _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  @override
  void initState() {
    super.initState();
    _fetchDeletedTodos();
  }

  Future<void> _fetchDeletedTodos() async {
    final todos = await _dbHelper.getDeletedTodos();
    setState(() {
      _todos = todos;
    });
  }
  void _deleteTodoDeleted(int id) async {
    await _dbHelper.deleteTodo(id);
    _fetchDeletedTodos();
  }
  void _restoreDeleted(int id) async {
    await _dbHelper.restoreDeleted(id);
    _fetchDeletedTodos();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Works deleted'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            title: Text(todo.todoName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () async {
                    _restoreDeleted(todo.id!);
                    _fetchDeletedTodos();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}