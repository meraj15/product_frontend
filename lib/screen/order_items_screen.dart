import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:product_client/model/product_model.dart';
import 'package:product_client/screen/sign_up.dart';

class OrderItems extends StatefulWidget {
  final String orderId;
  final String orderstatus;
  final String userAddress;

  const OrderItems(
      {super.key,
      required this.orderId,
      required this.orderstatus,
      required this.userAddress});

  @override
  State<OrderItems> createState() => _OrderItemsState();
}

class _OrderItemsState extends State<OrderItems> {
  List<Product> orderedItems = [];
  String username = "";
  @override
  void initState() {
    super.initState();
    getOrderItems(widget.orderId);
    fetchUserOrders(userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: orderedItems.isEmpty
          ? const Center(child: Text("No items found for this order."))
          : ListView.builder(
              itemCount: orderedItems.length,
              itemBuilder: (context, index) {
                final order = orderedItems[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(order.image),
                    title: Text(order.title),
                    subtitle: Row(
                      children: [
                        Text("\$${order.price.toString()}"),
                        const SizedBox(width: 8.0),
                        Text(order.category),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomSheet: GestureDetector(
        onTap: () async {
          if (widget.orderstatus == "Delivered") {
            final pdf = await _generateInvoicePdf();
            await Printing.sharePdf(
                bytes: await pdf.save(), filename: 'invoice.pdf');
          }
        },
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: const BoxDecoration(color: Colors.orange),
          child: const Center(
            child: Text(
              "Generate Invoice PDF",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getOrderItems(String orderId) async {
    final url = "http://192.168.0.110:3000/api/orderitems/$orderId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          orderedItems =
              decodedJson.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        debugPrint(
            "Failed to fetch order items. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching order items: $e");
    }
  }

  void fetchUserOrders(String userId) async {
    final url = "http://192.168.0.110:3000/api/myorders/$userId";
    final response = await http.get(Uri.parse(url));
    final decodeJson = jsonDecode(response.body) as List<dynamic>;
    username = decodeJson[0]["name"];
  }

  Future<pw.Document> _generateInvoicePdf() async {
    final pdf = pw.Document();

    final finalAddress = widget.userAddress.split(',');
    final addressLine1 = finalAddress.length >= 2
        ? "${finalAddress[0].trim()}, ${finalAddress[1].trim()}"
        : widget.userAddress;
    final addressLine2 = finalAddress.length >= 4
        ? "${finalAddress[2].trim()}, ${finalAddress[3].trim()}"
        : "";

    final List<List<String>> tableData = orderedItems.map((item) {
      return [
        item.title,
        "1",
        "\$${item.price.toString()}",
        "\$${item.price.toString()}"
      ];
    }).toList();

    final double subtotal =
        orderedItems.fold(0.0, (sum, item) => sum + item.price);
    final double tax = subtotal * 0.1;
    final double total = subtotal + tax;
    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(32)),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Invoice', style: pw.TextStyle(fontSize: 24)),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('E-commerce App',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('123, AM Company'),
                  pw.SizedBox(height: 4),
                  pw.Text('Mumbai, India'),
                  pw.SizedBox(height: 4),
                  pw.Text('Email: am@gmail.com'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Order ID: ${widget.orderId}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Order Date: 2024-12-22'),
                  pw.SizedBox(height: 4),
                  pw.Text('Invoice Date: 2024-12-22'),
                  pw.SizedBox(height: 4),
                  pw.Text('Due Date: 2025-01-05'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Bill To:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              )),
          pw.SizedBox(height: 4),
          pw.Text(username),
          pw.Text(addressLine1),
          pw.Text(addressLine2),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey),
            headers: ['Item', 'Quantity', 'Unit Price', 'Total'],
            data: tableData,
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
            cellStyle: pw.TextStyle(fontSize: 10),
            headerDecoration: pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            cellPadding: const pw.EdgeInsets.all(8),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Tax (10%): \$${tax.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Total: \$${total.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    return pdf;
  }
}
