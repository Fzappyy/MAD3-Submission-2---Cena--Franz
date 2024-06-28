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

  void _showOptionsModalSheet(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.black),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editPost(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(post.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          SeeAllPost.name,
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<List<Post>>(
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
                          color: Colors.white,
                          shadowColor: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person),
                                Text('User: ${post.userId}'),
                              ],
                            ),
                            title: Text(
                              post.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                                      style:
                                          const TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                            Icons.person),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Text(
                                                          'User: ${post.userId}',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(post.title,
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      post.body,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
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
                            trailing: IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () {
                                _showOptionsModalSheet(post);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 125.0,
                  height: 50.0,
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddPostScreen()),
                      );
                      if (result != null && result is Post) {
                        _addPost(result);
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      'Create post',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
