import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:product_client/model/product_model.dart';
import 'package:product_client/screen/address_screen.dart';
import 'package:product_client/screen/sign_up.dart';

class AddProductScreen extends StatefulWidget {
  AddProductScreen({
    super.key,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  List<Product> addProduct = [];
  @override
  void initState() {
    getCartsData(userID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product Screen"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: addProduct.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Image.network(addProduct[index].image),
                      title: Text(addProduct[index].title),
                      subtitle: Row(
                        children: [
                          Text("\$${addProduct[index].price.toString()}"),
                          const SizedBox(
                            width: 8.0,
                          ),
                          Text(addProduct[index].category),
                        ],
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            deleteData(index);
                            setState(() {});
                          },
                          icon: Icon(Icons.delete)),
                    ),
                  );
                }),
          ),
          ElevatedButton(
              onPressed: () async{
               await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressScreen(cartList: addProduct,userid: userID,),
                  ),
                );
                setState(() {}); 
              },
              child: Text("CheckOut"))
        ],
      ),
    );
  }

  void getCartsData(String userId) async {
    final url = "http://localhost:3000/api/carts/$userId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodeJson = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        addProduct = decodeJson.map((json) => Product.fromJson(json)).toList();
        debugPrint("User ID: $addProduct");
      });
    } else {
      debugPrint("Failed to load cart data.");
      debugPrint("User ID: $addProduct");
    }
  }

  void deleteData(int index) async {
    final idToDelete = addProduct[index].id;

    try {
      final url = Uri.parse("http://localhost:3000/api/carts/$idToDelete");
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          addProduct.removeAt(index);
        });
      } else {
        debugPrint(
            "Failed to delete data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error deleting data: $e");
    }
  }
}


