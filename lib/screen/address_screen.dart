import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product_client/model/product_model.dart';
import 'package:product_client/screen/order_screen.dart';

// ignore: must_be_immutable
class AddressScreen extends StatefulWidget {
  final String userid;
  List<Product> cartList;
   AddressScreen({super.key, required this.userid,required this.cartList});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final userName = TextEditingController();
  final userStreet = TextEditingController();
  final userCity = TextEditingController();
  final userState = TextEditingController();
  final userZipCode = TextEditingController();
  final userCountry = TextEditingController();

  bool isAddressFetched = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Address Form"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the user name",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userStreet,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the user address",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userCity,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the user city",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userState,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the user state",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userZipCode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the user zip-code",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userCountry,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter the user country",
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
           ElevatedButton(
  onPressed: () async {
    Map<String, dynamic> cardProduct = {
      'userid': widget.userid,
      'name': userName.text,
      'street': userStreet.text,
      'city': userCity.text,
      'state': userState.text,
      'zipcode': userZipCode.text.toString(),
      'country': userCountry.text,
    };

    if (isAddressFetched) {
       updateData(widget.userid);
    } else {
       saveAddress(cardProduct);
    }

    widget.cartList.clear();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderScreen(),
      ),
    );
  },
  child: Text(isAddressFetched ? "Confirm ADDRESS" : "SAVE ADDRESS"),
),

              ElevatedButton(
                onPressed: () {
                  // getData();
                },
                child: Text("Current Location"),
              ),
            ],
          ),
        ],
      ),
    );
  }

    void getData() async {
    final url = Uri.parse("http://localhost:3000/api/address/${widget.userid}");
    
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          final address = data['address'];
          setState(() {
            userName.text = address['name'];
            userStreet.text = address['street'];
            userCity.text = address['city'];
            userState.text = address['state'];
            userZipCode.text = address['zipcode'].toString();
            userCountry.text = address['country'];
            isAddressFetched = true;
          });
        } else {
          debugPrint("No address found for this user.");
        }
      } else {
        debugPrint(
            "Failed to fetch address. Status Code: ${response.statusCode}");
      }
    
  }

  void saveAddress(Map data) async {
    final url = Uri.parse("http://localhost:3000/api/address");
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
      
  }

  void updateData(String userId) async {
    final url = Uri.parse("http://localhost:3000/api/address/$userId");
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': userName.text,
        'street': userStreet.text,
        'city': userCity.text,
        'state': userState.text,
        'zipcode': userZipCode.text.toString(),
        'country': userCountry.text,
      }),
    );

    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(resData['message'] ?? "Address updated successfully")),
      );
    }
  }

}







