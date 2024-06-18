import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_ecommerce/models/model_cart.dart' as cart_model;
import 'package:project_ecommerce/orders/pesanan_page.dart';
import 'package:project_ecommerce/utils/session_manager.dart';

class CheckoutPage extends StatefulWidget {
  final List<cart_model.CartDatum> selectedItems;

  CheckoutPage({required this.selectedItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController _addressController = TextEditingController();
  String _paymentMethod = 'Cash';
  String? userId = ""; // Menggunakan nullable String

  @override
  void initState() {
    super.initState();
    getDataSession();
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = widget.selectedItems.fold(0, (sum, item) => sum + (item.jumlah * double.parse(item.harga)));

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Color(0xFF5C6E9D),
      ),
      backgroundColor: Color(0xFFA2BCF6),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk yang dibeli:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedItems.length,
                itemBuilder: (context, index) {
                  final item = widget.selectedItems[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage('http://192.168.1.8/ecommerce_server/${item.gambar}'),
                      ),
                      title: Text(item.nama_produk, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.jumlah} x ${formatRupiah(double.parse(item.harga))}'),
                      trailing: Text(formatRupiah(item.jumlah * double.parse(item.harga))),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text('Total: ${formatRupiah(totalAmount)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Metode Pembayaran:', style: TextStyle(fontSize: 16)),
            ListTile(
              title: const Text('Cash'),
              leading: Radio<String>(
                value: 'Cash',
                groupValue: _paymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Alamat Pengiriman',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _checkout(totalAmount);
                },
                child: Text('Konfirmasi Pembayaran'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Future<void> getDataSession() async {
    bool hasSession = await sessionManager.getSession();
    if (hasSession) {
      setState(() {
        userId = sessionManager.id;
      });
    } else {
      print('Session not found!');
    }
  }

  void _checkout(double totalAmount) async {
    // Menyiapkan data untuk dikirim ke server
    Map<String, dynamic> data = {
      "id_user": userId.toString(), // Menggunakan ID pengguna yang diperoleh dari manajer sesi
      "total_amount": totalAmount.toString(),
      "address": _addressController.text,
      "payment_method": _paymentMethod,
      "items": widget.selectedItems.map((item) {
        return {
          "id_produk": item.id_produk,
          "quantity": item.jumlah,
          "price_per_unit": item.harga,
          "subtotal": (item.jumlah * double.parse(item.harga)).toString() // Konversi ke String
        };
      }).toList(),
    };

    // Mengirim data ke server
    var url = 'http://192.168.1.8/ecommerce_server/checkout.php'; // Ganti dengan URL API Anda
    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));

    // Memeriksa status response
    if (response.statusCode == 200) {
      // Jika request berhasil, Anda bisa menavigasi ke halaman pesanan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PesananPage()),
      );
    } else {
      // Jika request gagal, Anda bisa menampilkan pesan kesalahan atau melakukan tindakan lainnya
      print('Request failed with status: ${response.statusCode}.');
    }
  }

}
