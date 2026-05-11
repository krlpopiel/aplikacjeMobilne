import 'package:flutter/material.dart';

void main() {
  runApp(const Task4App());
}

class Task4App extends StatelessWidget {
  const Task4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task 4 - Shopping List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ShoppingListScreen(),
    );
  }
}

class ShoppingItem {
  String name;
  bool isBought;
  ShoppingItem({required this.name, this.isBought = false});
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<ShoppingItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _items.add(ShoppingItem(name: _controller.text));
        _controller.clear();
      });
    }
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index].isBought = !_items[index].isBought;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New Item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: Key(item.name + index.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeItem(index),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.isBought ? TextDecoration.lineThrough : null,
                        color: item.isBought ? Colors.grey : Colors.black,
                      ),
                    ),
                    leading: Checkbox(
                      value: item.isBought,
                      onChanged: (_) => _toggleItem(index),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(index),
                    ),
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
