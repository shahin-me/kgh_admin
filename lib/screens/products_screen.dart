import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/controller/product_controller.dart';
import 'package:kgh_admin/models/product_model.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Products Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => productController.refreshProducts(),
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                onPressed: () {
                  _showAddProductDialog(productController, isMobile);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () {
                _showAddProductDialog(productController, isMobile);
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats
            _buildHeader(productController, isMobile),
            SizedBox(height: isMobile ? 12 : 16),

            // Search Bar
            _buildSearchBar(productController, isMobile),
            SizedBox(height: isMobile ? 12 : 16),

            // Category Filter Chips
            _buildCategoryFilter(productController, isMobile),
            SizedBox(height: isMobile ? 12 : 16),

            // Products List
            Expanded(
              child: _buildProductsList(productController, isMobile, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProductController controller, bool isMobile) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Products (${controller.totalProducts})',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Showing ${controller.filteredProducts.length} products',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductController controller, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products...',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
        ),
        onChanged: (value) {
          controller.filterProducts(query: value);
        },
      ),
    );
  }

  Widget _buildCategoryFilter(ProductController controller, bool isMobile) {
    return Obx(
      () => SizedBox(
        height: isMobile ? 40 : 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = controller.selectedCategory.value == category;

            return Container(
              margin: EdgeInsets.only(right: isMobile ? 6 : 8),
              child: FilterChip(
                label: Text(
                  category,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                selected: isSelected,
                backgroundColor: Colors.grey[300],
                selectedColor: Colors.blue,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  controller.filterProducts(category: category);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductsList(
    ProductController controller,
    bool isMobile,
    bool isTablet,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700], fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.filteredProducts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  controller.searchQuery.isEmpty
                      ? 'No products found in ${controller.selectedCategory}'
                      : 'No products found for "${controller.searchQuery}"',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // Responsive grid for desktop/tablet
      if (!isMobile) {
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 2 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.1 : 1.0,
          ),
          itemCount: controller.filteredProducts.length,
          itemBuilder: (context, index) {
            final product = controller.filteredProducts[index];
            return _buildProductCard(product, controller, isMobile);
          },
        );
      }

      // List view for mobile
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = controller.filteredProducts[index];
          return _buildProductItem(product, controller, isMobile);
        },
      );
    });
  }

  Widget _buildProductItem(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
        leading: Container(
          width: isMobile ? 50 : 60,
          height: isMobile ? 50 : 60,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            image: product.images.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.images.first),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: product.images.isEmpty
              ? Icon(
                  Icons.shopping_bag,
                  color: Colors.blue,
                  size: isMobile ? 20 : 24,
                )
              : null,
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              product.productCategory,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 11 : 12,
              ),
            ),
            SizedBox(height: isMobile ? 4 : 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildInfoChip(
                  'Stock: ${product.stock}',
                  Colors.blue,
                  isMobile,
                ),
                _buildInfoChip(
                  product.isAvailable ? 'Available' : 'Out of Stock',
                  product.isAvailable ? Colors.green : Colors.red,
                  isMobile,
                ),
                if (product.replaceCount > 0)
                  _buildInfoChip(
                    'Replace: ${product.replaceCount}',
                    Colors.orange,
                    isMobile,
                  ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: isMobile ? 70 : 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Wholesale Price - Highlighted
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '৳${product.wholesalePrice.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.green[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                'Retail: ৳${product.retailPrice.toInt()}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          _showProductActions(product, controller, isMobile);
        },
      ),
    );
  }

  Widget _buildProductCard(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showProductActions(product, controller, isMobile);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    image: product.images.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.images.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.images.isEmpty
                      ? const Icon(
                          Icons.shopping_bag,
                          color: Colors.blue,
                          size: 32,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),

              // Product Name
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Category
              Text(
                product.productCategory,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 8),

              // Status Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _buildInfoChip('Stock: ${product.stock}', Colors.blue, false),
                  _buildInfoChip(
                    product.isAvailable ? 'Available' : 'Out of Stock',
                    product.isAvailable ? Colors.green : Colors.red,
                    false,
                  ),
                  if (product.replaceCount > 0)
                    _buildInfoChip(
                      'Replace: ${product.replaceCount}',
                      Colors.orange,
                      false,
                    ),
                ],
              ),
              const Spacer(),

              // Pricing Information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wholesale Price - Highlighted
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'Wholesale: ৳${product.wholesalePrice.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Retail: ৳${product.retailPrice.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Cost: ৳${product.purchasePrice.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.wholesaleProfitPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 9 : 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showProductActions(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Product'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProductDialog(product, controller, isMobile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Product'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(product, controller);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.green),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showProductDetails(product, isMobile);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showProductDetails(ProductModel product, bool isMobile) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.images.isNotEmpty)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(product.images.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildDetailRow('Category', product.productCategory),
                _buildDetailRow('Brand', product.brandName),
                _buildDetailRow('Model', product.productModel),
                _buildDetailRow('Product Code', product.productCode),
                _buildDetailRow(
                  'Purchase Price',
                  '৳${product.purchasePrice.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Wholesale Price',
                  '৳${product.wholesalePrice.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Retail Price',
                  '৳${product.retailPrice.toStringAsFixed(2)}',
                ),
                _buildDetailRow('Stock', '${product.stock}'),
                _buildDetailRow('Replace Count', '${product.replaceCount}'),
                _buildDetailRow(
                  'Wholesale Profit',
                  '৳${product.wholesaleProfit.toStringAsFixed(2)} (${product.wholesaleProfitPercentage.toStringAsFixed(1)}%)',
                ),
                _buildDetailRow(
                  'Status',
                  product.isAvailable ? 'Available' : 'Out of Stock',
                ),
                _buildDetailRow('Warranty', product.warranty),
                _buildDetailRow('Unit', product.unit),
                if (product.productDetails.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Product Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...product.productDetails.map(
                    (detail) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $detail'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }

  void _showAddProductDialog(ProductController controller, bool isMobile) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final codeController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final wholesalePriceController = TextEditingController();
    final retailPriceController = TextEditingController();
    final stockController = TextEditingController();
    final replaceCountController = TextEditingController(text: '0');
    final warrantyController = TextEditingController();
    final unitController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add New Product',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name*',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter product name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category*',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter category';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: brandController,
                            decoration: const InputDecoration(
                              labelText: 'Brand Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: modelController,
                            decoration: const InputDecoration(
                              labelText: 'Model',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: codeController,
                            decoration: const InputDecoration(
                              labelText: 'Product Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'Paste image link here...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Pricing Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: purchasePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Purchase Price*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter purchase price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: wholesalePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Wholesale Price*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter wholesale price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: retailPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Retail Price*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter retail price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: stockController,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock*',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter stock quantity';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: replaceCountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Replace Count',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: warrantyController,
                            decoration: const InputDecoration(
                              labelText: 'Warranty',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              final newProduct = ProductModel(
                                brandName: brandController.text,
                                createdAt: DateTime.now(),
                                images: imageUrlController.text.isNotEmpty
                                    ? [imageUrlController.text]
                                    : [],
                                isAvailable: true,
                                isHot: false,
                                isNew: true,
                                name: nameController.text,
                                productCategory: categoryController.text,
                                productCode: codeController.text,
                                productDetails: [],
                                productModel: modelController.text,
                                productVideo: '',
                                quantityDiscount: {},
                                retailPrice: double.parse(
                                  retailPriceController.text,
                                ),
                                purchasePrice: double.parse(
                                  purchasePriceController.text,
                                ),
                                stock: int.parse(stockController.text),
                                unit: unitController.text,
                                warranty: warrantyController.text,
                                wholesalePrice: double.parse(
                                  wholesalePriceController.text,
                                ),
                                replaceCount: int.parse(
                                  replaceCountController.text,
                                ),
                              );

                              await controller.addProduct(newProduct);
                            } catch (e) {
                              // Error handled in controller
                            }
                          }
                        },
                        child: const Text('Add Product'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(
    ProductModel product,
    ProductController controller,
    bool isMobile,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.name);
    final categoryController = TextEditingController(
      text: product.productCategory,
    );
    final brandController = TextEditingController(text: product.brandName);
    final modelController = TextEditingController(text: product.productModel);
    final codeController = TextEditingController(text: product.productCode);
    final purchasePriceController = TextEditingController(
      text: product.purchasePrice.toString(),
    );
    final wholesalePriceController = TextEditingController(
      text: product.wholesalePrice.toString(),
    );
    final retailPriceController = TextEditingController(
      text: product.retailPrice.toString(),
    );
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );
    final replaceCountController = TextEditingController(
      text: product.replaceCount.toString(),
    );
    final warrantyController = TextEditingController(text: product.warranty);
    final unitController = TextEditingController(text: product.unit);
    final imageUrlController = TextEditingController(
      text: product.images.isNotEmpty ? product.images.first : '',
    );
    final isAvailable = product.isAvailable.obs;
    final isHot = product.isHot.obs;
    final isNew = product.isNew.obs;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Product',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name*',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter product name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category*',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter category';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: brandController,
                            decoration: const InputDecoration(
                              labelText: 'Brand Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: modelController,
                            decoration: const InputDecoration(
                              labelText: 'Model',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: codeController,
                            decoration: const InputDecoration(
                              labelText: 'Product Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'Paste image link here...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Pricing Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: purchasePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Purchase Price*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter purchase price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: wholesalePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Wholesale Price*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter wholesale price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: retailPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Retail Price*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter retail price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: stockController,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock*',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter stock quantity';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: replaceCountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Replace Count',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: warrantyController,
                            decoration: const InputDecoration(
                              labelText: 'Warranty',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('Available'),
                                    value: isAvailable.value,
                                    onChanged: (value) =>
                                        isAvailable.value = value!,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('Hot Product'),
                                    value: isHot.value,
                                    onChanged: (value) => isHot.value = value!,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(
                            () => CheckboxListTile(
                              title: const Text('New Product'),
                              value: isNew.value,
                              onChanged: (value) => isNew.value = value!,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              final updatedProduct = ProductModel(
                                id: product.id,
                                brandName: brandController.text,
                                createdAt: product.createdAt,
                                images: imageUrlController.text.isNotEmpty
                                    ? [imageUrlController.text]
                                    : [],
                                isAvailable: isAvailable.value,
                                isHot: isHot.value,
                                isNew: isNew.value,
                                name: nameController.text,
                                productCategory: categoryController.text,
                                productCode: codeController.text,
                                productDetails: product.productDetails,
                                productModel: modelController.text,
                                productVideo: product.productVideo,
                                quantityDiscount: product.quantityDiscount,
                                retailPrice: double.parse(
                                  retailPriceController.text,
                                ),
                                purchasePrice: double.parse(
                                  purchasePriceController.text,
                                ),
                                stock: int.parse(stockController.text),
                                unit: unitController.text,
                                warranty: warrantyController.text,
                                wholesalePrice: double.parse(
                                  wholesalePriceController.text,
                                ),
                                replaceCount: int.parse(
                                  replaceCountController.text,
                                ),
                              );

                              await controller.updateProduct(
                                product.id!,
                                updatedProduct,
                              );
                            } catch (e) {
                              // Error handled in controller
                            }
                          }
                        },
                        child: const Text('Update Product'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    ProductModel product,
    ProductController controller,
  ) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await controller.deleteProduct(product.id!);
              } catch (e) {
                // Error handled in controller
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kgh_admin/controller/product_controller.dart';
// import 'package:kgh_admin/models/product_model.dart';

// class ProductsScreen extends StatelessWidget {
//   const ProductsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final productController = Get.find<ProductController>();

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Products Management',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => productController.refreshProducts(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // Add new product functionality
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with stats
//             _buildHeader(productController),
//             const SizedBox(height: 16),

//             // Search Bar
//             _buildSearchBar(),
//             const SizedBox(height: 16),

//             // Products List
//             Expanded(child: _buildProductsList(productController)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(ProductController controller) {
//     return Obx(
//       () => Row(
//         children: [
//           Text(
//             'All Products (${controller.totalProducts})',
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(width: 16),
//           if (controller.isLoading.value)
//             const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Search products...',
//           border: InputBorder.none,
//           icon: const Icon(Icons.search, color: Colors.grey),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.clear, color: Colors.grey),
//             onPressed: () {
//               // Clear search functionality
//             },
//           ),
//         ),
//         onChanged: (value) {
//           // Implement search functionality
//         },
//       ),
//     );
//   }

//   Widget _buildProductsList(ProductController controller) {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (controller.errorMessage.isNotEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//               const SizedBox(height: 16),
//               Text(
//                 controller.errorMessage.value,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.red[700]),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => controller.refreshProducts(),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         );
//       }

//       if (controller.products.isEmpty) {
//         return const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'No products found',
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }

//       return ListView.builder(
//         itemCount: controller.products.length,
//         itemBuilder: (context, index) {
//           final product = controller.products[index];
//           return _buildProductItem(product);
//         },
//       );
//     });
//   }

//   Widget _buildProductItem(ProductModel product) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.blue[50],
//             borderRadius: BorderRadius.circular(8),
//             image: product.images.isNotEmpty
//                 ? DecorationImage(
//                     image: NetworkImage(product.images.first),
//                     fit: BoxFit.cover,
//                   )
//                 : null,
//           ),
//           child: product.images.isEmpty
//               ? const Icon(Icons.shopping_bag, color: Colors.blue, size: 24)
//               : null,
//         ),
//         title: Text(
//           product.name,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               product.productCategory,
//               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 _buildInfoChip('Stock: ${product.stock}', Colors.blue),
//                 const SizedBox(width: 8),
//                 _buildInfoChip(
//                   product.isAvailable ? 'Available' : 'Out of Stock',
//                   product.isAvailable ? Colors.green : Colors.red,
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               '৳${product.retailPrice.toInt()}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '৳${product.wholesalePrice.toInt()}',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//                 decoration: TextDecoration.lineThrough,
//               ),
//             ),
//           ],
//         ),
//         onTap: () {
//           // Navigate to product details
//           _showProductDetails(product);
//         },
//       ),
//     );
//   }

//   Widget _buildInfoChip(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           color: color,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   void _showProductDetails(ProductModel product) {
//     Get.dialog(
//       AlertDialog(
//         title: Text(product.name),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (product.images.isNotEmpty)
//                 Container(
//                   height: 200,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     image: DecorationImage(
//                       image: NetworkImage(product.images.first),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               _buildDetailRow('Category', product.productCategory),
//               _buildDetailRow('Brand', product.brandName),
//               _buildDetailRow('Model', product.productModel),
//               _buildDetailRow('Retail Price', '৳${product.retailPrice}'),
//               _buildDetailRow('Wholesale Price', '৳${product.wholesalePrice}'),
//               _buildDetailRow('Stock', '${product.stock}'),
//               _buildDetailRow(
//                 'Status',
//                 product.isAvailable ? 'Available' : 'Out of Stock',
//               ),
//               _buildDetailRow('Warranty', product.warranty),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Close')),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
//           Text(value.isEmpty ? 'N/A' : value),
//         ],
//       ),
//     );
//   }
// }
