import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_ecommerce/models/model_produk.dart';
import 'package:project_ecommerce/utils/session_manager.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Datum> favoriteList = [];
  bool isLoading = true; // Track loading state
  String? userId; // Define userId at the class level

  @override
  void initState() {
    super.initState();
    getSessionAndLoadFavorites(); // new method to handle session and load favorites
  }

  // New method to handle session and loading favorites
  void getSessionAndLoadFavorites() async {
    bool hasSession = await sessionManager.getSession();
    if (hasSession) {
      setState(() {
        userId = sessionManager.id; // Set userId from session manager
      });
      _loadFavorites();
    } else {
      print("Session not found!");
      setState(() => isLoading = false);
    }
  }

  String formatCurrency(String price) {
    double value = double.parse(price);
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Future<void> _loadFavorites() async {
    if (userId == null) {
      print("User ID is null, cannot load favorites.");
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(Uri.parse(
        'http://192.168.1.8/ecommerce_server/get_favorites.php?user_id=$userId'));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      List<Datum> favoritesFromServer =
          List<Datum>.from(responseBody['data'].map((x) => Datum.fromJson(x)));

      setState(() {
        favoriteList = favoritesFromServer;
        isLoading = false;
      });
    } else {
      print(
          'Failed to load favorites from server with status code: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  void _removeFavorite(Datum product) async {
    if (userId == null || product.id_produk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User ID or Product ID is missing")));
      return;
    }

    final response = await http.post(
        Uri.parse('http://192.168.1.8/ecommerce_server/remove_favorite.php'),
        body: {
          'user_id': userId,
          'product_id': product.id_produk,
        });

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200 && responseBody['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Favorite removed successfully")));
      setState(() {
        favoriteList.removeWhere((item) => item.id_produk == product.id_produk);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseBody['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Products'),
        backgroundColor: Color(0xFF5C6E9D),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteList.isEmpty
              ? Center(
                  child: Text(
                    'No favorites added yet!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteList.length,
                  itemBuilder: (context, index) {
                    final product = favoriteList[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.network(
                          "http://192.168.1.8/ecommerce_server/${product.gambar}",
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product.nama_produk),
                        subtitle: Text(
                          formatCurrency(product.harga),
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => _removeFavorite(product),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
