import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Todo>> fetchTodos() async {
  final response =
      await http.get('https://api.jsonbin.io/b/5ed0ca9060775a5685841cd6');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<Todo> todos = new List();
    for (Map i in data) {
      todos.add(Todo.fromJson(i));
    }
    return todos;
  } else {
    throw Exception('Failed to load');
  }
}

class Todo {
  final int id;
  final String name;
  final bool isComplete;

  Todo({this.id, this.name, this.isComplete});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      name: json['name'],
      isComplete: json['isComplete'],
    );
  }
}

class TodoScreen extends StatefulWidget {
  TodoScreen({Key key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  Future<List<Todo>> futureTodos;

  @override
  void initState() {
    super.initState();
    futureTodos = fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Data Todo'),
      ),
      body: Center(
        child: FutureBuilder<List<Todo>>(
          future: futureTodos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return TodoList(todoList: snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todoList;
  const TodoList({Key key, this.todoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${todoList.elementAt(index).name}'),
          subtitle: Text('${todoList.elementAt(index).id}'),
        );
      },
      itemCount: todoList.length,
    );
  }
}
