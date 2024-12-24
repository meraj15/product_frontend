import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product_client/screen/home_screen.dart';
import 'package:product_client/screen/sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userEmail = TextEditingController();
  String message = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Screen"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userEmail,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the email",
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (userEmail.text.isEmpty) {
                  setState(() {
                    message = "Email and Password cannot be empty.";
                  });
                  return;
                }

                login(userEmail.text);
              },
              child: Text("Login")),
          if (message.isNotEmpty) Text(message)
        ],
      ),
    );
  }

 void login(String email) async {
  const url = "http://localhost:3000/api/login";
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == "success") {
      userID = data['userId'] ?? "No User ID"; 
      debugPrint("userIDss : $userID");

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PasswordScreen(email: email,)),
      );
    } else if (data['status'] == 'error') {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SignUpScreen(
                  emailUser: email,
                )),
      );
    }
  } catch (e) {
    setState(() {
      message = "An error occurred. Please try again.";
    });
    debugPrint("Login Error: $e");
  }
}

}

class PasswordScreen extends StatefulWidget {
  final String email; 

  const PasswordScreen({super.key, required this.email}); 

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final userPassword = TextEditingController();
  String message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Password"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the password",
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (userPassword.text.isEmpty) {
                  setState(() {
                    message = "Password cannot be empty.";
                  });
                  return;
                }

                login2(widget.email, userPassword.text);
                userPassword.clear();
              },
              child: Text("Login")),
          if (message.isNotEmpty) Text(message),
        ],
      ),
    );
  }

  void login2(String email, String password) async {
    const url = "http://localhost:3000/api/password";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          setState(() {
            message = data['message'] ?? "Invalid email or password.";
          });
        }
      } else {
        setState(() {
          message = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        message = "An error occurred. Please try again.";
      });
      debugPrint("Login Error: $e");
    }
  }
}

