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
  double purchasePrice;
  int stock;
  int pendingStock;
  String unit;
  String warranty;
  double wholesalePrice;
  int replaceCount;

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
    required this.purchasePrice,
    required this.stock,
    this.pendingStock = 0,
    required this.unit,
    required this.warranty,
    required this.wholesalePrice,
    this.replaceCount = 0,
  });

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
      purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      pendingStock: (map['pendingStock'] ?? 0).toInt(),
      unit: map['unit'] ?? '',
      warranty: map['warranty'] ?? '',
      wholesalePrice: (map['wholesalePrice'] ?? 0).toDouble(),
      replaceCount: (map['replaceCount'] ?? 0).toInt(),
    );
  }

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
      'purchasePrice': purchasePrice,
      'stock': stock,
      'pendingStock': pendingStock,
      'unit': unit,
      'warranty': warranty,
      'wholesalePrice': wholesalePrice,
      'replaceCount': replaceCount,
    };
  }

  double get wholesaleProfit => wholesalePrice - purchasePrice;
  double get retailProfit => retailPrice - purchasePrice;
  double get wholesaleProfitPercentage =>
      purchasePrice > 0 ? ((wholesaleProfit / purchasePrice) * 100) : 0;
  double get retailProfitPercentage =>
      purchasePrice > 0 ? ((retailProfit / purchasePrice) * 100) : 0;

  int get availableStock => stock - pendingStock;
  bool get hasPendingOrders => pendingStock > 0;
  bool get isOutOfStock => availableStock <= 0;
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProductModel {
//   String? id;
//   String brandName;
//   DateTime createdAt;
//   List<String> images;
//   bool isAvailable;
//   bool isHot;
//   bool isNew;
//   String name;
//   String productCategory;
//   String productCode;
//   List<String> productDetails;
//   String productModel;
//   String productVideo;
//   Map<String, dynamic> quantityDiscount;
//   double retailPrice;
//   double purchasePrice;
//   int stock;
//   String unit;
//   String warranty;
//   double wholesalePrice;
//   int replaceCount;

//   ProductModel({
//     this.id,
//     required this.brandName,
//     required this.createdAt,
//     required this.images,
//     required this.isAvailable,
//     required this.isHot,
//     required this.isNew,
//     required this.name,
//     required this.productCategory,
//     required this.productCode,
//     required this.productDetails,
//     required this.productModel,
//     required this.productVideo,
//     required this.quantityDiscount,
//     required this.retailPrice,
//     required this.purchasePrice,
//     required this.stock,
//     required this.unit,
//     required this.warranty,
//     required this.wholesalePrice,
//     this.replaceCount = 0,
//   });

//   factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
//     return ProductModel(
//       id: id,
//       brandName: map['brandName'] ?? '',
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//       images: List<String>.from(map['images'] ?? []),
//       isAvailable: map['isAvailable'] ?? false,
//       isHot: map['isHot'] ?? false,
//       isNew: map['isNew'] ?? false,
//       name: map['name'] ?? '',
//       productCategory: map['productCategory'] ?? '',
//       productCode: map['productCode'] ?? '',
//       productDetails: List<String>.from(map['productDetails'] ?? []),
//       productModel: map['productModel'] ?? '',
//       productVideo: map['productVideo'] ?? '',
//       quantityDiscount: Map<String, dynamic>.from(
//         map['quantityDiscount'] ?? {},
//       ),
//       retailPrice: (map['retailPrice'] ?? 0).toDouble(),
//       purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
//       stock: (map['stock'] ?? 0).toInt(),
//       unit: map['unit'] ?? '',
//       warranty: map['warranty'] ?? '',
//       wholesalePrice: (map['wholesalePrice'] ?? 0).toDouble(),
//       replaceCount: (map['replaceCount'] ?? 0).toInt(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'brandName': brandName,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'images': images,
//       'isAvailable': isAvailable,
//       'isHot': isHot,
//       'isNew': isNew,
//       'name': name,
//       'productCategory': productCategory,
//       'productCode': productCode,
//       'productDetails': productDetails,
//       'productModel': productModel,
//       'productVideo': productVideo,
//       'quantityDiscount': quantityDiscount,
//       'retailPrice': retailPrice,
//       'purchasePrice': purchasePrice,
//       'stock': stock,
//       'unit': unit,
//       'warranty': warranty,
//       'wholesalePrice': wholesalePrice,
//       'replaceCount': replaceCount,
//     };
//   }

//   double get wholesaleProfit => wholesalePrice - purchasePrice;
//   double get retailProfit => retailPrice - purchasePrice;
//   double get wholesaleProfitPercentage =>
//       purchasePrice > 0 ? ((wholesaleProfit / purchasePrice) * 100) : 0;
//   double get retailProfitPercentage =>
//       purchasePrice > 0 ? ((retailProfit / purchasePrice) * 100) : 0;
// }
