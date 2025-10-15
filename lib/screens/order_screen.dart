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
          // Fast Loading Buttons
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading Status
            _buildLoadingStatus(orderController),
            const SizedBox(height: 12),

            // Statistics Cards
            _buildStatistics(orderController),
            const SizedBox(height: 12),

            // Filter Chips
            _buildFilterChips(orderController),
            const SizedBox(height: 16),

            // Orders List
            Expanded(child: _buildOrdersList(orderController)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatus(OrderController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
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
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.isLoading.value
                    ? 'Loading orders...'
                    : '${controller.orders.length} orders loaded instantly!',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: controller.isLoading.value
                      ? Colors.orange
                      : Colors.green,
                ),
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
      ),
    );
  }

  Widget _buildStatistics(OrderController controller) {
    return Obx(() {
      final stats = controller.getOrderStatistics();
      return AnimatedOpacity(
        opacity: controller.orders.isEmpty ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard(
                'Total Orders',
                stats['total'].toString(),
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Completed',
                stats['completed'].toString(),
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Pending',
                stats['pending'].toString(),
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Revenue',
                '৳${stats['totalRevenue'].toStringAsFixed(0)}',
                Colors.purple,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(OrderController controller) {
    return Obx(
      () => AnimatedOpacity(
        opacity: controller.orders.isEmpty ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('All', 'all', controller),
            _buildFilterChip('Completed', 'completed', controller),
            _buildFilterChip('Pending', 'pending', controller),
            _buildFilterChip('Cancelled', 'cancelled', controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    OrderController controller,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: controller.selectedStatus.value == value,
      onSelected: controller.orders.isEmpty
          ? null
          : (selected) {
              controller.filterOrders(status: value);
            },
    );
  }

  Widget _buildOrdersList(OrderController controller) {
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

      // Show orders immediately, even if loading
      final groupedOrders = controller.getOrdersGroupedByDate();
      final sortedDates = groupedOrders.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      return Column(
        children: [
          // Orders Count
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.orders.length} Orders',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (controller.isLoading.value)
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Updating...',
                        style: TextStyle(
                          fontSize: 12,
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
              itemCount: sortedDates.length,
              itemBuilder: (context, dateIndex) {
                final date = sortedDates[dateIndex];
                final ordersForDate = groupedOrders[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Text(
                        DateFormat('MMMM dd, yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    // Orders for this date
                    ...ordersForDate.map((order) => _buildOrderItem(order)),
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOrderItem(OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _getStatusIcon(order.status),
            color: _getStatusColor(order.status),
            size: 20,
          ),
        ),
        title: Text(
          'Order #${order.orderId}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              order.shopName,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              'Phone: ${order.phoneNumber ?? 'Loading...'}',
              style: TextStyle(
                color: order.phoneNumber == 'Loading...'
                    ? Colors.orange
                    : Colors.grey[600],
                fontSize: 11,
                fontStyle: order.phoneNumber == 'Loading...'
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                _buildInfoChip('${order.totalItems} items', Colors.blue),
                const SizedBox(width: 6),
                _buildInfoChip('৳${order.totalAmount.toInt()}', Colors.green),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(order.status)),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              order.dueAmount > 0 ? 'Due: ৳${order.dueAmount.toInt()}' : 'Paid',
              style: TextStyle(
                fontSize: 9,
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

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w500,
        ),
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
}
