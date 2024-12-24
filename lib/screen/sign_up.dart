import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product_client/screen/home_screen.dart';

String userID = "";

class SignUpScreen extends StatefulWidget {
  String emailUser;
  SignUpScreen({super.key, required this.emailUser});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final userName = TextEditingController();
  final userEmail = TextEditingController();
  final userPassword = TextEditingController();
  final userConfirmPassword = TextEditingController();
  final userMobile = TextEditingController();
  
String errorMessage = "";
  @override
  void initState() {
    debugPrint('email : ${widget.emailUser}');
    userEmail.text = widget.emailUser;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign-UP Screen"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the name",
              ),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userConfirmPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the confirm password",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userMobile,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the mobile number",
              ),
            ),
          ),
          ElevatedButton(
  onPressed: () {
    if (userConfirmPassword.text == userPassword.text) {
      setState(() {
        errorMessage = ""; 
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );

      Map<String, dynamic> userInfo = {
        'name': userName.text,
        'email': userEmail.text,
        'password': userPassword.text,
        'mobile':userMobile.text,
      };
      postData(userInfo);
    } else {
      setState(() {
        errorMessage = "Password does not match the confirm password.";
      });
    }
  },
  child: Text("Submit"),
),
if ( errorMessage.isNotEmpty)
  Text(
    errorMessage,
    style: TextStyle(color: Colors.red),
  ),
        ],
      ),
   
    );
  }

  void postData(Map<String, dynamic> pdata) async {
    debugPrint("pdata: $pdata");
    var url = Uri.parse("http://localhost:3000/api/signup");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(pdata),
    );
    // debugPrint("Data posted successfully in cards: ${res.body}");
    var jsonData = jsonDecode(res.body);
    userID = jsonData['userId'];
    debugPrint("userID in Sign up screen: $userID");
  }
}