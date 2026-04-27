import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final controller = TextEditingController();
  List<String> todos = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("todo list", style: TextStyle(color: Colors.white)),
              centerTitle: true,
              leading: const Icon(Icons.menu, color: Colors.white),
              backgroundColor: Colors.purple,
            ),
            body: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(todos[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            todos.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Dodaj zadanie"),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Wpisz nowe zadanie",
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            setState(() {
                              todos.add(controller.text);
                            });
                            Navigator.of(context).pop();
                            controller.clear();
                          }
                        },
                        child: const Text("Dodaj"),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
