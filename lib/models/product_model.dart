import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String? id;
  String brandName;
  DateTime createdAt;
  List<String> images;
  bool isAvailable;
  bool isHot;
  bool isNew;
  String name;
  String productCategory;
  String productCode;
  List<String> productDetails;
  String productModel;
  String productVideo;
  Map<String, dynamic> quantityDiscount;
  double retailPrice;
  int stock;
  String unit;
  String warranty;
  double wholesalePrice;

  ProductModel({
    this.id,
    required this.brandName,
    required this.createdAt,
    required this.images,
    required this.isAvailable,
    required this.isHot,
    required this.isNew,
    required this.name,
    required this.productCategory,
    required this.productCode,
    required this.productDetails,
    required this.productModel,
    required this.productVideo,
    required this.quantityDiscount,
    required this.retailPrice,
    required this.stock,
    required this.unit,
    required this.warranty,
    required this.wholesalePrice,
  });

  // Firebase থেকে data পাওয়ার পর map থেকে object create করার method
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      brandName: map['brandName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      images: List<String>.from(map['images'] ?? []),
      isAvailable: map['isAvailable'] ?? false,
      isHot: map['isHot'] ?? false,
      isNew: map['isNew'] ?? false,
      name: map['name'] ?? '',
      productCategory: map['productCategory'] ?? '',
      productCode: map['productCode'] ?? '',
      productDetails: List<String>.from(map['productDetails'] ?? []),
      productModel: map['productModel'] ?? '',
      productVideo: map['productVideo'] ?? '',
      quantityDiscount: Map<String, dynamic>.from(
        map['quantityDiscount'] ?? {},
      ),
      retailPrice: (map['retailPrice'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      unit: map['unit'] ?? '',
      warranty: map['warranty'] ?? '',
      wholesalePrice: (map['wholesalePrice'] ?? 0).toDouble(),
    );
  }

  // Object কে map এ convert করার method (যদি data save করতে চান)
  Map<String, dynamic> toMap() {
    return {
      'brandName': brandName,
      'createdAt': Timestamp.fromDate(createdAt),
      'images': images,
      'isAvailable': isAvailable,
      'isHot': isHot,
      'isNew': isNew,
      'name': name,
      'productCategory': productCategory,
      'productCode': productCode,
      'productDetails': productDetails,
      'productModel': productModel,
      'productVideo': productVideo,
      'quantityDiscount': quantityDiscount,
      'retailPrice': retailPrice,
      'stock': stock,
      'unit': unit,
      'warranty': warranty,
      'wholesalePrice': wholesalePrice,
    };
  }
}
