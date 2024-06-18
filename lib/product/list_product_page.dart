import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_ecommerce/login/login_page.dart';
import 'package:project_ecommerce/models/model_produk.dart';
import 'package:project_ecommerce/orders/keranjang_page.dart';
import 'package:project_ecommerce/product/detail_product_page.dart';
import 'package:project_ecommerce/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_page.dart';

class ListProductPage extends StatefulWidget {
  final String? categoryId; // Null jika ingin menampilkan semua produk

  const ListProductPage({Key? key, this.categoryId}) : super(key: key);

  @override
  State<ListProductPage> createState() => _ListProductPageState();

  static Future<List<Datum>> getNewArrivals() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.8/ecommerce_server/produk.php'));
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        List<Datum> allData =
            List<Datum>.from(parsed['data'].map((x) => Datum.fromJson(x)));
        allData.sort((a, b) => DateTime.parse(b.created_at)
            .compareTo(DateTime.parse(a.created_at)));
        return allData.take(4).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}

class _ListProductPageState extends State<ListProductPage> {
  String? username;
  String? userId;
  late List<Datum> _productList;
  late List<Datum> _filteredProductList;
  // late List<Datum> _favoriteList; // Make sure it's defined here if you use it here
  // late bool _isLoading;
  TextEditingController _searchController = TextEditingController();
  late List<Datum> _favoriteList = [];
  late bool _isLoading =
      true; // Also initialize other late variables if necessary
  late List<Datum> _cartItems = [];

  @override
  void initState() {
    super.initState();
    getDataSession();
    _fetchProduct();

    if (widget.categoryId != null) {
      fetchProductsByCategory(widget.categoryId!);
    }
    _loadFavorites();
    _loadCart(); // Panggil _loadCart() di sini
  }

