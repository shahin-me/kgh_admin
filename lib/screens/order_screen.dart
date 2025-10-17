import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kgh_admin/controller/order_controller.dart';
import 'package:kgh_admin/models/order_model.dart';
import 'package:kgh_admin/screens/order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.yellow),
            onPressed: () => orderController.loadOrdersInstantly(),
            tooltip: 'Instant Load',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: () => orderController.refreshOrders(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading Status
            _buildLoadingStatus(orderController, isMobile),
            SizedBox(height: isMobile ? 12 : 16),

            // Statistics Cards
            _buildStatistics(orderController, isMobile),
            SizedBox(height: isMobile ? 12 : 16),

            // Filter Chips
            _buildFilterChips(orderController, isMobile),
            SizedBox(height: isMobile ? 12 : 16),

            // Orders List
            Expanded(
              child: _buildOrdersList(orderController, isMobile, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatus(OrderController controller, bool isMobile) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: controller.isLoading.value
              ? Colors.orange[50]
              : Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.isLoading.value ? Colors.orange : Colors.green,
          ),
        ),
        child: Row(
          children: [
            Icon(
              controller.isLoading.value
                  ? Icons.hourglass_top
                  : Icons.check_circle,
              color: controller.isLoading.value ? Colors.orange : Colors.green,
              size: isMobile ? 18 : 20,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.isLoading.value
                        ? 'Loading orders...'
                        : '${controller.orders.length} orders loaded!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 14 : 16,
                      color: controller.isLoading.value
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  if (controller.hasMoreOrders.value &&
                      !controller.isLoading.value)
                    Text(
                      'Scroll down to load more...',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.blue[600],
                      ),
                    ),
                ],
              ),
            ),
            if (controller.isLoading.value)
              SizedBox(
                width: isMobile ? 16 : 20,
                height: isMobile ? 16 : 20,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            if (controller.isFetchingMore.value)
              SizedBox(
                width: isMobile ? 16 : 20,
                height: isMobile ? 16 : 20,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(OrderController controller, bool isMobile) {
    return Obx(() {
      final stats = controller.getOrderStatistics();
      return AnimatedOpacity(
        opacity: controller.orders.isEmpty ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: SizedBox(
          height: isMobile ? 70 : 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildStatCard(
                'Total',
                stats['total'].toString(),
                Colors.blue,
                isMobile,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _buildStatCard(
                'Pending',
                stats['pending'].toString(),
                Colors.orange,
                isMobile,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _buildStatCard(
                'Approved',
                stats['approved'].toString(),
                Colors.blue,
                isMobile,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _buildStatCard(
                'Processing',
                stats['processing'].toString(),
                Colors.purple,
                isMobile,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _buildStatCard(
                'Shipped',
                stats['shipped'].toString(),
                Colors.indigo,
                isMobile,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _buildStatCard(
                'Completed',
                stats['completed'].toString(),
                Colors.green,
                isMobile,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              _buildStatCard(
                'Cancelled',
                stats['cancelled'].toString(),
                Colors.red,
                isMobile,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(OrderController controller, bool isMobile) {
    return Obx(
      () => AnimatedOpacity(
        opacity: controller.orders.isEmpty ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Wrap(
          spacing: isMobile ? 6 : 8,
          runSpacing: isMobile ? 6 : 8,
          children: [
            _buildFilterChip('All', 'all', controller, isMobile),
            _buildFilterChip('Pending', 'pending', controller, isMobile),
            _buildFilterChip('Approved', 'approved', controller, isMobile),
            _buildFilterChip('Processing', 'processing', controller, isMobile),
            _buildFilterChip('Shipped', 'shipped', controller, isMobile),
            _buildFilterChip('Completed', 'completed', controller, isMobile),
            _buildFilterChip('Cancelled', 'cancelled', controller, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    OrderController controller,
    bool isMobile,
  ) {
    final isSelected = controller.selectedStatus.value == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 12 : 14,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selected: isSelected,
      backgroundColor: Colors.grey[300],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      onSelected: controller.orders.isEmpty
          ? null
          : (selected) {
              controller.filterOrders(status: value);
            },
    );
  }

  Widget _buildOrdersList(
    OrderController controller,
    bool isMobile,
    BuildContext context,
  ) {
    return Obx(() {
      // Show instant empty state
      if (!controller.isLoading.value && controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'No orders found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => controller.loadOrdersInstantly(),
                icon: const Icon(Icons.flash_on),
                label: const Text('Load Orders Instantly'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      // Show loading with instant preview
      if (controller.isLoading.value && controller.orders.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading orders instantly...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      // Show orders with infinite scroll
      final groupedOrders = controller.getOrdersGroupedByDate();
      final sortedDates = groupedOrders.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Load next page when user reaches bottom
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              controller.hasMoreOrders.value &&
              !controller.isFetchingMore.value &&
              !controller.isLoading.value) {
            controller.loadNextPage();
          }
          return false;
        },
        child: Column(
          children: [
            // Orders Count and Status
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.orders.length} Orders Loaded',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.blue,
                        ),
                      ),
                      if (controller.hasMoreOrders.value)
                        Text(
                          'More orders available',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.orange[700],
                          ),
                        ),
                    ],
                  ),
                  if (controller.isFetchingMore.value)
                    Row(
                      children: [
                        SizedBox(
                          width: isMobile ? 14 : 16,
                          height: isMobile ? 14 : 16,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'Loading more...',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Orders List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount:
                    sortedDates.length +
                    (controller.hasMoreOrders.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Load more indicator at the end
                  if (index == sortedDates.length) {
                    return _buildLoadMoreIndicator(controller, isMobile);
                  }

                  final date = sortedDates[index];
                  final ordersForDate = groupedOrders[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: isMobile ? 12 : 16,
                        ),
                        child: Text(
                          DateFormat('MMMM dd, yyyy').format(date),
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),

                      // Orders for this date
                      ...ordersForDate.map(
                        (order) => _buildOrderItem(
                          order,
                          controller,
                          isMobile,
                          context,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator(OrderController controller, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Center(
        child: Column(
          children: [
            if (controller.isFetchingMore.value)
              SizedBox(
                width: isMobile ? 20 : 24,
                height: isMobile ? 20 : 24,
                child: const CircularProgressIndicator(),
              ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              controller.isFetchingMore.value
                  ? 'Loading more orders...'
                  : 'Scroll to load more',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    OrderModel order,
    OrderController controller,
    bool isMobile,
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: isMobile ? 8 : 12),
      elevation: 1,
      child: ListTile(
        contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
        leading: Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: controller.getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
          ),
          child: Icon(
            controller.getStatusIcon(order.status),
            color: controller.getStatusColor(order.status),
            size: isMobile ? 18 : 20,
          ),
        ),
        title: Text(
          'Order #${order.orderId}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              order.shopName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 12 : 14,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              'Phone: ${order.phoneNumber ?? 'Loading...'}',
              style: TextStyle(
                color: order.phoneNumber == 'Loading...'
                    ? Colors.orange
                    : Colors.grey[600],
                fontSize: isMobile ? 11 : 12,
                fontStyle: order.phoneNumber == 'Loading...'
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Row(
              children: [
                _buildInfoChip(
                  '${order.totalItems} items',
                  Colors.blue,
                  isMobile,
                ),
                SizedBox(width: isMobile ? 4 : 6),
                _buildInfoChip(
                  '৳${order.totalAmount.toInt()}',
                  Colors.green,
                  isMobile,
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Status Badge
            GestureDetector(
              onTap: () {
                _showStatusUpdateDialog(order, controller, isMobile, context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: controller
                      .getStatusColor(order.status)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  border: Border.all(
                    color: controller.getStatusColor(order.status),
                  ),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    color: controller.getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              order.dueAmount > 0 ? 'Due: ৳${order.dueAmount.toInt()}' : 'Paid',
              style: TextStyle(
                fontSize: isMobile ? 9 : 11,
                color: order.dueAmount > 0 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isMobile) ...[
              SizedBox(height: 2),
              Text(
                DateFormat('hh:mm a').format(order.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
        onTap: () {
          Get.to(() => OrderDetailsScreen(order: order));
        },
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 6,
        vertical: isMobile ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
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

  void _showStatusUpdateDialog(
    OrderModel order,
    OrderController controller,
    bool isMobile,
    BuildContext context,
  ) {
    final availableStatuses = controller.getNextAvailableStatuses(order.status);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Order Status',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #${order.orderId}',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Current Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.getStatusIcon(order.status),
                        color: controller.getStatusColor(order.status),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Status: ${order.status.toUpperCase()}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: controller.getStatusColor(order.status),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ৳${order.totalAmount.toStringAsFixed(2)} | Paid: ৳${order.paidAmount.toStringAsFixed(2)} | Due: ৳${order.dueAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Available Status Options
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (availableStatuses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No further status updates available',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...availableStatuses.map(
                            (status) => _buildStatusOption(
                              status,
                              order,
                              controller,
                              isMobile,
                              context,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    String status,
    OrderModel order,
    OrderController controller,
    bool isMobile,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          controller.getStatusIcon(status),
          color: controller.getStatusColor(status),
        ),
        title: Text(
          status.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: controller.getStatusColor(status),
          ),
        ),
        subtitle: _getStatusDescription(status),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context); // Close dialog
          if (status == 'completed') {
            _showPaymentDialog(order, controller, isMobile, context);
          } else {
            _confirmStatusUpdate(order, controller, status, isMobile, context);
          }
        },
      ),
    );
  }

  Text _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return const Text('Order received, waiting for approval');
      case 'approved':
        return const Text('Order approved, preparing for processing');
      case 'processing':
        return const Text('Order is being processed');
      case 'shipped':
        return const Text('Order has been shipped');
      case 'completed':
        return const Text('Order delivered successfully');
      case 'cancelled':
        return const Text('Order has been cancelled');
      default:
        return const Text('Update order status');
    }
  }

  void _showPaymentDialog(
    OrderModel order,
    OrderController controller,
    bool isMobile,
    BuildContext context,
  ) {
    final paidAmountController = TextEditingController(
      text: order.paidAmount.toStringAsFixed(2),
    );
    final dueAmount = order.totalAmount - order.paidAmount;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Complete Order with Payment',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildPaymentRow(
                      'Order Total',
                      '৳${order.totalAmount.toStringAsFixed(2)}',
                    ),
                    _buildPaymentRow(
                      'Already Paid',
                      '৳${order.paidAmount.toStringAsFixed(2)}',
                    ),
                    _buildPaymentRow(
                      'Current Due',
                      '৳${dueAmount.toStringAsFixed(2)}',
                      isBold: true,
                      color: dueAmount > 0 ? Colors.orange : Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Input
              TextFormField(
                controller: paidAmountController,
                decoration: const InputDecoration(
                  labelText: 'Paid Amount*',
                  hintText: 'Enter paid amount',
                  border: OutlineInputBorder(),
                  prefixText: '৳',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Real-time due amount update can be added here if needed
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Remaining due: ৳${(order.totalAmount - (double.tryParse(paidAmountController.text) ?? order.paidAmount)).toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Buttons
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        final paidAmount = double.tryParse(
                          paidAmountController.text,
                        );
                        if (paidAmount == null ||
                            paidAmount < 0 ||
                            paidAmount > order.totalAmount) {
                          Get.snackbar(
                            'Error',
                            'Please enter valid paid amount (0 - ${order.totalAmount})',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        Navigator.pop(context); // Close payment dialog
                        try {
                          await controller.completeOrderWithPayment(
                            order.id!,
                            paidAmount,
                          );
                        } catch (e) {
                          // Error handled in controller
                        }
                      },
                      child: const Text(
                        'Complete Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStatusUpdate(
    OrderModel order,
    OrderController controller,
    String newStatus,
    bool isMobile,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Change order status from:'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  controller.getStatusIcon(order.status),
                  color: controller.getStatusColor(order.status),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: controller.getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 8),
                Icon(
                  controller.getStatusIcon(newStatus),
                  color: controller.getStatusColor(newStatus),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  newStatus.toUpperCase(),
                  style: TextStyle(
                    color: controller.getStatusColor(newStatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Order: #${order.orderId}'),
            Text('Shop: ${order.shopName}'),
            Text('Total Amount: ৳${order.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.getStatusColor(newStatus),
            ),
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              try {
                await controller.updateOrderStatus(order.id!, newStatus);
              } catch (e) {
                // Error handled in controller
              }
            },
            child: Text(
              'Update to ${newStatus.toUpperCase()}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
