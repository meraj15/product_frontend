import 'package:flutter/material.dart';
import 'package:product_client/screen/my_order_screen.dart';

class AppDrawer extends StatelessWidget {

  const AppDrawer({super.key,});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("name"),
            accountEmail: Text("user@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "JD",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text("My Orders"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOrderScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
