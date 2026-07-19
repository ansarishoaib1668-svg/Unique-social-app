wimport 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Image.asset(
          'assets/images/20260719213130.png',
          height: 42,
        ),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.white, size: 28),
          SizedBox(width: 18),
          Icon(Icons.send_outlined, color: Colors.white, size: 26),
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
                              Colors.purple,
                            ],
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "User$index",
                        style: const TextStyle(
                          color: Colors.white,
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
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
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
            backgroundColor: Colors.purple,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),

          title: Text(
            user,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          trailing: const Icon(
            Icons.more_vert,
            color: Colors.white,
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
                  color: Colors.white,
                  size: 28),

              SizedBox(width: 18),

              Icon(Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 27),

              SizedBox(width: 18),

              Icon(Icons.send_outlined,
                  color: Colors.white,
                  size: 27),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            caption,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }
}
