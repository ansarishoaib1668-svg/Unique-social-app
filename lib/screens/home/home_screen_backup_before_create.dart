import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Vɪᴇᴡɢʀᴀᴍ ✦',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
        children: const [
          PostCard(
            user: "Shaad",
            caption: "Welcome to Viewgram 🚀",
          ),
          PostCard(
            user: "Creator",
            caption: "Share your moments ✨",
          ),
          PostCard(
            user: "Developer",
            caption: "Building social world 🌎",
          ),
        ],
      ),
    );
  }
}


class PostCard extends StatefulWidget {
  final String user;
  final String caption;

  const PostCard({
    super.key,
    required this.user,
    required this.caption,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}


class _PostCardState extends State<PostCard> {

  bool liked = false;
  int feelCount = 0;
  final List<String> comments = [];


  void addComment(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      comments.add(text);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(
            widget.user,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),


        Container(
          height: 330,
          width: double.infinity,
          color: Colors.grey[900],
          child: const Icon(
            Icons.image_outlined,
            size: 90,
            color: Colors.grey,
          ),
        ),


        Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [

              GestureDetector(
                onTap: () {

                  setState(() {

                    liked = !liked;

                    liked
                        ? feelCount++
                        : feelCount--;

                  });

                },

                child: Icon(
                  liked
                      ? Icons.favorite
                      : Icons.favorite_border,

                  color: liked
                      ? Colors.red
                      : Colors.black,

                  size: 30,
                ),
              ),


              const SizedBox(width: 6),


              Text(
                "Feel $feelCount",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),


              const SizedBox(width: 20),


              GestureDetector(

                onTap: () {

                  showModalBottomSheet(

                    context: context,

                    isScrollControlled: true,

                    builder: (context) {

                      final controller =
                          TextEditingController();


                      return Padding(

                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: MediaQuery.of(context)
                              .viewInsets
                              .bottom + 15,
                        ),

                        child: TextField(

                          controller: controller,

                          autofocus: true,

                          decoration: const InputDecoration(
                            hintText:
                            "Write a comment...",
                          ),

                          onSubmitted: (value) {

                            addComment(value);

                            Navigator.pop(context);

                          },

                        ),

                      );
                    },
                  );

                },


                child: Text(
                  "💬 ${comments.length}",
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),


              const SizedBox(width: 20),


              GestureDetector(

                onTap: () {

                  Share.share(
                    "Check out this post on Viewgram 🚀",
                  );

                },

                child: const Text(
                  "🚀",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),

              ),

            ],
          ),
        ),


        Padding(

          padding:
          const EdgeInsets.symmetric(horizontal: 12),

          child: Text(
            widget.caption,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

        ),


        ...comments.map(
              (c) => Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            child: Text(
              "💬 $c",
            ),
          ),
        ),


        const SizedBox(height: 20),

      ],
    );
  }
}
