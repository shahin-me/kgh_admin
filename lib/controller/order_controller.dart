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
    fetchOrders();
  }

  // Fetch all orders from Firestore
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .get();

      orders.value = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Sort by date (newest first)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      filteredOrders.value = List.from(orders);

      print('Fetched ${orders.length} orders from Firestore');
    } catch (e) {
      errorMessage.value = 'Error fetching orders: $e';
      print('Error fetching orders: $e');
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
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });

      // Update local data
      final index = orders.indexWhere((order) => order.id == orderId);
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
        );
        filterOrders(); // Reapply filters
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
