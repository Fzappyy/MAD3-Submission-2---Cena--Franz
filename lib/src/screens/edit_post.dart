import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/src/models/post.dart';
import 'dart:convert';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    _bodyController.text = widget.post.body;
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      Post updatedPost = Post(
        id: widget.post.id,
        userId: widget.post.userId,
        title: _titleController.text,
        body: _bodyController.text,
      );

      final response = await http.put(
        Uri.parse(
            'https://jsonplaceholder.typicode.com/posts/${updatedPost.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': updatedPost.id,
          'userId': updatedPost.userId,
          'title': updatedPost.title,
          'body': updatedPost.body,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Post editedPost = Post.fromJson(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
        Navigator.pop(context, editedPost);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update post')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the body';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 100.0,
                height: 50.0,
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    _submitPost();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
