import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kgh_admin/models/customer_model.dart';
import 'package:kgh_admin/models/order_model.dart';

class CustomerController extends GetxController {
  static CustomerController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable lists
  var customers = <CustomerModel>[].obs;
  var customerOrders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var isLoadingOrders = false.obs;
  var errorMessage = ''.obs;

  // Current selected customer for orders
  var selectedCustomer = Rx<CustomerModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  // Fetch all customers from Firestore
  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final QuerySnapshot snapshot = await _firestore.collection('users').get();

      customers.value = snapshot.docs.map((doc) {
        return CustomerModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Sort by shop name
      customers.sort((a, b) => a.shopName.compareTo(b.shopName));

      print('Fetched ${customers.length} customers from Firestore');
    } catch (e) {
      errorMessage.value = 'Error fetching customers: $e';
      print('Error fetching customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch orders for a specific customer - CORRECTED FOR SUBCOLLECTION
  Future<void> fetchCustomerOrders(String customerId) async {
    try {
      isLoadingOrders.value = true;
      errorMessage.value = '';
      customerOrders.clear(); // Clear previous orders

      print('Fetching orders for customer ID: $customerId');

      // Subcollection path: users/{customerId}/userOrders
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(customerId)
          .collection('userOrders')
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${snapshot.docs.length} orders in subcollection');

      if (snapshot.docs.isEmpty) {
        print('No orders found in subcollection for customer: $customerId');
        customerOrders.value = [];
        return;
      }

      // Convert documents to OrderModel
      customerOrders.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Processing order: ${data['orderId']}');
        return OrderModel.fromMap(data, doc.id);
      }).toList();

      print(
        'Successfully fetched ${customerOrders.length} orders from subcollection for customer $customerId',
      );
    } catch (e) {
      errorMessage.value =
          'Error fetching customer orders from subcollection: $e';
      print('Error fetching customer orders from subcollection: $e');
      print('Stack trace: ${e.toString()}');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Set selected customer and fetch their orders
  Future<void> setSelectedCustomer(CustomerModel customer) async {
    selectedCustomer.value = customer;
    await fetchCustomerOrders(customer.id!);
  }

  // Get customer by ID
  CustomerModel? getCustomerById(String id) {
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get customer by phone number
  CustomerModel? getCustomerByPhone(String phone) {
    try {
      return customers.firstWhere((customer) => customer.phone == phone);
    } catch (e) {
      return null;
    }
  }

  // Search customers
  List<CustomerModel> searchCustomers(String query) {
    if (query.isEmpty) return customers;
    return customers
        .where(
          (customer) =>
              customer.shopName.toLowerCase().contains(query.toLowerCase()) ||
              customer.proprietorName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              customer.phone.contains(query) ||
              customer.address.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Get customer statistics
  Map<String, dynamic> getCustomerStatistics() {
    int total = customers.length;
    int withDue = customers.where((customer) => customer.hasDue).length;
    int withPayable = customers.where((customer) => customer.hasPayable).length;
    double totalDue = customers.fold(
      0,
      (sum, customer) => sum + customer.totalDue,
    );
    double totalPayable = customers.fold(
      0,
      (sum, customer) => sum + customer.totalPayableToCustomer,
    );

    return {
      'total': total,
      'withDue': withDue,
      'withPayable': withPayable,
      'totalDue': totalDue,
      'totalPayable': totalPayable,
      'netBalance': totalPayable - totalDue,
    };
  }

  // Refresh customers
  Future<void> refreshCustomers() async {
    await fetchCustomers();
  }

  // Get total orders amount for a customer
  double getCustomerTotalOrdersAmount() {
    return customerOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Get completed orders count
  int getCustomerCompletedOrdersCount() {
    return customerOrders.where((order) => order.isCompleted).length;
  }

  // Get pending orders count
  int getCustomerPendingOrdersCount() {
    return customerOrders.where((order) => order.isPending).length;
  }

  // Get total orders count
  int getCustomerTotalOrdersCount() {
    return customerOrders.length;
  }
}
