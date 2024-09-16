import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp ({super.key});
  @override
  Widget build(BuildContext context){
    return ChangeNotifierProvider(
      create: (context) => TodoAppState(),
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0x2497C2FF)),
        ),
        home: TodoHomePage(),
      ),
    );
  }
}

class TodoAppState extends ChangeNotifier {
  var todos = <String>[];
  var worksDone = <String>[];
  var worksDeleted = <String>[];
  String notification = '';
  var inputBox = TextEditingController();
  void add(String todo){
    //check if input is empty
    if(todo.isEmpty){
      return;
    }
    todos.add(todo);
    notifyListeners();
  }
  void remove(String todo){
    todos.remove(todo);
    worksDone.remove(todo);
    worksDeleted.add(todo + ' (deleted)');
    notifyListeners();
  }
  void markAsDone(String todo){
    todos.remove(todo);
    worksDone.add(todo + ' (done)');
    notifyListeners();
  }
  void permentlyDelete(String todo){
    worksDeleted.remove(todo);
    notifyListeners();
  }
}
class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}
class _TodoHomePageState extends State<TodoHomePage>{
  var selectedIndex = 0;
  var inputBox = TextEditingController();
  @override
  Widget build(BuildContext context){
    Widget page;

    switch(selectedIndex){
      case 0:
        page = TodoListPage();
        break;
      case 1:
        page = WorksDonePage();
        break;
      case 2:
        page = removeTodoPage();
        break;
      default:
        page = TodoListPage();
    }
    return LayoutBuilder(
      builder: (context, constraints){
        return Scaffold (
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
                      icon: Icon(Icons.delete),
                      label: Text('Works deleted'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
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
        );
      },
    );
  }
}

class TodoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: context.read<TodoAppState>().inputBox,
              decoration: InputDecoration(
                labelText: 'Add Todo',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final todoAppState = context.read<TodoAppState>();
                    todoAppState.add(todoAppState.inputBox.text);
                    todoAppState.inputBox.clear();
                  },
                ),
              ),
            ),
          ),
        ),

        IconButton(
          icon: Icon(Icons.save),
          onPressed: (){
            List<String> todos = context.read<TodoAppState>().todos;
            saveTodosToFile(context, todos);
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: context.watch<TodoAppState>().todos.length,
            itemBuilder: (context, index){
              return ListTile(
                title: Text(context.watch<TodoAppState>().todos[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        context.read<TodoAppState>().markAsDone(context.read<TodoAppState>().todos[index]);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        context.read<TodoAppState>().remove(context.read<TodoAppState>().todos[index]);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class WorksDonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: context.watch<TodoAppState>().worksDone.length,
      itemBuilder: (context, index){
        return ListTile(
          title: Text(context.watch<TodoAppState>().worksDone[index]),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              context.read<TodoAppState>().remove(context.read<TodoAppState>().worksDone[index]);
            },
          ),
        );
      },
    );
  }
}

class removeTodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: context.watch<TodoAppState>().worksDeleted.length,
      itemBuilder: (context, index){
        return ListTile(
          title: Text(context.watch<TodoAppState>().worksDeleted[index]),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              context.read<TodoAppState>().permentlyDelete(context.read<TodoAppState>().worksDeleted[index]);
            },
          ),
        );
      },
    );
  }
}

Future<void> saveTodosToFile(BuildContext context, List<String>todos) async {
  try{
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/todos.txt');
    await file.writeAsString(todos.join('\n'));

    //set notification /data/user/0/com.example.todolist/app_flutter/todos.txt
    context.read<TodoAppState>().notification = 'Todos saved to ${directory.path}';
    context.read<TodoAppState>().notifyListeners();
    print(context.read<TodoAppState>().notification);

  } catch(e){
    context.read<TodoAppState>().notification = 'Failed to save. Error: $e';
    context.read<TodoAppState>().notifyListeners();
    print(context.read<TodoAppState>().notification);
  }
}