import 'dart:convert';

ModelProduk modelProdukFromJson(String str) =>
    ModelProduk.fromJson(json.decode(str));

String modelProdukToJson(ModelProduk data) => json.encode(data.toJson());

class ModelProduk {
  bool isSuccess;
  String message;
  List<Datum> data;

  ModelProduk({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ModelProduk.fromJson(Map<String, dynamic> json) => ModelProduk(
        isSuccess: json["isSuccess"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String id_produk;
  String id_kategori;
  String nama_produk;
  String gambar;
  String harga;
  String keterangan;
  String created_at;

  Datum({
    required this.id_produk,
    required this.id_kategori,
    required this.nama_produk,
    required this.gambar,
    required this.harga,
    required this.keterangan,
    required this.created_at,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id_produk: json["id_produk"].toString(), // Convert to String if not already
    id_kategori: json["id_kategori"].toString(), // Convert to String, handle possible integer
    nama_produk: json["nama_produk"] ?? 'No Content', // Default if null
    gambar: json["gambar"] ?? '', // Default if null
    harga: json["harga"].toString(), // Convert to String to handle integer
    keterangan: json["keterangan"] ?? '', // Default if null
    created_at: json["created_at"] ?? '', // Default if null
  );

  Map<String, dynamic> toJson() => {
    "id_produk": id_produk,
    "id_kategori": id_kategori,
    "nama_produk": nama_produk,
    "gambar": gambar,
    "harga": harga,
    "keterangan": keterangan,
    "created_at": created_at,
  };
}
