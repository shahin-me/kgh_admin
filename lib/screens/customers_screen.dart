import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kgh_admin/controller/customer_controller.dart';
import 'package:kgh_admin/models/customer_model.dart';
import 'package:kgh_admin/screens/customer_details_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => customerController.refreshCustomers(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            _buildStatistics(customerController),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(customerController),
            const SizedBox(height: 16),

            // Customers List
            Expanded(child: _buildCustomersList(customerController)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(CustomerController controller) {
    return Obx(() {
      final stats = controller.getCustomerStatistics();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard(
              'Total Customers',
              stats['total'].toString(),
              Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'With Due',
              stats['withDue'].toString(),
              Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'With Payable',
              stats['withPayable'].toString(),
              Colors.green,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Net Balance',
              '৳${stats['netBalance'].toStringAsFixed(0)}',
              stats['netBalance'] >= 0 ? Colors.purple : Colors.red,
            ),
          ],
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

  Widget _buildSearchBar(CustomerController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search customers by shop name, phone, or address...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
        onChanged: (value) {
          // Implement search functionality if needed
        },
      ),
    );
  }

  Widget _buildCustomersList(CustomerController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refreshCustomers(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.customers.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No customers found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.customers.length,
        itemBuilder: (context, index) {
          final customer = controller.customers[index];
          return _buildCustomerItem(customer);
        },
      );
    });
  }

  Widget _buildCustomerItem(CustomerModel customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(Icons.business_center, color: Colors.blue[700], size: 24),
        ),
        title: Text(
          customer.shopName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'প্রোপাইটর: ${customer.proprietorName}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              customer.phone,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (customer.hasDue)
                  _buildBalanceChip(
                    'Due: ৳${customer.totalDue.toInt()}',
                    Colors.orange,
                  ),
                if (customer.hasPayable)
                  _buildBalanceChip(
                    'Payable: ৳${customer.totalPayableToCustomer.toInt()}',
                    Colors.green,
                  ),
                if (!customer.hasDue && !customer.hasPayable)
                  _buildBalanceChip('Settled', Colors.grey),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              customer.deliveryDay.isNotEmpty
                  ? customer.deliveryDay
                  : 'No Schedule',
              style: TextStyle(
                fontSize: 12,
                color: customer.deliveryDay.isNotEmpty
                    ? Colors.blue
                    : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(customer.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        onTap: () {
          Get.to(() => CustomerDetailsScreen(customer: customer));
        },
      ),
    );
  }

  Widget _buildBalanceChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
