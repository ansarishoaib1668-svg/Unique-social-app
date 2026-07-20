import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,

      appBar: AppBar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
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
        unselectedItemColor: Colors.grey,
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

          postCard(
            "Shaad",
            "Welcome to Viewgram 🚀",
          ),

          postCard(
            "Creator",
            "Share your moments ✨",
          ),

          postCard(
            "Developer",
            "Building social world 🌎",
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
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


  Widget postCard(String user, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
            child: Icon(
              Icons.person,
              color: Colors.black,
            ),
          ),

          title: Text(
            user,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          trailing: const Icon(
            Icons.more_vert,
            color: Colors.black,
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

        const Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.favorite_border,
                  color: Colors.black,
                  size: 28),

              SizedBox(width: 18),

              Icon(Icons.chat_bubble_outline,
                  color: Colors.black,
                  size: 27),

              SizedBox(width: 18),

              Icon(Icons.send_outlined,
                  color: Colors.black,
                  size: 27),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            caption,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }
}
