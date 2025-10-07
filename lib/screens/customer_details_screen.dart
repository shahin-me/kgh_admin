import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kgh_admin/controller/customer_controller.dart';
import 'package:kgh_admin/models/customer_model.dart';
import 'package:kgh_admin/models/order_model.dart';
import 'package:kgh_admin/screens/order_details_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CustomerController _customerController = Get.find<CustomerController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch customer orders when screen loads
    _loadCustomerOrders();
  }

  Future<void> _loadCustomerOrders() async {
    print('Loading orders for customer: ${widget.customer.id}');
    await _customerController.fetchCustomerOrders(widget.customer.id!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.shopName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details', icon: Icon(Icons.info_outline)),
            Tab(text: 'Orders', icon: Icon(Icons.receipt_long)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Customer Details Tab
          _buildCustomerDetailsTab(),
          // Customer Orders Tab
          _buildCustomerOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Information Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shop Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Shop Name', widget.customer.shopName),
                  _buildDetailRow('Proprietor', widget.customer.proprietorName),
                  _buildDetailRow('Phone', widget.customer.phone),
                  _buildDetailRow('Email', widget.customer.email),
                  _buildDetailRow('Address', widget.customer.address),
                  _buildDetailRow(
                    'Delivery Day',
                    widget.customer.deliveryDay.isNotEmpty
                        ? widget.customer.deliveryDay
                        : 'Not Set',
                  ),
                  _buildDetailRow(
                    'Member Since',
                    DateFormat(
                      'MMMM dd, yyyy',
                    ).format(widget.customer.createdAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Financial Summary Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFinancialRow(
                    'Total Due',
                    '৳${widget.customer.totalDue.toStringAsFixed(2)}',
                    isNegative: widget.customer.totalDue > 0,
                  ),
                  _buildFinancialRow(
                    'Total Payable',
                    '৳${widget.customer.totalPayableToCustomer.toStringAsFixed(2)}',
                    isPositive: widget.customer.totalPayableToCustomer > 0,
                  ),
                  const Divider(),
                  _buildFinancialRow(
                    'Net Balance',
                    '৳${widget.customer.netBalance.toStringAsFixed(2)}',
                    isBold: true,
                    isPositive: widget.customer.netBalance >= 0,
                    isNegative: widget.customer.netBalance < 0,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.customer.netBalance >= 0
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.customer.netBalance >= 0
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.customer.netBalance >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: widget.customer.netBalance >= 0
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.customer.netBalance >= 0
                                ? 'You owe ৳${widget.customer.netBalance.toStringAsFixed(2)} to customer'
                                : 'Customer owes ৳${(-widget.customer.netBalance).toStringAsFixed(2)} to you',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: widget.customer.netBalance >= 0
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Orders Summary Card
          const SizedBox(height: 16),
          _buildOrdersSummaryCard(),

          // Debug Information Card (Temporary)
          const SizedBox(height: 16),
          _buildDebugInfoCard(),
        ],
      ),
    );
  }

  Widget _buildOrdersSummaryCard() {
    return Obx(() {
      final totalOrders = _customerController.getCustomerTotalOrdersCount();
      final completedOrders = _customerController
          .getCustomerCompletedOrdersCount();
      final pendingOrders = _customerController.getCustomerPendingOrdersCount();
      final totalAmount = _customerController.getCustomerTotalOrdersAmount();

      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orders Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 16),
              _buildOrderStatRow('Total Orders', totalOrders.toString()),
              _buildOrderStatRow(
                'Completed Orders',
                completedOrders.toString(),
              ),
              _buildOrderStatRow('Pending Orders', pendingOrders.toString()),
              _buildOrderStatRow(
                'Total Amount',
                '৳${totalAmount.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDebugInfoCard() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            _buildDebugRow('Customer ID', widget.customer.id ?? 'N/A'),
            _buildDebugRow('Customer Phone', widget.customer.phone),
            _buildDebugRow(
              'Orders Found',
              '${_customerController.customerOrders.length}',
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _debugCustomerOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Debug Orders Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCustomerOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh Orders'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerOrdersTab() {
    return Obx(() {
      if (_customerController.isLoadingOrders.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading customer orders...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      if (_customerController.customerOrders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No orders found for this customer',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Customer ID: ${widget.customer.id}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCustomerOrders,
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Orders Count Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_customerController.customerOrders.length} Orders Found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loadCustomerOrders,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _customerController.customerOrders.length,
              itemBuilder: (context, index) {
                final order = _customerController.customerOrders[index];
                return _buildOrderItem(order);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOrderItem(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getStatusIcon(order.status),
            color: _getStatusColor(order.status),
            size: 24,
          ),
        ),
        title: Text(
          'Order #${order.orderId}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${order.totalItems} items • ৳${order.totalAmount.toInt()}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(order.status)),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.dueAmount > 0 ? 'Due: ৳${order.dueAmount.toInt()}' : 'Paid',
              style: TextStyle(
                fontSize: 11,
                color: order.dueAmount > 0 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () {
          Get.to(() => OrderDetailsScreen(order: order));
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    String label,
    String value, {
    bool isPositive = false,
    bool isNegative = false,
    bool isBold = false,
  }) {
    Color color = Colors.black;
    if (isPositive) color = Colors.green;
    if (isNegative) color = Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
  }

  void _debugCustomerOrders() {
    print('=== DEBUG CUSTOMER ORDERS ===');
    print('Customer ID: ${widget.customer.id}');
    print('Customer Phone: ${widget.customer.phone}');
    print('Customer Document ID: ${widget.customer.id}');
    print(
      'Total Orders in Controller: ${_customerController.customerOrders.length}',
    );

    if (_customerController.customerOrders.isEmpty) {
      print('No orders found in controller');
      print('Loading state: ${_customerController.isLoadingOrders.value}');
      print('Error message: ${_customerController.errorMessage.value}');
    } else {
      _customerController.customerOrders.forEach((order) {
        print('--- Order Details ---');
        print('Order ID: ${order.orderId}');
        print('Order Document ID: ${order.id}');
        print('Total Amount: ${order.totalAmount}');
        print('Status: ${order.status}');
        print('Items Count: ${order.items.length}');
        print('Created At: ${order.createdAt}');
        print('User ID: ${order.userId}');
      });
    }

    // Show snackbar with debug info
    Get.snackbar(
      'Debug Info',
      'Orders found: ${_customerController.customerOrders.length}',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }
}
