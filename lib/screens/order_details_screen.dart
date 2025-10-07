import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kgh_admin/controller/order_controller.dart';
import 'package:kgh_admin/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel? order;

  const OrderDetailsScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      // যদি order null হয়, তাহলে error show করে back করে দিবে
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Error',
          'Order not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final orderController = Get.find<OrderController>();
    final orderData = order!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderData.orderId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value != orderData.status) {
                orderController.updateOrderStatus(orderData.id!, value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Text('Mark as Pending'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Mark as Completed'),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Text('Cancel Order'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildOrderSummaryCard(orderData),
            const SizedBox(height: 16),

            // Shop Information
            _buildShopInfoCard(orderData),
            const SizedBox(height: 16),

            // Order Items
            _buildOrderItemsCard(orderData),
            const SizedBox(height: 16),

            // Payment Summary
            _buildPaymentSummaryCard(orderData),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Order ID', order.orderId),
            _buildDetailRow(
              'Order Date',
              DateFormat('MMMM dd, yyyy - hh:mm a').format(order.createdAt),
            ),
            _buildDetailRow('Total Items', '${order.totalItems}'),
            _buildDetailRow(
              'Total Amount',
              '৳${order.totalAmount.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfoCard(OrderModel order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Shop Name', order.shopName),
            _buildDetailRow('Address', order.shopAddress),
            _buildDetailRow('User ID', order.userId),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(OrderModel order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${order.items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildOrderItemTile(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${item.pricePerUnit.toStringAsFixed(2)} × ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Total Price
          Text(
            '৳${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(OrderModel order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentRow(
              'Total Amount',
              '৳${order.totalAmount.toStringAsFixed(2)}',
            ),
            _buildPaymentRow(
              'Paid Amount',
              '৳${order.paidAmount.toStringAsFixed(2)}',
              isPositive: true,
            ),
            if (order.previousDue > 0)
              _buildPaymentRow(
                'Previous Due',
                '৳${order.previousDue.toStringAsFixed(2)}',
                isNegative: true,
              ),
            if (order.previousCustomerPayable > 0)
              _buildPaymentRow(
                'Previous Payable',
                '৳${order.previousCustomerPayable.toStringAsFixed(2)}',
                isPositive: true,
              ),
            const Divider(),
            _buildPaymentRow(
              'Due Amount',
              '৳${order.dueAmount.toStringAsFixed(2)}',
              isBold: true,
              isNegative: order.dueAmount > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
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

  Widget _buildPaymentRow(
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
}
