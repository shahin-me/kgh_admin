import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/models/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var products = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;
  var categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .get();

      products.value = snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      _extractCategories();
      filterProducts();

      print('Fetched ${products.length} products from Firestore');
    } catch (e) {
      errorMessage.value = 'Error fetching products: $e';
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _extractCategories() {
    final allCategories = products
        .map((product) => product.productCategory)
        .toList();
    final uniqueCategories = allCategories.toSet().toList();
    uniqueCategories.sort();
    categories.value = ['All'] + uniqueCategories;
  }

  void filterProducts({String? category, String? query}) {
    if (category != null) selectedCategory.value = category;
    if (query != null) searchQuery.value = query;

    filteredProducts.value = products.where((product) {
      bool categoryMatch =
          selectedCategory.value == 'All' ||
          product.productCategory == selectedCategory.value;

      bool searchMatch =
          searchQuery.value.isEmpty ||
          product.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          product.productCategory.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          product.brandName.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          product.productCode.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );

      return categoryMatch && searchMatch;
    }).toList();
  }

  int get totalProducts => products.length;

  List<ProductModel> getProductsByCategory(String category) {
    return products
        .where((product) => product.productCategory == category)
        .toList();
  }

  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return products;
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.productCategory.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              product.brandName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
      await fetchProducts();
      Get.back();
      Get.snackbar(
        'Success',
        'Product added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      throw e;
    }
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update(product.toMap());
      await fetchProducts();
      Get.back();
      Get.snackbar(
        'Success',
        'Product updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      throw e;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      await fetchProducts();
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      throw e;
    }
  }

  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  Map<String, dynamic> getProductStatistics() {
    double totalInvestment = products.fold(
      0.0,
      (sum, product) => sum + (product.purchasePrice * product.stock),
    );
    double totalWholesaleValue = products.fold(
      0.0,
      (sum, product) => sum + (product.wholesalePrice * product.stock),
    );
    double totalRetailValue = products.fold(
      0.0,
      (sum, product) => sum + (product.retailPrice * product.stock),
    );
    int totalPendingStock = products.fold(
      0,
      (sum, product) => sum + product.pendingStock,
    );

    return {
      'totalProducts': products.length,
      'totalInvestment': totalInvestment,
      'totalWholesaleValue': totalWholesaleValue,
      'totalRetailValue': totalRetailValue,
      'totalPendingStock': totalPendingStock,
      'potentialProfit': totalWholesaleValue - totalInvestment,
    };
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kgh_admin/models/product_model.dart';

// class ProductController extends GetxController {
//   static ProductController get instance => Get.find();

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   var products = <ProductModel>[].obs;
//   var filteredProducts = <ProductModel>[].obs;
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   var selectedCategory = 'All'.obs;
//   var searchQuery = ''.obs;
//   var categories = <String>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchProducts();
//   }

//   Future<void> fetchProducts() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';

//       final QuerySnapshot snapshot = await _firestore
//           .collection('products')
//           .get();

//       products.value = snapshot.docs.map((doc) {
//         return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//       }).toList();

//       _extractCategories();
//       filterProducts();

//       print('Fetched ${products.length} products from Firestore');
//     } catch (e) {
//       errorMessage.value = 'Error fetching products: $e';
//       print('Error fetching products: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _extractCategories() {
//     final allCategories = products
//         .map((product) => product.productCategory)
//         .toList();
//     final uniqueCategories = allCategories.toSet().toList();
//     uniqueCategories.sort();
//     categories.value = ['All'] + uniqueCategories;
//   }

//   void filterProducts({String? category, String? query}) {
//     if (category != null) selectedCategory.value = category;
//     if (query != null) searchQuery.value = query;

//     filteredProducts.value = products.where((product) {
//       bool categoryMatch =
//           selectedCategory.value == 'All' ||
//           product.productCategory == selectedCategory.value;

//       bool searchMatch =
//           searchQuery.value.isEmpty ||
//           product.name.toLowerCase().contains(
//             searchQuery.value.toLowerCase(),
//           ) ||
//           product.productCategory.toLowerCase().contains(
//             searchQuery.value.toLowerCase(),
//           ) ||
//           product.brandName.toLowerCase().contains(
//             searchQuery.value.toLowerCase(),
//           ) ||
//           product.productCode.toLowerCase().contains(
//             searchQuery.value.toLowerCase(),
//           );

//       return categoryMatch && searchMatch;
//     }).toList();

//     print(
//       'Filtered to ${filteredProducts.length} products in category: ${selectedCategory.value}',
//     );
//   }

//   int get totalProducts => products.length;

//   List<ProductModel> getProductsByCategory(String category) {
//     return products
//         .where((product) => product.productCategory == category)
//         .toList();
//   }

//   List<ProductModel> searchProducts(String query) {
//     if (query.isEmpty) return products;
//     return products
//         .where(
//           (product) =>
//               product.name.toLowerCase().contains(query.toLowerCase()) ||
//               product.productCategory.toLowerCase().contains(
//                 query.toLowerCase(),
//               ) ||
//               product.brandName.toLowerCase().contains(query.toLowerCase()),
//         )
//         .toList();
//   }

//   Future<void> addProduct(ProductModel product) async {
//     try {
//       await _firestore.collection('products').add(product.toMap());
//       await fetchProducts();
//       Get.back(); // Close dialog first
//       Get.snackbar(
//         'Success',
//         'Product added successfully',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to add product: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       throw e;
//     }
//   }

//   Future<void> updateProduct(String productId, ProductModel product) async {
//     try {
//       await _firestore
//           .collection('products')
//           .doc(productId)
//           .update(product.toMap());
//       await fetchProducts();
//       Get.back(); // Close dialog first
//       Get.snackbar(
//         'Success',
//         'Product updated successfully',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to update product: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       throw e;
//     }
//   }

//   Future<void> deleteProduct(String productId) async {
//     try {
//       await _firestore.collection('products').doc(productId).delete();
//       await fetchProducts();
//       Get.snackbar(
//         'Success',
//         'Product deleted successfully',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to delete product: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       throw e;
//     }
//   }

//   Future<void> refreshProducts() async {
//     await fetchProducts();
//   }

//   Map<String, dynamic> getProductStatistics() {
//     double totalInvestment = products.fold(
//       0.0,
//       (sum, product) => sum + (product.purchasePrice * product.stock),
//     );
//     double totalWholesaleValue = products.fold(
//       0.0,
//       (sum, product) => sum + (product.wholesalePrice * product.stock),
//     );
//     double totalRetailValue = products.fold(
//       0.0,
//       (sum, product) => sum + (product.retailPrice * product.stock),
//     );

//     return {
//       'totalProducts': products.length,
//       'totalInvestment': totalInvestment,
//       'totalWholesaleValue': totalWholesaleValue,
//       'totalRetailValue': totalRetailValue,
//       'potentialProfit': totalWholesaleValue - totalInvestment,
//     };
//   }
// }
