import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/models/order_model.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable lists for orders
  var orders = <OrderModel>[].obs;
  var filteredOrders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Filter variables
  var selectedStatus = 'all'.obs;
  var selectedDateRange = <DateTime?>[null, null].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrdersInstantly(); // Instant loading
  }

  // INSTANT LOAD: Show orders immediately, load phone numbers later
  Future<void> loadOrdersInstantly() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Clear previous data but show loading immediately
      orders.clear();
      filteredOrders.value = [];

      print('🎯 INSTANT: Showing orders immediately...');

      // Step 1: First show orders without phone numbers (instant)
      final customersSnapshot = await _firestore.collection('users').get();

      List<Future<QuerySnapshot>> orderFutures = [];
      final customerIds = <String>[];

      for (final doc in customersSnapshot.docs) {
        customerIds.add(doc.id);
        orderFutures.add(
          _firestore
              .collection('users')
              .doc(doc.id)
              .collection('userOrders')
              .orderBy('createdAt', descending: true)
              .limit(20) // Limit to 20 orders per customer for instant load
              .get(),
        );
      }

      final orderResults = await Future.wait(orderFutures);

      List<OrderModel> instantOrders = [];

      for (int i = 0; i < orderResults.length; i++) {
        final customerId = customerIds[i];
        final ordersSnapshot = orderResults[i];

        for (final orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data() as Map<String, dynamic>;

          instantOrders.add(
            OrderModel(
              id: orderDoc.id,
              createdAt: (orderData['createdAt'] as Timestamp).toDate(),
              items: List<OrderItem>.from(
                (orderData['items'] ?? []).map(
                  (item) => OrderItem.fromMap(item),
                ),
              ),
              orderId: orderData['orderId'] ?? 'No Order ID',
              paidAmount: (orderData['paidAmount'] ?? 0).toDouble(),
              previousCustomerPayable:
                  (orderData['previousCustomerPayable'] ?? 0).toDouble(),
              previousDue: (orderData['previousDue'] ?? 0).toDouble(),
              shopAddress: orderData['shopAddress'] ?? '',
              shopName: orderData['shopName'] ?? '',
              status: orderData['status'] ?? 'pending',
              totalAmount: (orderData['totalAmount'] ?? 0).toDouble(),
              totalItems: (orderData['totalItems'] ?? 0).toInt(),
              userId: customerId,
              phoneNumber: 'Loading...', // Temporary placeholder
            ),
          );
        }
      }

      // Show orders immediately
      instantOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      orders.value = instantOrders;
      filteredOrders.value = List.from(orders);

      print('🎯 INSTANT: Showing ${orders.length} orders immediately!');

      // Step 2: Then update phone numbers in background
      _updatePhoneNumbersInBackground(customersSnapshot);
    } catch (e) {
      errorMessage.value = 'Error loading orders: $e';
      print('❌ INSTANT ERROR: $e');
      isLoading.value = false;
    }
  }

  // CORRECTED: Update phone numbers in background
  void _updatePhoneNumbersInBackground(QuerySnapshot customersSnapshot) {
    try {
      // Create phone number map with null safety
      final phoneMap = <String, String>{};

      for (final doc in customersSnapshot.docs) {
        final data = doc.data();
        if (data != null) {
          final Map<String, dynamic> userData = data as Map<String, dynamic>;
          phoneMap[doc.id] = userData['phone']?.toString() ?? 'No Phone';
        }
      }

      // Update orders with phone numbers
      final updatedOrders = orders.map((order) {
        return OrderModel(
          id: order.id,
          createdAt: order.createdAt,
          items: order.items,
          orderId: order.orderId,
          paidAmount: order.paidAmount,
          previousCustomerPayable: order.previousCustomerPayable,
          previousDue: order.previousDue,
          shopAddress: order.shopAddress,
          shopName: order.shopName,
          status: order.status,
          totalAmount: order.totalAmount,
          totalItems: order.totalItems,
          userId: order.userId,
          phoneNumber: phoneMap[order.userId] ?? 'No Phone',
        );
      }).toList();

      orders.value = updatedOrders;
      filteredOrders.value = List.from(orders);

      print('📞 BACKGROUND: Phone numbers updated for ${orders.length} orders');
    } catch (e) {
      print('❌ BACKGROUND PHONE UPDATE ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // SUPER FAST: Fetch all orders instantly with phone numbers
  Future<void> fetchAllOrdersInstantly() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      orders.clear();

      print('🚀 INSTANT: Fetching all orders quickly...');

      // Step 1: Get all customers with their phone numbers
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

      // Step 2: Fetch all orders from ALL userOrders subcollections in parallel
      List<Future<QuerySnapshot>> orderFutures = [];

      for (final customerId in customerMap.keys) {
        orderFutures.add(
          _firestore
              .collection('users')
              .doc(customerId)
              .collection('userOrders')
              .orderBy('createdAt', descending: true)
              .get(),
        );
      }

      print(
        '🔄 Fetching orders from ${orderFutures.length} customers in parallel...',
      );
      final orderResults = await Future.wait(orderFutures);

      // Step 3: Process all orders quickly
      List<OrderModel> allOrders = [];

      for (int i = 0; i < orderResults.length; i++) {
        final customerId = customerMap.keys.elementAt(i);
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

      // Step 4: Sort and update
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      orders.value = allOrders;
      filteredOrders.value = List.from(orders);

      print('✅ INSTANT SUCCESS: Loaded ${orders.length} orders immediately!');
    } catch (e) {
      errorMessage.value = 'Error fetching orders: $e';
      print('❌ INSTANT ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ULTRA FAST: Fetch only recent orders (last 7 days)
  Future<void> fetchRecentOrdersFast() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      orders.clear();

      print('⚡ ULTRA FAST: Fetching recent orders only...');

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      // Get all customers quickly
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

      // Fetch recent orders in parallel
      List<Future<QuerySnapshot>> orderFutures = [];

      for (final customerId in customerMap.keys) {
        orderFutures.add(
          _firestore
              .collection('users')
              .doc(customerId)
              .collection('userOrders')
              .where(
                'createdAt',
                isGreaterThan: Timestamp.fromDate(sevenDaysAgo),
              )
              .orderBy('createdAt', descending: true)
              .get(),
        );
      }

      final orderResults = await Future.wait(orderFutures);

      List<OrderModel> allOrders = [];

      for (int i = 0; i < orderResults.length; i++) {
        final customerId = customerMap.keys.elementAt(i);
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

      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      orders.value = allOrders;
      filteredOrders.value = List.from(orders);

      print('✅ ULTRA FAST: Loaded ${orders.length} recent orders instantly!');
    } catch (e) {
      errorMessage.value = 'Error fetching recent orders: $e';
      print('❌ ULTRA FAST ERROR: $e');
    } finally {
      isLoading.value = false;
    }
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
    int completed = orders.where((order) => order.isCompleted).length;
    int pending = orders.where((order) => order.isPending).length;
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
      'completed': completed,
      'pending': pending,
      'cancelled': cancelled,
      'totalRevenue': totalRevenue,
      'collectedRevenue': collectedRevenue,
      'dueRevenue': totalRevenue - collectedRevenue,
    };
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Find the order to get its path
      final order = orders.firstWhere((o) => o.id == orderId);

      // Update in userOrders subcollection
      await _firestore
          .collection('users')
          .doc(order.userId)
          .collection('userOrders')
          .doc(orderId)
          .update({'status': newStatus});

      // Update local data
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = OrderModel(
          id: orders[index].id,
          createdAt: orders[index].createdAt,
          items: orders[index].items,
          orderId: orders[index].orderId,
          paidAmount: orders[index].paidAmount,
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
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Refresh orders - Use instant loading
  Future<void> refreshOrders() async {
    await loadOrdersInstantly(); // Use instant loading
  }

  // Clear all data
  void clearData() {
    orders.clear();
    filteredOrders.clear();
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
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

//   // Filter variables
//   var selectedStatus = 'all'.obs;
//   var selectedDateRange = <DateTime?>[null, null].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchOrders();
//   }

//   // Fetch all orders from Firestore
//   Future<void> fetchOrders() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';

//       final QuerySnapshot snapshot = await _firestore
//           .collection('orders')
//           .get();

//       orders.value = snapshot.docs.map((doc) {
//         return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//       }).toList();

//       // Sort by date (newest first)
//       orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//       filteredOrders.value = List.from(orders);

//       print('Fetched ${orders.length} orders from Firestore');
//     } catch (e) {
//       errorMessage.value = 'Error fetching orders: $e';
//       print('Error fetching orders: $e');
//     } finally {
//       isLoading.value = false;
//     }
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
//     int completed = orders.where((order) => order.isCompleted).length;
//     int pending = orders.where((order) => order.isPending).length;
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
//       'completed': completed,
//       'pending': pending,
//       'cancelled': cancelled,
//       'totalRevenue': totalRevenue,
//       'collectedRevenue': collectedRevenue,
//       'dueRevenue': totalRevenue - collectedRevenue,
//     };
//   }

//   // Update order status
//   Future<void> updateOrderStatus(String orderId, String newStatus) async {
//     try {
//       await _firestore.collection('orders').doc(orderId).update({
//         'status': newStatus,
//       });

//       // Update local data
//       final index = orders.indexWhere((order) => order.id == orderId);
//       if (index != -1) {
//         orders[index] = OrderModel(
//           id: orders[index].id,
//           createdAt: orders[index].createdAt,
//           items: orders[index].items,
//           orderId: orders[index].orderId,
//           paidAmount: orders[index].paidAmount,
//           previousCustomerPayable: orders[index].previousCustomerPayable,
//           previousDue: orders[index].previousDue,
//           shopAddress: orders[index].shopAddress,
//           shopName: orders[index].shopName,
//           status: newStatus,
//           totalAmount: orders[index].totalAmount,
//           totalItems: orders[index].totalItems,
//           userId: orders[index].userId,
//         );
//         filterOrders(); // Reapply filters
//       }
//     } catch (e) {
//       throw Exception('Failed to update order status: $e');
//     }
//   }

//   // Refresh orders
//   Future<void> refreshOrders() async {
//     await fetchOrders();
//   }
// }
