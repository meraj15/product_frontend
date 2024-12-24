import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product_client/drawer.dart';
import 'package:product_client/model/product_model.dart';
import 'package:product_client/screen/add_product_screen.dart';
import 'package:product_client/screen/favourite_screen.dart';
import 'package:product_client/screen/login_screen.dart';
import 'package:product_client/screen/sign_up.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Client APP"),
        
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FavouriteScreen(),
                  ),
                );
              },
              icon: Icon(Icons.favorite_border,color: Colors.red,)),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(),
                  ),
                );
              },
              icon: Icon(Icons.shopping_bag_outlined))
        ],
      ),
      drawer:const AppDrawer(),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.network(products[index].image),
              title: Text(products[index].title),
              subtitle: Row(
                children: [
                  Text("\$${products[index].price.toString()}"),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(products[index].category),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () {
                      
                        Map<String, dynamic> FavouriteProduct = {
                          'id': products[index].id,
                          'title': products[index].title,
                          'discription': "hello",
                          'image': products[index].image,
                          'price': products[index].price,
                          'category': products[index].category,
                          'userid': userID
                        };
                        debugPrint("userID : $userID");
                        postfavouriteData(FavouriteProduct);
                      },
                      child: Text("Add")),
                  IconButton(
                      onPressed: () {
                        Map<String, dynamic> cardProduct = {
                          'id': products[index].id,
                          'title': products[index].title,
                          'discription': "hello",
                          'image': products[index].image,
                          'price': products[index].price,
                          'category': products[index].category,
                          'userid': userID
                        };
                        debugPrint("userID : $userID");
                        postData(cardProduct);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Added Successfull"),
                            duration: Duration(microseconds: 900),
                          ),
                        );
                      },
                      icon: Icon(Icons.add)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void getData() async {
    const url = "http://localhost:3000/api/products";
    final response = await http.get(Uri.parse(url));
    final decodeJson = jsonDecode(response.body) as List<dynamic>;
    setState(() {
      products = decodeJson.map((json) => Product.fromJson(json)).toList();
    });
  }

void postData(Map<String, dynamic> pdata) async {
  pdata['price'] = double.tryParse(pdata['price'].toString()) ?? 0.0;

  var url = Uri.parse("http://localhost:3000/api/carts");
 await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(pdata),
  );
  getData();
}

void postfavouriteData(Map<String, dynamic> pdata) async {
  // Ensure price is a valid double
  pdata['price'] = double.tryParse(pdata['price'].toString()) ?? 0.0;

  var url = Uri.parse("http://localhost:3000/api/favourites");
  final res = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(pdata),
  );
  debugPrint("Data posted successfully in favourites: ${res.body}");
  getData();
}



  // void deleteData(int index) async {
  //   final idToDelete = products[index].id;

  //   try {
  //     final url = Uri.parse("http://localhost:3000/api/products/$idToDelete");
  //     final response = await http.delete(url);

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         products.removeAt(index);
  //       });
  //     } else {
  //       debugPrint(
  //           "Failed to delete data. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     debugPrint("Error deleting data: $e");
  //   }
  // }

  // void updateData(int index) async {
  //   final int idToUpdate = products[index].id;

  //   final url = Uri.parse("http://localhost:3000/api/products/$idToUpdate");

  //   await http.patch(
  //     url,
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "title": productTitle.text,
  //       "discription": productDiscription.text,
  //       "price": productPrice.text,
  //       "image": productImage.text,
  //       "category": productCategory.text
  //     }),
  //   );

  //   getData();
  // }
}
