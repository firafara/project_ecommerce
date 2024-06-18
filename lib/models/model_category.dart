import 'dart:convert';

ModelCategory modelCategoryFromJson(String str) =>
    ModelCategory.fromJson(json.decode(str));

String modelCategoryToJson(ModelCategory data) => json.encode(data.toJson());

class ModelCategory {
  bool isSuccess;
  String message;
  List<Datum> data;

  ModelCategory({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory ModelCategory.fromJson(Map<String, dynamic> json) => ModelCategory(
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
  String id_kategori;
  String nama_kategori;

  Datum({
    required this.id_kategori,
    required this.nama_kategori,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id_kategori: json["id_kategori"].toString(), // Convert to String if not already
    nama_kategori: json["nama_kategori"] ?? '', // Default if null
  );

  Map<String, dynamic> toJson() => {
    "id_kategori": id_kategori,
    "nama_kategori": nama_kategori,
  };
}
