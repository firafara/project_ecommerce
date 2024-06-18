// import 'dart:convert';
//
// ModelCart modelCartFromJson(String str) => ModelCart.fromJson(json.decode(str));
//
// String modelCartToJson(ModelCart data) => json.encode(data.toJson());
//
// class ModelCart {
//   bool isSuccess;
//   String message;
//   List<Datum> data;
//
//   ModelCart({
//     required this.isSuccess,
//     required this.message,
//     required this.data,
//   });
//
//   factory ModelCart.fromJson(Map<String, dynamic> json) => ModelCart(
//     isSuccess: json["isSuccess"],
//     message: json["message"],
//     data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "isSuccess": isSuccess,
//     "message": message,
//     "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   };
//
//   // Define the getter for id_produk
//   String get id_produk => data.first.id_produk; // Assuming id_produk is accessed from the first item in the list
// }
//
//
// class Datum {
//   String id_produk;
//   String? nama_produk;
//   String? gambar;
//   String harga;
//   int jumlah;
//
//   Datum({
//     required this.id_produk,
//     this.nama_produk,
//     this.gambar,
//     required this.harga,
//     required this.jumlah,
//   });
//
//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//     id_produk: json["id_produk"] as String,
//     nama_produk: json["nama_produk"] as String?,
//     gambar: json["gambar"] as String?,
//     harga: json["harga"] as String,
//     jumlah: int.parse(json["jumlah"]), // Convert string to int here
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id_produk": id_produk,
//     "nama_produk": nama_produk ?? "",
//     "gambar": gambar ?? "",
//     "harga": harga,
//     "jumlah": jumlah,
//   };
// }
//
import 'dart:convert';

ModelCart modelCartFromJson(String str) => ModelCart.fromJson(json.decode(str));

String modelCartToJson(ModelCart data) => json.encode(data.toJson());

class ModelCart {
  bool isSuccess;
  String message;
  List<CartDatum> data;

  ModelCart({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ModelCart.fromJson(Map<String, dynamic> json) => ModelCart(
    isSuccess: json["isSuccess"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null
        ? List<CartDatum>.from(json["data"].map((x) => CartDatum.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "isSuccess": isSuccess,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CartDatum {
  String id_keranjang;
  String id_produk;
  String harga;
  int jumlah;
  String nama_produk;
  String gambar;

  CartDatum({
    required this.id_keranjang,
    required this.id_produk,
    required this.harga,
    required this.jumlah,
    required this.nama_produk,
    required this.gambar,
  });

  factory CartDatum.fromJson(Map<String, dynamic> json) {
    return CartDatum(
      id_keranjang: json["id_keranjang"] ?? '',
      id_produk: json["id_produk"] ?? '',
      harga: json["harga"] ?? '0',
      jumlah: json["jumlah"] != null ? int.tryParse(json["jumlah"].toString()) ?? 0 : 0,
      nama_produk: json["nama_produk"] ?? '',
      gambar: json["gambar"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id_keranjang": id_keranjang,
    "id_produk": id_produk,
    "harga": harga,
    "jumlah": jumlah,
    "nama_produk": nama_produk,
    "gambar": gambar,
  };
}
