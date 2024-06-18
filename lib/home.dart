import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_ecommerce/orders/keranjang_page.dart';
import 'package:project_ecommerce/orders/pesanan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_ecommerce/category/accesories_page.dart';
import 'package:project_ecommerce/category/bag_page.dart';
import 'package:project_ecommerce/category/clothing_page.dart';
import 'package:project_ecommerce/category/shoes_page.dart';
import 'package:project_ecommerce/models/model_category.dart' as cat_model;
import 'package:project_ecommerce/login/login_page.dart';
import 'package:project_ecommerce/models/model_user.dart';
import 'package:project_ecommerce/models/model_produk.dart';
import 'package:project_ecommerce/product/detail_product_page.dart';
import 'package:project_ecommerce/product/favorite_page.dart';
import 'package:project_ecommerce/product/list_product_page.dart';
import 'package:project_ecommerce/users/list_user_page.dart';
import 'package:project_ecommerce/utils/session_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? username;
  String? userId;
  late bool _isLoading;
  List<Datum> newArrivals = [];
  List<Datum> favoriteList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDataSession();
    _isLoading = true;
    _fetchNewArrivals();
  }

  Future<void> getDataSession() async {
    bool hasSession = await sessionManager.getSession();
    if (hasSession) {
      setState(() {
        username = sessionManager.username;
        userId = sessionManager.id;
        print('Data session: $username');
      });
      await _loadFavorites();
    } else {
      print('Session tidak ditemukan!');
    }
  }

  Future<void> _fetchNewArrivals() async {
    try {
      List<Datum> products = await ListProductPage.getNewArrivals();
      setState(() {
        newArrivals = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch new arrivals: $e');
    }
  }

  Future<List<cat_model.Datum>> fetchCategories() async {
    const url = 'http://192.168.1.8/ecommerce_server/kategori.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final modelCategory = cat_model.ModelCategory.fromJson(jsonResponse);
      if (!modelCategory.isSuccess) {
        throw Exception('Failed to load categories: ${modelCategory.message}');
      }
      return modelCategory.data;
    } else {
      throw Exception('Failed to load categories from API');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListProductPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoritePage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PesananPage()),
        );
        break;
      case 4:
        ModelUsers currentUser = ModelUsers(
          id: int.parse(sessionManager.id!),
          username: sessionManager.username!,
          email: sessionManager.email!,
          fullname: sessionManager.fullname!,
          nohp: sessionManager.nohp!,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListUserPage(currentUser: currentUser)),
        );
        break;
    }
  }

  String formatRupiah(String harga) {
    final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');
    return numberFormat.format(double.parse(harga));
  }

  void toggleFavorite(Datum product) async {
    if (userId == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = '${userId}_favorite_${product.id_produk}';
    setState(() {
      if (favoriteList.contains(product)) {
        favoriteList.remove(product);
        prefs.remove(key);
      } else {
        favoriteList.add(product);
        prefs.setBool(key, true);
      }
    });
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (userId == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Datum> allProducts = await ListProductPage.getNewArrivals();
    List<Datum> loadedFavorites = [];

    for (Datum product in allProducts) {
      String key = '${userId}_favorite_${product.id_produk}';
      bool isFavorite = prefs.getBool(key) ?? false;
      if (isFavorite) {
        loadedFavorites.add(product);
      }
    }

    setState(() {
      favoriteList = loadedFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Ecommerce",
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF5C6E9D),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Hi, ${sessionManager.username ?? ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Jost',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'Cart',
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KeranjangPage()),
                );
              },
            ),
            // IconButton(
            //   icon: const Icon(Icons.notifications),
            //   tooltip: 'Notifications',
            //   color: Colors.white,
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => KeranjangPage()),
            //     );
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Logout',
              color: Colors.white,
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
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFAABBEE),
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Category'),
            ],
          ),
        ),
        backgroundColor: Color(0xFFA2BCF6),
        body: TabBarView(
          children: [
            _buildHomeTab(context),
            _buildCategoryTab(context),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Color(0xFF5C6E9D),
          selectedItemColor: Colors.black,
          unselectedItemColor: Color(0xFFAABBEE),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.production_quantity_limits),
              label: 'Product',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/slideshow.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16.0),
                Text(
                  "New Arrivals",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Jost',
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 16.0),
                _isLoading
                    ? CircularProgressIndicator()
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: newArrivals.length,
                        itemBuilder: (context, index) {
                          final product = newArrivals[index];
                          final imageUrl =
                              "http://192.168.1.8/ecommerce_server/${product.gambar}";
                          return Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product.nama_produk,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        fontFamily: 'Jost',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(product.harga),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.0,
                                      fontFamily: 'Jost',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  // IconButton(
                                  //   icon: Icon(
                                  //     favoriteList.contains(product)
                                  //         ? Icons.favorite
                                  //         : Icons.favorite_border,
                                  //     color: favoriteList.contains(product)
                                  //         ? Colors.red
                                  //         : null,
                                  //   ),
                                  //   onPressed: () {
                                  //     toggleFavorite(product);
                                  //   },
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCategoryTab(BuildContext context) {
  //   return FutureBuilder<List<cat_model.Datum>>(
  //     future: fetchCategories(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Text("Error: ${snapshot.error}");
  //       } else if (snapshot.hasData) {
  //         return ListView.builder(
  //           itemCount: snapshot.data!.length,
  //           itemBuilder: (context, index) {
  //             final category = snapshot.data![index];
  //             return ListTile(
  //               title: Text(category.nama_kategori),
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => ListProductPage(categoryId: category.id_kategori),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         );
  //       } else {
  //         return Text("No categories found");
  //       }
  //     },
  //   );
  // }
  Widget _buildCategoryTab(BuildContext context) {
    return FutureBuilder<List<cat_model.Datum>>(
      future: fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Adjust based on your design requirement
              childAspectRatio: 3 / 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final category = snapshot.data![index];
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListProductPage(categoryId: category.id_kategori),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 40), // Example icon
                      SizedBox(height: 10),
                      Text(
                        category.nama_kategori,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Text("No categories found");
        }
      },
    );
  }
}
