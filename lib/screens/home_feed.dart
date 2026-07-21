import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/post_model.dart';

class HomeFeed extends StatelessWidget {
  HomeFeed({super.key});

  final FirestoreService service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Viewgram"),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: service.getPosts(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No posts yet"),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {

              final post = posts[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        post.text,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),

                    Row(
                      children: [

                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                          ),
                          onPressed: () {
                            service.likePost(post.id);
                          },
                        ),

                        Text(
                          "${post.likes}",
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.comment,
                          ),
                          onPressed: () {},
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.share,
                          ),
                          onPressed: () {},
                        ),

                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
