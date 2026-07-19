import 'package:flutter/material.dart';

void main() {
  runApp(const ViewgramApp());
}

class ViewgramApp extends StatelessWidget {
  const ViewgramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Viewgram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff090979),
              Color(0xff2E3192),
              Color(0xff1CB5E0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.camera_alt_rounded,
                size: 65,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "VIEWGRAM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Welcome to Viewgram",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Connect • Share • Discover",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: 280,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text("Login"),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 280,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text("Create Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePassword = true;
  bool rememberMe = false;
final usernameController = TextEditingController();
final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Viewgram Login"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
  controller: passwordController,
    obscureText: hidePassword,
  decoration: InputDecoration(
    labelText: "Password",
    border: const OutlineInputBorder(),
   prefixIcon: const Icon(Icons.lock),
    suffixIcon: IconButton(
      icon: Icon(
        hidePassword
            ? Icons.visibility_off
            : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          hidePassword = !hidePassword;
        });
      },
    ),
  ),
),

            const SizedBox(height: 15),

            TextField(
  controller: usernameController,
  decoration: const InputDecoration(
    labelText: "Username",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.person),
  ),
),

const SizedBox(height: 15),

            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value!;
                    });
                  },
                ),
                const Text("Remember Me"),
              ],
            ),

            Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {},
    child: const Text("Forgot Password?"),
  ),
),

const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
  print("Username: '${usernameController.text}'");
  print("Password: '${passwordController.text}'");

  if (usernameController.text == "shoaib" &&
      passwordController.text == "908070") {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login Successful"),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Wrong Username or Password"),
      ),
    );
  }
},
    child: const Text("Login"),
  ),
),

          ],
        ),
      ),
    );
  }
}


class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Create Account"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
