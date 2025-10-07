import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/models/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable list for products
  var products = <ProductModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // Fetch all products from Firestore
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

      print('Fetched ${products.length} products from Firestore');
    } catch (e) {
      errorMessage.value = 'Error fetching products: $e';
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get total number of products
  int get totalProducts => products.length;

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    return products
        .where((product) => product.productCategory == category)
        .toList();
  }

  // Search products by name
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

  // Refresh products
  Future<void> refreshProducts() async {
    await fetchProducts();
  }
}
