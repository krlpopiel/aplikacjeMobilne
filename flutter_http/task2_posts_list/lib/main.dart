import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Task2App());
}

class Task2App extends StatelessWidget {
  const Task2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task 2 - Posts List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PostsListScreen(),
    );
  }
}

class PostsListScreen extends StatefulWidget {
  const PostsListScreen({super.key});

  @override
  State<PostsListScreen> createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load posts: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(
          title: Text(
            post['title'] ?? 'No Title',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            post['body'] ?? 'No Body',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailsScreen(
                  title: post['title'] ?? 'No Title',
                  body: post['body'] ?? 'No Body',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PostDetailsScreen extends StatelessWidget {
  final String title;
  final String body;

  const PostDetailsScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(body, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
