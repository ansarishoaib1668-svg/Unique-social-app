import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.favorite_border, color: Colors.black, size: 28),
          SizedBox(width: 18),
          Icon(Icons.send_outlined, color: Colors.black, size: 26),
          SizedBox(width: 15),
        ],
      ),

      body: ListView(
        children: [

          SizedBox(
            height: 115,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  width: 75,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "User$index",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          PostCard(
            "Shaad",
            "Welcome to Viewgram 🚀",
          ),

          PostCard(
            "Creator",
            "Share your moments ✨",
          ),

          PostCard(
            "Developer",
            "Building social world 🌎",
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "",
          ),
        ],
      ),
    );
  }



}
class PostCard extends StatefulWidget {
  final String user;
  final String caption;

  const PostCard(this.user, this.caption, {super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  int feels = 0;
  final List<String> comments = [];

  void addComment(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      comments.add(text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black),
          ),
          title: Text(
            widget.user,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(Icons.more_vert, color: Colors.black),
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

        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  liked = !liked;
                  feels += liked ? 1 : -1;
                });
              },
              icon: Icon(
                Icons.favorite,
                color: liked ? Colors.red : Colors.black,
              ),
              label: Text(
                "Feel $feels",
                style: const TextStyle(color: Colors.black),
              ),
            ),

            TextButton.icon(
              onPressed: () {
                final controller = TextEditingController();

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Comment"),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Write comment..."
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          addComment(controller.text);
                          Navigator.pop(context);
                        },
                        child: const Text("Post"),
                      )
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline,
                  color: Colors.black),
              label: const Text("Comment",
                  style: TextStyle(color: Colors.black)),
            ),

            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Share option coming soon 🚀"),
                  ),
                );
              },
              icon: const Icon(Icons.send_outlined,
                  color: Colors.black),
              label: const Text("Share",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),

        Text(
          widget.caption,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),

        for (var c in comments)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              "💬 $c",
              style: const TextStyle(color: Colors.black),
            ),
          ),

        const SizedBox(height: 18),
      ],
    );
  }
}

