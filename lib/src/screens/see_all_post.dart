import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/src/models/post.dart';
import 'add_post.dart';
import 'edit_post.dart'; // Import the edit post screen

class SeeAllPost extends StatefulWidget {
  static const String route = 'see-all-post';
  static const String path = '/see-all-post';
  static const String name = 'See All Post';

  const SeeAllPost({super.key});

  @override
  State<SeeAllPost> createState() => _SeeAllPostState();
}

class _SeeAllPostState extends State<SeeAllPost> {
  late Future<List<Post>> posts;
  List<Post> _postList = [];

  @override
  void initState() {
    super.initState();
    posts = fetchData();
  }

  Future<void> _refreshPosts() async {
    final fetchedPosts = await fetchData();
    setState(() {
      _postList = fetchedPosts;
    });
  }

  void _addPost(Post newPost) {
    setState(() {
      _postList.insert(0, newPost);
    });
  }

  void _deletePost(int id) {
    setState(() {
      _postList.removeWhere((post) => post.id == id);
    });
  }

  void _editPost(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
    );
    if (result != null && result is Post) {
      setState(() {
        int index = _postList.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _postList[index] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SeeAllPost.name),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Post>>(
          future: posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No posts found'));
            } else {
              if (_postList.isEmpty) {
                _postList = snapshot.data!;
              }
              return RefreshIndicator(
                onRefresh: _refreshPosts,
                child: ListView.builder(
                  itemCount: _postList.length,
                  itemBuilder: (context, index) {
                    Post post = _postList[index];
                    String shortenedBody =
                        '${post.body.substring(0, 10)}${post.body.length > 50 ? '...' : ''}';
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Text('User: ${post.userId}'),
                        title: Text(
                          post.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: shortenedBody,
                                style: const TextStyle(color: Colors.black),
                              ),
                              if (post.body.length > 50)
                                TextSpan(
                                  text: ' See more',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('User: ${post.userId}'),
                                                const SizedBox(height: 8),
                                                Text(post.title,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                Text(post.body),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editPost(post); // Navigate to edit screen
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deletePost(post.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
          if (result != null && result is Post) {
            _addPost(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<List<Post>> fetchData() async {
  final url = Uri.parse("https://jsonplaceholder.typicode.com/posts");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(response.body);
    List<Post> posts = jsonList.map((json) => Post.fromJson(json)).toList();
    return posts;
  } else {
    throw Exception('Failed to load posts');
  }
}