  Future<void> _addToCart(Datum product) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You need to be logged in to add items to the cart.")));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.8/ecommerce_server/add_to_cart.php'),
        body: {
          'id_user': userId,
          'id_produk': product.id_produk,
          'jumlah': '1', // This can be adjusted if you implement quantity selection
        },
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 && responseBody['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product added to cart successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseBody['message'] ?? "Failed to add product to cart")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding product to cart: $e")));
    }
  }



  Future<void> getDataSession() async {
    bool hasSession = await sessionManager.getSession();
    if (hasSession) {
      setState(() {
        username = sessionManager.username;
        userId = sessionManager.id; // Ensure this is correctly assigned.
        print(
            'Data session: $username, User ID: $userId'); // This will confirm the values.
      });
    } else {
      print('Session not found!');
    }
  }

  Future<void> clearSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
    print("Session cleared");
  }

  Future<void> _fetchProduct() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.8/ecommerce_server/produk.php'));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      setState(() {
        _productList =
            List<Datum>.from(parsed['data'].map((x) => Datum.fromJson(x)));
        _filteredProductList = _productList;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load produk');
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      final uri = Uri.parse(
          'http://192.168.1.8/ecommerce_server/products_by_category.php?id_kategori=$categoryId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        setState(() {
          _productList =
              List<Datum>.from(parsed['data'].map((x) => Datum.fromJson(x)));
          _filteredProductList = _productList;
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load products for category $categoryId, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // You can handle or log the error more specifically here
      throw Exception('Error: $e');
    }
  }

  void _filterProductList(String query) async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.8/ecommerce_server/produk.php'));
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        List<Datum> allData =
            List<Datum>.from(parsed['data'].map((x) => Datum.fromJson(x)));
        if (query.isNotEmpty) {
          setState(() {
            _filteredProductList = allData
                .where((product) =>
                    product.nama_produk
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    product.harga.toLowerCase().contains(query.toLowerCase()))
                .toList();
          });
        } else {
          setState(() {
            _filteredProductList = allData;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }

  String formatCurrency(String price) {
    double value = double.parse(price);
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // void _toggleFavorite(Datum product) async {
  //   if (userId == null) return; // Make sure the userId is not null.
  //
  //   final response = await http.post(
  //       Uri.parse('http://192.168.31.53/ecommerce_server/add_favorite.php'),
  //       body: {
  //         'id_user': userId,
  //         'id_produk': product.id_produk,
  //       }
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final responseBody = jsonDecode(response.body);
  //     if (responseBody['isSuccess']) {
  //       setState(() {
  //         // Check if the product is already in the favorite list
  //         if (_favoriteList.any((p) => p.id_produk == product.id_produk)) {
  //           _favoriteList.removeWhere((p) => p.id_produk == product.id_produk);
  //         } else {
  //           _favoriteList.add(product); // Add to favorite list if not already added
  //         }
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to toggle favorite")));
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network error")));
  //   }
  // }
  void _toggleFavorite(Datum product) async {
    if (userId == null) return;

    final isCurrentlyFavorited =
        _favoriteList.any((p) => p.id_produk == product.id_produk);
    final response = await http.post(
        Uri.parse('http://192.168.1.8/ecommerce_server/add_favorite.php'),
        body: {
          'id_user': userId,
          'id_produk': product.id_produk,
        });

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['isSuccess']) {
        setState(() {
          if (isCurrentlyFavorited) {
            _favoriteList.removeWhere((p) => p.id_produk == product.id_produk);
          } else {
            _favoriteList.add(product);
          }
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to toggle favorite")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Network error")));
    }
  }
  Future<void> _loadCart() async {
    if (userId == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.8/ecommerce_server/get_cart.php?id_user=$userId'),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      setState(() {
        _cartItems = List<Datum>.from(responseBody['data'].map((item) => Datum.fromJson(item)));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load cart')));
    }
  }


  // Future<void> _loadFavorites() async {
  //   if (userId == null) {
  //     print("User ID is null, cannot load favorites.");
  //     return;
  //   }
  //
  //   final response = await http.get(Uri.parse('http://192.168.31.53/ecommerce_server/get_favorites.php?user_id=$userId'));
  //
  //   if (response.statusCode == 200) {
  //     final responseBody = jsonDecode(response.body);
  //     List<Datum> favoritesFromServer = List<Datum>.from(
  //         responseBody['data'].map((x) => Datum.fromJson(x))
  //     );
  //
  //     setState(() {
  //       _favoriteList = favoritesFromServer;
  //     });
  //   } else {
  //     print('Failed to load favorites from server with status code: ${response.statusCode}');
  //   }
  // }
  Future<void> _loadFavorites() async {
    if (userId == null) {
      print("User ID is null, cannot load favorites.");
      return;
    }

    final response = await http.get(Uri.parse(
        'http://192.168.1.8/ecommerce_server/get_favorites.php?user_id=$userId'));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      List<Datum> favoritesFromServer =
          List<Datum>.from(responseBody['data'].map((x) => Datum.fromJson(x)));

      setState(() {
        _favoriteList = favoritesFromServer;
      });
    } else {
      print(
          'Failed to load favorites from server with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "List Product",
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C6E9D),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Hi, ${username ?? ''}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Jost',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            color: Colors.black,
            onPressed: () {
              setState(() {
                sessionManager.clearSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              });
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFA2BCF6),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterProductList,
                  decoration: InputDecoration(
                    labelText: 'Search Product',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _filteredProductList.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProductList[index];
                        final isFavorite = _favoriteList
                            .any((item) => item.id_produk == product.id_produk);
                        final imageUrl =
                            "http://192.168.1.8/ecommerce_server/${product.gambar}";
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailProductPage(product: product),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(0xFFFFFFFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(product.nama_produk),
                                      subtitle:
                                          Text(formatCurrency(product.harga)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : null,
                                            ),
                                            onPressed: () {
                                              _toggleFavorite(product);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.shopping_cart),
                                            color: Colors.black,
                                            onPressed: () {
                                              _addToCart(product).then((_) {
                                                // Optionally, refresh the cart page or give visual feedback that the cart has been updated
                                              });
                                            },
                                          )

                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
