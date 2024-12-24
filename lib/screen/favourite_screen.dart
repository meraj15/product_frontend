import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:product_client/model/product_model.dart';
import 'package:product_client/screen/address_screen.dart';
import 'package:product_client/screen/login_screen.dart';
import 'package:product_client/screen/sign_up.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<Product> favouriteProduct = [];
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    getFavouriteData(userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Products"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favouriteProduct.isEmpty
              ? const Center(child: Text("No favourites found.")) 
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: favouriteProduct.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: Image.network(
                                favouriteProduct[index].image,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              ),
                              title: Text(favouriteProduct[index].title),
                              subtitle: Row(
                                children: [
                                  Text("\$${favouriteProduct[index].price}"),
                                  const SizedBox(width: 8.0),
                                  Text(favouriteProduct[index].category),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () => deleteData(index),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                  ],
                ),
    );
  }

  void getFavouriteData(String userId) async {
    final url = "http://localhost:3000/api/favourites/$userId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodeJson = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          favouriteProduct = decodeJson
              .map((json) => Product.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        debugPrint("Failed to load favourites: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading favourites: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteData(int index) async {
    final idToDelete = favouriteProduct[index].id;
    final url = Uri.parse("http://localhost:3000/api/favourites/$idToDelete");
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          favouriteProduct.removeAt(index); 
        });
      } else {
        debugPrint("Failed to delete item: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error deleting item: $e");
    }
  }
}
