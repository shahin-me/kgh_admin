import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kgh_admin/controller/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(DashboardController());
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
          if (MediaQuery.of(context).size.width >= 600)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: controller.updateStats,
              ),
            ),
        ],
      ),
      drawer: MediaQuery.of(context).size.width < 600
          ? _buildDrawer(controller)
          : null,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar for desktop and tablet
            if (MediaQuery.of(context).size.width >= 600)
              _buildDesktopSidebar(controller, context),

            // Main content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 12.0 : 24.0,
                ),
                child: _buildMainContent(controller, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    DashboardController controller,
    BuildContext context,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome Banner
          _buildWelcomeBanner(context),
          const SizedBox(height: 24),

          // Statistics Grid - Responsive
          _buildResponsiveStatsGrid(controller, context),
          const SizedBox(height: 24),

          // Charts and Data Section - Responsive Layout
          _buildResponsiveDataSection(controller, context),
          const SizedBox(height: 24),

          // Bottom Section - Responsive Layout
          _buildResponsiveBottomSection(controller, context),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your store today.',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width >= 768)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatsGrid(
    DashboardController controller,
    BuildContext context,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 2;
    } else if (isTablet) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 4;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 1.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildStatCard(index, controller, context);
      },
    );
  }

  Widget _buildStatCard(
    int index,
    DashboardController controller,
    BuildContext context,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final stats = [
      {
        'title': 'Total Sales',
        'value': '\$${controller.totalSales.value}',
        'icon': Iconsax.chart_2,
        'color': Colors.blue,
        'progress': 0.75,
      },
      {
        'title': 'Total Orders',
        'value': controller.totalOrders.value.toString(),
        'icon': Iconsax.shopping_bag,
        'color': Colors.green,
        'progress': 0.60,
      },
      {
        'title': 'Total Products',
        'value': controller.totalProducts.value.toString(),
        'icon': Iconsax.box,
        'color': Colors.orange,
        'progress': 0.45,
      },
      {
        'title': 'Total Customers',
        'value': controller.totalCustomers.value.toString(),
        'icon': Iconsax.people,
        'color': Colors.purple,
        'progress': 0.85,
      },
    ];

    final stat = stats[index];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: (stat['color'] as Color).withOpacity(0.1),
                    // color: stat['color']!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stat['title'] as String,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 12 : 14,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stat['progress'] as double,
              backgroundColor: Colors.grey[200],
              color: stat['color'] as Color,
              minHeight: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveDataSection(
    DashboardController controller,
    BuildContext context,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      // Mobile Layout - Vertical
      return Column(
        children: [
          _buildSalesChart(context),
          const SizedBox(height: 16),
          _buildRecentOrders(controller, context),
        ],
      );
    } else {
      // Desktop/Tablet Layout - Horizontal
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: isTablet ? 1 : 2, child: _buildSalesChart(context)),
          const SizedBox(width: 16),
          Expanded(
            flex: isTablet ? 1 : 3,
            child: _buildRecentOrders(controller, context),
          ),
        ],
      );
    }
  }

  Widget _buildResponsiveBottomSection(
    DashboardController controller,
    BuildContext context,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    if (isMobile) {
      // Mobile Layout - Vertical
      return Column(
        children: [
          _buildTopProducts(controller, context),
          const SizedBox(height: 16),
          _buildQuickActions(context),
        ],
      );
    } else {
      // Desktop/Tablet Layout - Horizontal
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isTablet ? 1 : 3,
            child: _buildTopProducts(controller, context),
          ),
          const SizedBox(width: 16),
          Expanded(flex: isTablet ? 1 : 2, child: _buildQuickActions(context)),
        ],
      );
    }
  }

  Widget _buildSalesChart(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Overview',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: isMobile ? 150 : 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Sales Chart',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(
    DashboardController controller,
    BuildContext context,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            ...controller.recentOrders
                .take(isMobile ? 2 : 4)
                .map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOrderItem(order, context),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Iconsax.shopping_bag, color: Colors.blue[600], size: 20),
        ),
        title: Text(
          order['id'],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(order['customer'], style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              order['amount'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: order['statusColor'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order['status'],
                style: TextStyle(
                  color: order['statusColor'],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Iconsax.shopping_bag, color: Colors.blue[600]),
        ),
        title: Text(
          order['id'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(order['customer']),
        trailing: SizedBox(
          width: 120,
          child: Row(
            children: [
              Text(
                order['amount'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    color: order['statusColor'],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTopProducts(
    DashboardController controller,
    BuildContext context,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Products',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            ...controller.topProducts
                .take(isMobile ? 2 : 4)
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildProductItem(product, context),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: isMobile ? 36 : 48,
        height: isMobile ? 36 : 48,
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Iconsax.trend_up,
          color: Colors.green[600],
          size: isMobile ? 16 : 20,
        ),
      ),
      title: Text(
        product['name'],
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
      subtitle: Text(
        '${product['sales']} sales',
        style: TextStyle(fontSize: isMobile ? 12 : 14),
      ),
      trailing: Text(
        product['revenue'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final actions = [
      {'icon': Iconsax.add, 'title': 'Add Product', 'color': Colors.blue},
      {'icon': Iconsax.edit, 'title': 'Manage Products', 'color': Colors.green},
      {
        'icon': Iconsax.shopping_cart,
        'title': 'View Orders',
        'color': Colors.orange,
      },
      {
        'icon': Iconsax.people,
        'title': 'Customer List',
        'color': Colors.purple,
      },
      {'icon': Iconsax.chart_2, 'title': 'Analytics', 'color': Colors.red},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...actions.map(
              (action) => _QuickActionButton(
                icon: action['icon'] as IconData,
                title: action['title'] as String,
                color: action['color'] as Color,
                onTap: () {},
                isMobile: isMobile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar and Drawer Methods - UPDATED WITH NAVIGATION
  Widget _buildDesktopSidebar(
    DashboardController controller,
    BuildContext context,
  ) {
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return Container(
      width: isTablet ? 200 : 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: isTablet ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ..._getSidebarItems(controller).map(
            (item) => _SidebarItem(
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              isSelected: item['isSelected'] as bool,
              onTap: item['onTap'] as VoidCallback,
              isTablet: isTablet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(DashboardController controller) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Colors.blue),
                ),
                SizedBox(height: 12),
                Text(
                  'Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'admin@example.com',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ..._getSidebarItems(controller).map(
            (item) => ListTile(
              leading: Icon(item['icon'] as IconData),
              title: Text(item['title'] as String),
              selected: item['isSelected'] as bool,
              onTap: item['onTap'] as VoidCallback,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSidebarItems(DashboardController controller) {
    final currentRoute = Get.currentRoute;

    return [
      {
        'icon': Icons.dashboard,
        'title': 'Dashboard',
        'isSelected': currentRoute == '/dashboard',
        'onTap': controller.navigateToDashboard,
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Products',
        'isSelected': currentRoute == '/products',
        'onTap': controller.navigateToProducts,
      },
      {
        'icon': Icons.shopping_cart,
        'title': 'Orders',
        'isSelected': currentRoute == '/orders',
        'onTap': controller.navigateToOrders,
      },
      {
        'icon': Icons.people,
        'title': 'Customers',
        'isSelected': currentRoute == '/customers',
        'onTap': controller.navigateToCustomers,
      },
      {
        'icon': Icons.analytics,
        'title': 'Analytics',
        'isSelected': currentRoute == '/analytics',
        'onTap': controller.navigateToAnalytics,
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'isSelected': currentRoute == '/settings',
        'onTap': controller.navigateToSettings,
      },
    ];
  }
}

// Custom Widgets
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isMobile;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: isMobile,
      leading: Container(
        width: isMobile ? 32 : 40,
        height: isMobile ? 32 : 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: isMobile ? 16 : 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
      trailing: Icon(Iconsax.arrow_right_3, size: isMobile ? 14 : 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue[700] : Colors.grey[600],
          size: isTablet ? 20 : 24,
        ),
        title: isTablet
            ? null
            : Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                ),
              ),
        onTap: onTap,
      ),
    );
  }
}
