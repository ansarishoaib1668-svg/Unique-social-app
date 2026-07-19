import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Viewgram",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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

          // Stories
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.orange,
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey[800],
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "User${index + 1}",
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
            "Building a new social world 🌎",
          ),
        ],
      ),

      bottomNavigationBar: Container(
        color: Colors.black,
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
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
          height: 320,
          width: double.infinity,
          color: Colors.grey[900],
          child: const Icon(
            Icons.image,
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
                  size: 26),

              SizedBox(width: 18),

              Icon(Icons.send_outlined,
                  color: Colors.white,
                  size: 26),
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

        const SizedBox(height: 15),
      ],
    );
  }
} 
