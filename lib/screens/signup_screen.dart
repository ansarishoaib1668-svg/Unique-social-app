import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String verificationId = "";
  bool otpSent = false;
  bool otpVerified = false;
  bool loading = false;
  bool hidePassword = true;

  Future<void> sendOTP() async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter phone number")),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$phone",

      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() {
          otpVerified = true;
        });
      },

      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "OTP failed")),
        );
      },

      codeSent: (String id, int? resendToken) {
        setState(() {
          verificationId = id;
          otpSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent")),
        );
      },

      codeAutoRetrievalTimeout: (String id) {
        verificationId = id;
      },
    );

    setState(() => loading = false);
  }


  Future<void> verifyOTP() async {
    try {

      PhoneAuthCredential credential =
          PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        otpVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone verified")),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );

    }
  }


  Future<void> createAccount() async {

    if (!otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verify phone first")),
      );
      return;
    }


    setState(() => loading = true);

    try {

      UserCredential user =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.user!.uid)
          .set({

        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),

      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully"),
        ),
      );


      Navigator.pop(context);


    } on FirebaseAuthException catch(e){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );

    }


    setState(() => loading = false);

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Account"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [


            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height:15),


            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixText: "+91 ",
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height:10),


            ElevatedButton(
              onPressed: loading ? null : sendOTP,
              child: const Text("SEND OTP"),
            ),



            if(otpSent)...[

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "OTP",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height:10),

              ElevatedButton(
                onPressed: verifyOTP,
                child: const Text("VERIFY OTP"),
              ),

            ],


            const SizedBox(height:20),


            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height:15),


            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                  ),

                  onPressed: (){
                    setState(() {
                      hidePassword=!hidePassword;
                    });
                  },
                ),
              ),
            ),


            const SizedBox(height:20),


            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                loading ? null : createAccount,

                child: Text(
                  loading
                  ? "Please wait..."
                  : "CREATE ACCOUNT",
                ),

              ),
            )

          ],
        ),
      ),
    );
  }
}
