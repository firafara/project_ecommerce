import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_ecommerce/models/model_cart.dart';
import 'package:project_ecommerce/models/model_produk.dart';
import 'package:intl/intl.dart'; // Tambahkan ini

class DetailProductPage extends StatelessWidget {
  final Datum product;
  const DetailProductPage({Key? key, required this.product}) : super(key: key);

  String formatRupiah(String harga) {
    final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');
    return numberFormat.format(double.parse(harga));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Product",
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C6E9D),
      ),
      backgroundColor: Color(0xFFA2BCF6),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300, // Sesuaikan dengan kebutuhan
              child: CachedNetworkImage(
                imageUrl:
                    "http://192.168.1.8/ecommerce_server/${product.gambar}",
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                product.nama_produk,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                formatRupiah(product.harga), // Gunakan formatRupiah disini
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
            SizedBox(height: 10), // Space below the TabBarView
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                product.keterangan,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
            SizedBox(height: 20), // Space below the TabBarView
          ],
        ),
      ),
    );
  }
}
