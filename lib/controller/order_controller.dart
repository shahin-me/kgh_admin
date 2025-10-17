import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/models/order_model.dart';
import 'package:kgh_admin/models/product_model.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable lists for orders
  var orders = <OrderModel>[].obs;
  var filteredOrders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Pagination variables
  var currentPage = 0.obs;
  var ordersPerPage = 20.obs;
  var hasMoreOrders = true.obs;
  var isFetchingMore = false.obs;

  // Filter variables
  var selectedStatus = 'all'.obs;
  var selectedDateRange = <DateTime?>[null, null].obs;

  // Available status options
  final List<String> statusOptions = [
    'pending',
    'approved',
    'processing',
    'shipped',
    'completed',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrdersWithPagination(refresh: true);
  }

  // PAGINATION: Load orders with pagination
  Future<void> loadOrdersWithPagination({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        orders.clear();
        filteredOrders.clear();
        hasMoreOrders.value = true;
        isLoading.value = true;
      } else if (isFetchingMore.value) {
        return;
      }

      isFetchingMore.value = true;
      errorMessage.value = '';

      print('📄 Loading page ${currentPage.value + 1}...');

      // Get all customers with their data
      final customersSnapshot = await _firestore.collection('users').get();
      final customerMap = <String, Map<String, dynamic>>{};

      for (final doc in customersSnapshot.docs) {
        final data = doc.data();
        if (data != null) {
          final Map<String, dynamic> userData = data as Map<String, dynamic>;
          customerMap[doc.id] = {
            'phone': userData['phone']?.toString() ?? 'No Phone',
            'shopName': userData['shopName']?.toString() ?? 'No Shop',
            'address': userData['address']?.toString() ?? 'No Address',
          };
        }
      }

      print('📞 Found ${customerMap.length} customers');

      // Fetch all orders from all customers in parallel
      List<Future<QuerySnapshot>> orderFutures = [];
      final customerIds = customerMap.keys.toList();

      for (final customerId in customerIds) {
        orderFutures.add(
          _firestore
              .collection('users')
              .doc(customerId)
              .collection('userOrders')
              .orderBy('createdAt', descending: true)
              .get(),
        );
      }

      print('🔄 Fetching orders from ${orderFutures.length} customers...');
      final orderResults = await Future.wait(orderFutures);

      // Process all orders
      List<OrderModel> allOrders = [];

      for (int i = 0; i < orderResults.length; i++) {
        final customerId = customerIds[i];
        final customerData = customerMap[customerId]!;
        final ordersSnapshot = orderResults[i];

        for (final orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data() as Map<String, dynamic>;

          allOrders.add(
            OrderModel(
              id: orderDoc.id,
              createdAt: (orderData['createdAt'] as Timestamp).toDate(),
              items: List<OrderItem>.from(
                (orderData['items'] ?? []).map(
                  (item) => OrderItem.fromMap(item),
                ),
              ),
              orderId: orderData['orderId']?.toString() ?? 'No Order ID',
              paidAmount: (orderData['paidAmount'] ?? 0).toDouble(),
              previousCustomerPayable:
                  (orderData['previousCustomerPayable'] ?? 0).toDouble(),
              previousDue: (orderData['previousDue'] ?? 0).toDouble(),
              shopAddress:
                  orderData['shopAddress']?.toString() ??
                  customerData['address'],
              shopName:
                  orderData['shopName']?.toString() ?? customerData['shopName'],
              status: orderData['status']?.toString() ?? 'pending',
              totalAmount: (orderData['totalAmount'] ?? 0).toDouble(),
              totalItems: (orderData['totalItems'] ?? 0).toInt(),
              userId: customerId,
              phoneNumber: customerData['phone'],
            ),
          );
        }
      }

      // Sort all orders by date (newest first)
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply pagination
      final totalOrdersCount = allOrders.length;
      final startIndex = currentPage.value * ordersPerPage.value;
      final endIndex = startIndex + ordersPerPage.value;

      List<OrderModel> paginatedOrders = [];

      if (startIndex < totalOrdersCount) {
        paginatedOrders = allOrders.sublist(
          startIndex,
          endIndex < totalOrdersCount ? endIndex : totalOrdersCount,
        );
      }

      // Add to existing orders
      if (refresh) {
        orders.value = paginatedOrders;
      } else {
        orders.addAll(paginatedOrders);
      }

      filteredOrders.value = List.from(orders);

      // Update pagination state
      hasMoreOrders.value = endIndex < totalOrdersCount;
      currentPage.value++;

      print(
        '✅ Page ${currentPage.value} loaded: ${paginatedOrders.length} orders',
      );
      print(
        '📊 Total loaded: ${orders.length}, Has more: ${hasMoreOrders.value}',
      );
    } catch (e) {
      errorMessage.value = 'Error loading orders: $e';
      print('❌ PAGINATION ERROR: $e');
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  // Load next page for infinite scroll
  Future<void> loadNextPage() async {
    if (hasMoreOrders.value && !isFetchingMore.value && !isLoading.value) {
      print('⬇️ Loading next page...');
      await loadOrdersWithPagination();
    }
  }

  // Refresh orders (reset pagination)
  Future<void> refreshOrders() async {
    await loadOrdersWithPagination(refresh: true);
  }

  // Legacy method for compatibility
  Future<void> loadOrdersInstantly() async {
    await loadOrdersWithPagination(refresh: true);
  }

  // Filter orders by status and date range
  void filterOrders({String? status, List<DateTime?>? dateRange}) {
    if (status != null) selectedStatus.value = status;
    if (dateRange != null) selectedDateRange.value = dateRange;

    filteredOrders.value = orders.where((order) {
      bool statusMatch =
          selectedStatus.value == 'all' || order.status == selectedStatus.value;

      bool dateMatch = true;
      if (selectedDateRange[0] != null) {
        dateMatch = dateMatch && order.createdAt.isAfter(selectedDateRange[0]!);
      }
      if (selectedDateRange[1] != null) {
        dateMatch =
            dateMatch &&
            order.createdAt.isBefore(
              selectedDateRange[1]!.add(const Duration(days: 1)),
            );
      }

      return statusMatch && dateMatch;
    }).toList();
  }

  // Get orders by date (group by date)
  Map<DateTime, List<OrderModel>> getOrdersGroupedByDate() {
    Map<DateTime, List<OrderModel>> groupedOrders = {};

    for (var order in filteredOrders) {
      DateTime date = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );

      if (!groupedOrders.containsKey(date)) {
        groupedOrders[date] = [];
      }
      groupedOrders[date]!.add(order);
    }

    return groupedOrders;
  }

  // Get statistics
  Map<String, dynamic> getOrderStatistics() {
    int total = orders.length;
    int pending = orders.where((order) => order.isPending).length;
    int approved = orders.where((order) => order.isApproved).length;
    int processing = orders.where((order) => order.isProcessing).length;
    int shipped = orders.where((order) => order.isShipped).length;
    int completed = orders.where((order) => order.isCompleted).length;
    int cancelled = orders.where((order) => order.isCancelled).length;

    double totalRevenue = orders.fold(
      0,
      (sum, order) => sum + order.totalAmount,
    );
    double collectedRevenue = orders.fold(
      0,
      (sum, order) => sum + order.paidAmount,
    );

    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'processing': processing,
      'shipped': shipped,
      'completed': completed,
      'cancelled': cancelled,
      'totalRevenue': totalRevenue,
      'collectedRevenue': collectedRevenue,
      'dueRevenue': totalRevenue - collectedRevenue,
    };
  }

  // Update product stock based on order status changes
  Future<void> _updateProductStock(
    OrderModel order,
    String oldStatus,
    String newStatus,
  ) async {
    try {
      for (final item in order.items) {
        // Find the product by productId
        final productQuery = await _firestore
            .collection('products')
            .where('name', isEqualTo: item.productId)
            .get();

        if (productQuery.docs.isNotEmpty) {
          final productDoc = productQuery.docs.first;
          final productData = productDoc.data();
          final currentStock = (productData['stock'] ?? 0).toInt();
          final currentPendingStock = (productData['pendingStock'] ?? 0)
              .toInt();
          final quantity = item.quantity;

          int newStock = currentStock;
          int newPendingStock = currentPendingStock;

          // Handle status transitions
          if (oldStatus == 'pending' && newStatus == 'approved') {
            // When approving: move from stock to pending stock
            newStock = currentStock - quantity;
            newPendingStock = currentPendingStock + quantity;
            print('🔄 Approved: Stock -$quantity, Pending Stock +$quantity');
          } else if (oldStatus == 'approved' && newStatus == 'completed') {
            // When completing: remove from pending stock (already deducted from stock)
            newPendingStock = currentPendingStock - quantity;
            print('✅ Completed: Pending Stock -$quantity');
          } else if (oldStatus == 'approved' && newStatus == 'cancelled') {
            // When cancelling approved order: return to stock from pending stock
            newStock = currentStock + quantity;
            newPendingStock = currentPendingStock - quantity;
            print(
              '❌ Cancelled approved: Stock +$quantity, Pending Stock -$quantity',
            );
          } else if (oldStatus == 'pending' && newStatus == 'cancelled') {
            // When cancelling pending order: no change (stock not deducted yet)
            print('ℹ️ Cancelled pending: No stock change');
          } else if (oldStatus == 'completed' && newStatus == 'cancelled') {
            // When cancelling completed order: return to stock
            newStock = currentStock + quantity;
            print('🔄 Cancelled completed: Stock +$quantity');
          }

          // Update the product
          await _firestore.collection('products').doc(productDoc.id).update({
            'stock': newStock,
            'pendingStock': newPendingStock,
          });

          print('📦 Updated product: ${item.productId}');
          print('   Stock: $currentStock → $newStock');
          print('   Pending Stock: $currentPendingStock → $newPendingStock');
        } else {
          print('⚠️ Product not found: ${item.productId}');
        }
      }
    } catch (e) {
      print('❌ Error updating product stock: $e');
      throw Exception('Failed to update product stock: $e');
    }
  }

  // Update order status with payment information and stock management
  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    double? paidAmount,
  }) async {
    try {
      // Find the order to get its path and old status
      final order = orders.firstWhere((o) => o.id == orderId);
      final oldStatus = order.status;

      // Prepare update data
      Map<String, dynamic> updateData = {'status': newStatus};

      // If paid amount is provided, update it
      if (paidAmount != null) {
        updateData['paidAmount'] = paidAmount;
      }

      // Update product stock based on status change
      await _updateProductStock(order, oldStatus, newStatus);

      // Update in userOrders subcollection
      await _firestore
          .collection('users')
          .doc(order.userId)
          .collection('userOrders')
          .doc(orderId)
          .update(updateData);

      // Also update in main orders collection if exists
      try {
        await _firestore.collection('orders').doc(orderId).update(updateData);
        print('✅ Updated in main orders collection');
      } catch (e) {
        print('ℹ️ Order not found in main orders collection, continuing...');
      }

      // Update local data
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = OrderModel(
          id: orders[index].id,
          createdAt: orders[index].createdAt,
          items: orders[index].items,
          orderId: orders[index].orderId,
          paidAmount: paidAmount ?? orders[index].paidAmount,
          previousCustomerPayable: orders[index].previousCustomerPayable,
          previousDue: orders[index].previousDue,
          shopAddress: orders[index].shopAddress,
          shopName: orders[index].shopName,
          status: newStatus,
          totalAmount: orders[index].totalAmount,
          totalItems: orders[index].totalItems,
          userId: orders[index].userId,
          phoneNumber: orders[index].phoneNumber,
        );
        filterOrders();
      }

      Get.snackbar(
        'Success',
        'Order status updated to ${newStatus.toUpperCase()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      throw Exception('Failed to update order status: $e');
    }
  }

  // Complete order with payment details
  Future<void> completeOrderWithPayment(
    String orderId,
    double paidAmount,
  ) async {
    try {
      // Find the order to get its path
      final order = orders.firstWhere((o) => o.id == orderId);
      final oldStatus = order.status;

      // Update product stock
      await _updateProductStock(order, oldStatus, 'completed');

      // Prepare update data for completed status and paid amount
      Map<String, dynamic> updateData = {
        'status': 'completed',
        'paidAmount': paidAmount,
      };

      // Update in userOrders subcollection
      await _firestore
          .collection('users')
          .doc(order.userId)
          .collection('userOrders')
          .doc(orderId)
          .update(updateData);

      // Also update in main orders collection if exists
      try {
        await _firestore.collection('orders').doc(orderId).update(updateData);
        print('✅ Updated in main orders collection');
      } catch (e) {
        print('ℹ️ Order not found in main orders collection, continuing...');
      }

      // Update local data
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = OrderModel(
          id: orders[index].id,
          createdAt: orders[index].createdAt,
          items: orders[index].items,
          orderId: orders[index].orderId,
          paidAmount: paidAmount,
          previousCustomerPayable: orders[index].previousCustomerPayable,
          previousDue: orders[index].previousDue,
          shopAddress: orders[index].shopAddress,
          shopName: orders[index].shopName,
          status: 'completed',
          totalAmount: orders[index].totalAmount,
          totalItems: orders[index].totalItems,
          userId: orders[index].userId,
          phoneNumber: orders[index].phoneNumber,
        );
        filterOrders();
      }

      Get.snackbar(
        'Success',
        'Order completed successfully! Paid: ৳$paidAmount',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      throw Exception('Failed to complete order: $e');
    }
  }

  // Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status icon
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.thumb_up;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  // Get next available statuses based on current status
  List<String> getNextAvailableStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['approved', 'processing', 'cancelled'];
      case 'approved':
        return ['processing', 'shipped', 'completed', 'cancelled'];
      case 'processing':
        return ['shipped', 'completed', 'cancelled'];
      case 'shipped':
        return ['completed', 'cancelled'];
      case 'completed':
        return ['cancelled'];
      case 'cancelled':
        return [];
      default:
        return [
          'pending',
          'approved',
          'processing',
          'shipped',
          'completed',
          'cancelled',
        ];
    }
  }

  // Clear all data
  void clearData() {
    orders.clear();
    filteredOrders.clear();
    currentPage.value = 0;
    hasMoreOrders.value = true;
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kgh_admin/models/order_model.dart';

// class OrderController extends GetxController {
//   static OrderController get instance => Get.find();

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Observable lists for orders
//   var orders = <OrderModel>[].obs;
//   var filteredOrders = <OrderModel>[].obs;
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   // Pagination variables
//   var currentPage = 0.obs;
//   var ordersPerPage = 20.obs;
//   var hasMoreOrders = true.obs;
//   var isFetchingMore = false.obs;

//   // Filter variables
//   var selectedStatus = 'all'.obs;
//   var selectedDateRange = <DateTime?>[null, null].obs;

//   // Available status options
//   final List<String> statusOptions = [
//     'pending',
//     'approved',
//     'processing',
//     'shipped',
//     'completed',
//     'cancelled',
//   ];

//   @override
//   void onInit() {
//     super.onInit();
//     loadOrdersWithPagination(refresh: true);
//   }

//   // PAGINATION: Load orders with pagination
//   Future<void> loadOrdersWithPagination({bool refresh = false}) async {
//     try {
//       if (refresh) {
//         currentPage.value = 0;
//         orders.clear();
//         filteredOrders.clear();
//         hasMoreOrders.value = true;
//         isLoading.value = true;
//       } else if (isFetchingMore.value) {
//         return;
//       }

//       isFetchingMore.value = true;
//       errorMessage.value = '';

//       print('📄 Loading page ${currentPage.value + 1}...');

//       // Get all customers with their data
//       final customersSnapshot = await _firestore.collection('users').get();
//       final customerMap = <String, Map<String, dynamic>>{};

//       for (final doc in customersSnapshot.docs) {
//         final data = doc.data();
//         if (data != null) {
//           final Map<String, dynamic> userData = data as Map<String, dynamic>;
//           customerMap[doc.id] = {
//             'phone': userData['phone']?.toString() ?? 'No Phone',
//             'shopName': userData['shopName']?.toString() ?? 'No Shop',
//             'address': userData['address']?.toString() ?? 'No Address',
//           };
//         }
//       }

//       print('📞 Found ${customerMap.length} customers');

//       // Fetch all orders from all customers in parallel
//       List<Future<QuerySnapshot>> orderFutures = [];
//       final customerIds = customerMap.keys.toList();

//       for (final customerId in customerIds) {
//         orderFutures.add(
//           _firestore
//               .collection('users')
//               .doc(customerId)
//               .collection('userOrders')
//               .orderBy('createdAt', descending: true)
//               .get(),
//         );
//       }

//       print('🔄 Fetching orders from ${orderFutures.length} customers...');
//       final orderResults = await Future.wait(orderFutures);

//       // Process all orders
//       List<OrderModel> allOrders = [];

//       for (int i = 0; i < orderResults.length; i++) {
//         final customerId = customerIds[i];
//         final customerData = customerMap[customerId]!;
//         final ordersSnapshot = orderResults[i];

//         for (final orderDoc in ordersSnapshot.docs) {
//           final orderData = orderDoc.data() as Map<String, dynamic>;

//           allOrders.add(
//             OrderModel(
//               id: orderDoc.id,
//               createdAt: (orderData['createdAt'] as Timestamp).toDate(),
//               items: List<OrderItem>.from(
//                 (orderData['items'] ?? []).map(
//                   (item) => OrderItem.fromMap(item),
//                 ),
//               ),
//               orderId: orderData['orderId']?.toString() ?? 'No Order ID',
//               paidAmount: (orderData['paidAmount'] ?? 0).toDouble(),
//               previousCustomerPayable:
//                   (orderData['previousCustomerPayable'] ?? 0).toDouble(),
//               previousDue: (orderData['previousDue'] ?? 0).toDouble(),
//               shopAddress:
//                   orderData['shopAddress']?.toString() ??
//                   customerData['address'],
//               shopName:
//                   orderData['shopName']?.toString() ?? customerData['shopName'],
//               status: orderData['status']?.toString() ?? 'pending',
//               totalAmount: (orderData['totalAmount'] ?? 0).toDouble(),
//               totalItems: (orderData['totalItems'] ?? 0).toInt(),
//               userId: customerId,
//               phoneNumber: customerData['phone'],
//             ),
//           );
//         }
//       }

//       // Sort all orders by date (newest first)
//       allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//       // Apply pagination
//       final totalOrdersCount = allOrders.length;
//       final startIndex = currentPage.value * ordersPerPage.value;
//       final endIndex = startIndex + ordersPerPage.value;

//       List<OrderModel> paginatedOrders = [];

//       if (startIndex < totalOrdersCount) {
//         paginatedOrders = allOrders.sublist(
//           startIndex,
//           endIndex < totalOrdersCount ? endIndex : totalOrdersCount,
//         );
//       }

//       // Add to existing orders
//       if (refresh) {
//         orders.value = paginatedOrders;
//       } else {
//         orders.addAll(paginatedOrders);
//       }

//       filteredOrders.value = List.from(orders);

//       // Update pagination state
//       hasMoreOrders.value = endIndex < totalOrdersCount;
//       currentPage.value++;

//       print(
//         '✅ Page ${currentPage.value} loaded: ${paginatedOrders.length} orders',
//       );
//       print(
//         '📊 Total loaded: ${orders.length}, Has more: ${hasMoreOrders.value}',
//       );
//     } catch (e) {
//       errorMessage.value = 'Error loading orders: $e';
//       print('❌ PAGINATION ERROR: $e');
//     } finally {
//       isLoading.value = false;
//       isFetchingMore.value = false;
//     }
//   }

//   // Load next page for infinite scroll
//   Future<void> loadNextPage() async {
//     if (hasMoreOrders.value && !isFetchingMore.value && !isLoading.value) {
//       print('⬇️ Loading next page...');
//       await loadOrdersWithPagination();
//     }
//   }

//   // Refresh orders (reset pagination)
//   Future<void> refreshOrders() async {
//     await loadOrdersWithPagination(refresh: true);
//   }

//   // Legacy method for compatibility
//   Future<void> loadOrdersInstantly() async {
//     await loadOrdersWithPagination(refresh: true);
//   }

//   // Filter orders by status and date range
//   void filterOrders({String? status, List<DateTime?>? dateRange}) {
//     if (status != null) selectedStatus.value = status;
//     if (dateRange != null) selectedDateRange.value = dateRange;

//     filteredOrders.value = orders.where((order) {
//       bool statusMatch =
//           selectedStatus.value == 'all' || order.status == selectedStatus.value;

//       bool dateMatch = true;
//       if (selectedDateRange[0] != null) {
//         dateMatch = dateMatch && order.createdAt.isAfter(selectedDateRange[0]!);
//       }
//       if (selectedDateRange[1] != null) {
//         dateMatch =
//             dateMatch &&
//             order.createdAt.isBefore(
//               selectedDateRange[1]!.add(const Duration(days: 1)),
//             );
//       }

//       return statusMatch && dateMatch;
//     }).toList();
//   }

//   // Get orders by date (group by date)
//   Map<DateTime, List<OrderModel>> getOrdersGroupedByDate() {
//     Map<DateTime, List<OrderModel>> groupedOrders = {};

//     for (var order in filteredOrders) {
//       DateTime date = DateTime(
//         order.createdAt.year,
//         order.createdAt.month,
//         order.createdAt.day,
//       );

//       if (!groupedOrders.containsKey(date)) {
//         groupedOrders[date] = [];
//       }
//       groupedOrders[date]!.add(order);
//     }

//     return groupedOrders;
//   }

//   // Get statistics
//   Map<String, dynamic> getOrderStatistics() {
//     int total = orders.length;
//     int pending = orders.where((order) => order.isPending).length;
//     int approved = orders.where((order) => order.isApproved).length;
//     int processing = orders.where((order) => order.isProcessing).length;
//     int shipped = orders.where((order) => order.isShipped).length;
//     int completed = orders.where((order) => order.isCompleted).length;
//     int cancelled = orders.where((order) => order.isCancelled).length;

//     double totalRevenue = orders.fold(
//       0,
//       (sum, order) => sum + order.totalAmount,
//     );
//     double collectedRevenue = orders.fold(
//       0,
//       (sum, order) => sum + order.paidAmount,
//     );

//     return {
//       'total': total,
//       'pending': pending,
//       'approved': approved,
//       'processing': processing,
//       'shipped': shipped,
//       'completed': completed,
//       'cancelled': cancelled,
//       'totalRevenue': totalRevenue,
//       'collectedRevenue': collectedRevenue,
//       'dueRevenue': totalRevenue - collectedRevenue,
//     };
//   }

//   // Update order status with payment information - UPDATED FOR BOTH COLLECTIONS
//   Future<void> updateOrderStatus(
//     String orderId,
//     String newStatus, {
//     double? paidAmount,
//   }) async {
//     try {
//       // Find the order to get its path
//       final order = orders.firstWhere((o) => o.id == orderId);

//       // Prepare update data
//       Map<String, dynamic> updateData = {'status': newStatus};

//       // If paid amount is provided, update it
//       if (paidAmount != null) {
//         updateData['paidAmount'] = paidAmount;
//       }

//       // Update in userOrders subcollection
//       await _firestore
//           .collection('users')
//           .doc(order.userId)
//           .collection('userOrders')
//           .doc(orderId)
//           .update(updateData);

//       // Also update in main orders collection if exists
//       try {
//         await _firestore.collection('orders').doc(orderId).update(updateData);
//         print('✅ Updated in main orders collection');
//       } catch (e) {
//         print('ℹ️ Order not found in main orders collection, continuing...');
//       }

//       // Update local data
//       final index = orders.indexWhere((o) => o.id == orderId);
//       if (index != -1) {
//         orders[index] = OrderModel(
//           id: orders[index].id,
//           createdAt: orders[index].createdAt,
//           items: orders[index].items,
//           orderId: orders[index].orderId,
//           paidAmount: paidAmount ?? orders[index].paidAmount,
//           previousCustomerPayable: orders[index].previousCustomerPayable,
//           previousDue: orders[index].previousDue,
//           shopAddress: orders[index].shopAddress,
//           shopName: orders[index].shopName,
//           status: newStatus,
//           totalAmount: orders[index].totalAmount,
//           totalItems: orders[index].totalItems,
//           userId: orders[index].userId,
//           phoneNumber: orders[index].phoneNumber,
//         );
//         filterOrders();
//       }

//       Get.snackbar(
//         'Success',
//         'Order status updated to ${newStatus.toUpperCase()}',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to update order status: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       throw Exception('Failed to update order status: $e');
//     }
//   }

//   // Complete order with payment details
//   Future<void> completeOrderWithPayment(
//     String orderId,
//     double paidAmount,
//   ) async {
//     try {
//       // Find the order to get its path
//       final order = orders.firstWhere((o) => o.id == orderId);

//       // Prepare update data for completed status and paid amount
//       Map<String, dynamic> updateData = {
//         'status': 'completed',
//         'paidAmount': paidAmount,
//       };

//       // Update in userOrders subcollection
//       await _firestore
//           .collection('users')
//           .doc(order.userId)
//           .collection('userOrders')
//           .doc(orderId)
//           .update(updateData);

//       // Also update in main orders collection if exists
//       try {
//         await _firestore.collection('orders').doc(orderId).update(updateData);
//         print('✅ Updated in main orders collection');
//       } catch (e) {
//         print('ℹ️ Order not found in main orders collection, continuing...');
//       }

//       // Update local data
//       final index = orders.indexWhere((o) => o.id == orderId);
//       if (index != -1) {
//         orders[index] = OrderModel(
//           id: orders[index].id,
//           createdAt: orders[index].createdAt,
//           items: orders[index].items,
//           orderId: orders[index].orderId,
//           paidAmount: paidAmount,
//           previousCustomerPayable: orders[index].previousCustomerPayable,
//           previousDue: orders[index].previousDue,
//           shopAddress: orders[index].shopAddress,
//           shopName: orders[index].shopName,
//           status: 'completed',
//           totalAmount: orders[index].totalAmount,
//           totalItems: orders[index].totalItems,
//           userId: orders[index].userId,
//           phoneNumber: orders[index].phoneNumber,
//         );
//         filterOrders();
//       }

//       Get.snackbar(
//         'Success',
//         'Order completed successfully! Paid: ৳$paidAmount',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to complete order: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//       throw Exception('Failed to complete order: $e');
//     }
//   }

//   // Get status color
//   Color getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'approved':
//         return Colors.blue;
//       case 'processing':
//         return Colors.purple;
//       case 'shipped':
//         return Colors.indigo;
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   // Get status icon
//   IconData getStatusIcon(String status) {
//     switch (status) {
//       case 'pending':
//         return Icons.pending;
//       case 'approved':
//         return Icons.thumb_up;
//       case 'processing':
//         return Icons.autorenew;
//       case 'shipped':
//         return Icons.local_shipping;
//       case 'completed':
//         return Icons.check_circle;
//       case 'cancelled':
//         return Icons.cancel;
//       default:
//         return Icons.receipt;
//     }
//   }

//   // Get next available statuses based on current status
//   List<String> getNextAvailableStatuses(String currentStatus) {
//     switch (currentStatus) {
//       case 'pending':
//         return ['approved', 'processing', 'cancelled'];
//       case 'approved':
//         return ['processing', 'shipped', 'cancelled'];
//       case 'processing':
//         return ['shipped', 'completed', 'cancelled'];
//       case 'shipped':
//         return ['completed'];
//       case 'completed':
//         return [];
//       case 'cancelled':
//         return [];
//       default:
//         return [
//           'pending',
//           'approved',
//           'processing',
//           'shipped',
//           'completed',
//           'cancelled',
//         ];
//     }
//   }

//   // Clear all data
//   void clearData() {
//     orders.clear();
//     filteredOrders.clear();
//     currentPage.value = 0;
//     hasMoreOrders.value = true;
//   }
// }
