import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product_client/screen/order_items_screen.dart';
import 'package:product_client/screen/sign_up.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  List<dynamic> userOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserOrders(userID);
  }

  void fetchUserOrders(String userId) async {
    final url = "http://192.168.0.110:3000/api/myorders/$userId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodeJson = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          userOrders = decodeJson;

          isLoading = false;
        });
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (error) {
      debugPrint("Error fetching user orders: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userOrders.isEmpty
              ? const Center(child: Text("No orders found."))
              : ListView.builder(
                  itemCount: userOrders.length,
                  itemBuilder: (context, index) {
                    final order = userOrders[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Name: ${order['name']}"),
                            Text("Status: ${order['order_status']}"),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Price: ₹${order['price']}"),
                            Text("Address: ${order['address']}"),
                            Text("Mobile: ${order['mobile']}"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderItems(
                                orderId: order['order_id'],
                                orderstatus: order['order_status'],
                                userAddress: order['address'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
