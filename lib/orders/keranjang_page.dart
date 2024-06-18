// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:project_ecommerce/models/model_cart.dart' as cart_model;
// import 'package:project_ecommerce/product/detail_product_page.dart';
// import 'package:project_ecommerce/utils/session_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class KeranjangPage extends StatefulWidget {
//   const KeranjangPage({Key? key});
//
//   @override
//   State<KeranjangPage> createState() => _KeranjangPageState();
// }
//
// class _KeranjangPageState extends State<KeranjangPage> {
//   late List<cart_model.CartDatum> _cartItems = [];
//   String? userId;
//   List<cart_model.CartDatum> _selectedItems = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserId();
//   }
//
//   Future<void> _loadUserId() async {
//     bool hasSession = await sessionManager.getSession();
//     if (hasSession) {
//       setState(() {
//         userId = sessionManager.id;
//       });
//       _loadCart();
//     } else {
//       print('Session not found!');
//     }
//   }
//
//   Future<void> clearSession() async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     await pref.clear();
//     print("Session cleared");
//   }
//
//   Future<void> _loadCart() async {
//     if (userId == null) {
//       print("User ID is null, cannot load cart.");
//       return;
//     }
//
//     final response = await http.get(
//       Uri.parse('http://192.168.31.53/ecommerce_server/get_cart.php?id_user=$userId'),
//     );
//
//     if (response.statusCode == 200) {
//       final responseBody = jsonDecode(response.body);
//       print("Raw cart data: ${response.body}");
//
//       if (responseBody is Map<String, dynamic> && responseBody['data'] is List) {
//         try {
//           List<dynamic> dataList = responseBody['data'];
//           List<cart_model.CartDatum> cartItems = dataList.map((data) {
//             print("Parsing item: $data");
//             final parsedItem = cart_model.CartDatum.fromJson(data);
//             print("Parsed item: ${parsedItem.toJson()}");
//             return parsedItem;
//           }).toList();
//
//           setState(() {
//             _cartItems = cartItems;
//           });
//
//           print("Loaded items: ${_cartItems.map((e) => e.toJson()).toList()}");
//         } catch (e) {
//           print('Error parsing cart items: $e');
//         }
//       } else {
//         print('Unexpected JSON structure: $responseBody');
//       }
//     } else {
//       print('Failed to load cart, status code: ${response.statusCode}');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to load cart')));
//     }
//   }
//
//   void _toggleFavorite(cart_model.CartDatum product) {
//     setState(() {
//       // Implement the toggle favorite functionality
//     });
//   }
//
//   Future<void> _addToCart(cart_model.CartDatum product) async {
//     // Implement the add to cart functionality
//   }
//
//   void _incrementQuantity(cart_model.CartDatum product) {
//     setState(() {
//       product.jumlah += 1;
//     });
//   }
//
//   void _decrementQuantity(cart_model.CartDatum product) {
//     setState(() {
//       if (product.jumlah > 1) {
//         product.jumlah -= 1;
//       } else {
//         _cartItems.remove(product);
//       }
//     });
//   }
//
//   void _toggleSelection(cart_model.CartDatum product) {
//     setState(() {
//       if (_selectedItems.contains(product)) {
//         _selectedItems.remove(product);
//       } else {
//         _selectedItems.add(product);
//       }
//     });
//   }
//
//   void _checkoutSelectedItems() {
//     // Implement the checkout functionality for selected items
//   }
//
//   String formatCurrency(String price) {
//     double value = double.parse(price);
//     return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
//         RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Keranjang'),
//         backgroundColor: Color(0xFF5C6E9D),
//     ),
//       backgroundColor: Color(0xFFA2BCF6),
//       body: _cartItems.isEmpty
//           ? Center(child: Text('Keranjang kosong'))
//           : SingleChildScrollView(
//         child: Column(
//           children: [
//             ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: _cartItems.length,
//               itemBuilder: (context, index) {
//                 final item = _cartItems[index];
//                 final imageUrl = "http://192.168.31.53/ecommerce_server/${item.gambar}";
//                 return Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   child: GestureDetector(
//                     onTap: () {
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) => DetailProductPage(product: item),
//                       //   ),
//                       // );
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15),
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 7,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: CachedNetworkImage(
//                                 imageUrl: imageUrl,
//                                 fit: BoxFit.cover,
//                                 height: 100,
//                                 width: 100,
//                                 placeholder: (context, url) =>
//                                     CircularProgressIndicator(),
//                                 errorWidget: (context, url, error) =>
//                                     Icon(Icons.error),
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Checkbox(
//                                         value: _selectedItems.contains(item),
//                                         onChanged: (bool? value) {
//                                           _toggleSelection(item);
//                                         },
//                                       ),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               item.nama_produk,
//                                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                             ),
//                                             Text(
//                                               formatCurrency(item.harga),
//                                               style: TextStyle(fontSize: 14, color: Colors.green),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           IconButton(
//                                             icon: Icon(Icons.remove),
//                                             onPressed: () {
//                                               _decrementQuantity(item);
//                                             },
//                                           ),
//                                           Text(item.jumlah.toString()),
//                                           IconButton(
//                                             icon: Icon(Icons.add),
//                                             onPressed: () {
//                                               _incrementQuantity(item);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           IconButton(
//                                             icon: Icon(
//                                               Icons.favorite_border,
//                                               color: Colors.redAccent,
//                                             ),
//                                             onPressed: () {
//                                               _toggleFavorite(item);
//                                             },
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.shopping_cart),
//                                             onPressed: () {
//                                               _addToCart(item).then((_) {
//                                                 // Optionally, refresh the cart page or give visual feedback that the cart has been updated
//                                               });
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: _selectedItems.isEmpty
//                     ? null
//                     : () {
//                   _checkoutSelectedItems();
//                 },
//                 child: Text('Checkout'),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                   textStyle: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_ecommerce/models/model_cart.dart' as cart_model;
import 'package:project_ecommerce/orders/chekout_page.dart';
import 'package:project_ecommerce/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({Key? key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  late List<cart_model.CartDatum> _cartItems = [];
  String? userId;
  List<cart_model.CartDatum> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    bool hasSession = await sessionManager.getSession();
    if (hasSession) {
      setState(() {
        userId = sessionManager.id;
      });
      _loadCart();
    } else {
      print('Session not found!');
    }
  }

  Future<void> clearSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
    print("Session cleared");
  }

  Future<void> _loadCart() async {
    if (userId == null) {
      print("User ID is null, cannot load cart.");
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.8/ecommerce_server/get_cart.php?id_user=$userId'),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print("Raw cart data: ${response.body}");

      if (responseBody is Map<String, dynamic> && responseBody['data'] is List) {
        try {
          List<dynamic> dataList = responseBody['data'];
          List<cart_model.CartDatum> cartItems = dataList.map((data) {
            print("Parsing item: $data");
            final parsedItem = cart_model.CartDatum.fromJson(data);
            print("Parsed item: ${parsedItem.toJson()}");
            return parsedItem;
          }).toList();

          setState(() {
            _cartItems = cartItems;
          });

          print("Loaded items: ${_cartItems.map((e) => e.toJson()).toList()}");
        } catch (e) {
          print('Error parsing cart items: $e');
        }
      } else {
        print('Unexpected JSON structure: $responseBody');
      }
    } else {
      print('Failed to load cart, status code: ${response.statusCode}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load cart')));
    }
  }

  void _toggleFavorite(cart_model.CartDatum product) {
    setState(() {
      // Implement the toggle favorite functionality
    });
  }

  Future<void> _addToCart(cart_model.CartDatum product) async {
    // Implement the add to cart functionality
  }

  void _incrementQuantity(cart_model.CartDatum product) {
    setState(() {
      product.jumlah += 1;
    });
  }

  void _decrementQuantity(cart_model.CartDatum product) {
    setState(() {
      if (product.jumlah > 1) {
        product.jumlah -= 1;
      } else {
        _cartItems.remove(product);
      }
    });
  }

  void _toggleSelection(cart_model.CartDatum product) {
    setState(() {
      if (_selectedItems.contains(product)) {
        _selectedItems.remove(product);
      } else {
        _selectedItems.add(product);
      }
    });
  }

  void _checkoutSelectedItems() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(selectedItems: _selectedItems),
      ),
    );
  }

  String formatCurrency(String price) {
    double value = double.parse(price);
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
        backgroundColor: Color(0xFF5C6E9D),
      ),
      backgroundColor: Color(0xFFA2BCF6),
      body: _cartItems.isEmpty
          ? Center(child: Text('Keranjang kosong'))
          : SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                final imageUrl = "http://192.168.1.8/ecommerce_server/${item.gambar}";
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DetailProductPage(product: item),
                      //   ),
                      // );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _selectedItems.contains(item),
                                        onChanged: (bool? value) {
                                          _toggleSelection(item);
                                        },
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.nama_produk,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formatCurrency(item.harga),
                                              style: TextStyle(fontSize: 14, color: Colors.green),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              _decrementQuantity(item);
                                            },
                                          ),
                                          Text(item.jumlah.toString()),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              _incrementQuantity(item);
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.favorite_border,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () {
                                              _toggleFavorite(item);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.shopping_cart),
                                            onPressed: () {
                                              _addToCart(item).then((_) {
                                                // Optionally, refresh the cart page or give visual feedback that the cart has been updated
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _selectedItems.isEmpty
                    ? null
                    : () {
                  _checkoutSelectedItems();
                },
                child: Text('Checkout'),
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
}
