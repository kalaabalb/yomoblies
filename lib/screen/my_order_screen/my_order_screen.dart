import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/screen/order_details_screen/order_details_screen.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/loading_states.dart';
import '../../shared/widgets/cards.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
      _debugAllOrders();
    });
  }

  void _loadOrders() async {
    await context.dataProvider.getAllOrders();
    _debugOrders();
  }

  void _debugOrders() {
    final dataProvider = context.dataProvider;
    final userProvider = context.userProvider;
    final currentUser = userProvider.getLoginUsr();

    print(
        '🟡 [ORDERS DEBUG] Total orders from server: ${dataProvider.orders.length}');

    final userOrders = dataProvider.orders.where((order) {
      final isUserOrder = order.userID?.sId == currentUser?.sId;
      print(
          '🟡 [ORDERS DEBUG] Order ${order.sId} - User: ${order.userID?.sId} - Is Current User: $isUserOrder');
      return isUserOrder;
    }).toList();

    // ignore: unused_local_variable
    for (final order in userOrders) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.dataProvider.translate('my_orders'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkOrange,
          ),
        ),
      ),
      body: Consumer2<DataProvider, UserProvider>(
        builder: (context, dataProvider, userProvider, child) {
          // Get current user
          final currentUser = userProvider.getLoginUsr();

          // Filter orders by current user
          final userOrders = dataProvider.orders.where((order) {
            return order.userID?.sId == currentUser?.sId;
          }).toList();

          if (userOrders.isEmpty) {
            return const EmptyState(
              title: 'No Orders Yet',
              subtitle: 'Your orders will appear here',
              icon: Icons.shopping_bag_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.dataProvider.getAllOrders();
              _debugOrders(); // Debug after refresh
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userOrders.length,
              itemBuilder: (context, index) {
                final order = userOrders[index];
                return _buildOrderCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.sId?.substring(order.sId!.length - 6).toUpperCase() ?? 'N/A'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatDate(order.orderDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOrderItemsPreview(order),
          const SizedBox(height: 12),
          // Payment Method
          Row(
            children: [
              Icon(
                _getPaymentMethodIcon(order.paymentMethod),
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _getPaymentMethodDisplayName(order.paymentMethod),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order Status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.orderStatus),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.orderStatusDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Payment Status (for non-COD orders)
              if (order.paymentMethod != 'cod')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(order.paymentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.paymentStatusDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // Total Price
              Text(
                'Birr ${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColor.darkOrange,
                ),
              ),
            ],
          ),

          // Payment Pending Notice
          if (order.paymentMethod != 'cod' && order.isPaymentPending)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[800], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Awaiting payment verification',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _debugAllOrders() {
    final dataProvider = context.dataProvider;
    final userProvider = context.userProvider;
    final currentUser = userProvider.getLoginUsr();

    print(
        '🟡 [ORDERS FULL DEBUG] All orders count: ${dataProvider.orders.length}');

    // ignore: unused_local_variable
    for (final order in dataProvider.orders) {}

    dataProvider.orders.where((order) {
      return order.userID?.sId == currentUser?.sId;
    }).toList();
  }

  Widget _buildOrderItemsPreview(Order order) {
    final firstItem =
        order.items?.isNotEmpty == true ? order.items!.first : null;
    final itemCount = order.items?.length ?? 0;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.shopping_bag, color: Colors.grey[400]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstItem?.productName ?? 'Order Items',
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                itemCount == 1 ? '1 item' : '$itemCount items',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    );
  }

  IconData _getPaymentMethodIcon(String? paymentMethod) {
    switch (paymentMethod) {
      case 'cod':
        return Icons.money_off;
      case 'cbe':
        return Icons.account_balance;
      case 'telebirr':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodDisplayName(String? paymentMethod) {
    switch (paymentMethod) {
      case 'cod':
        return 'Cash on Delivery';
      case 'cbe':
        return 'CBE Bank';
      case 'telebirr':
        return 'Telebirr';
      default:
        return paymentMethod ?? 'Unknown';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
      case 'processing':
      case 'payment_verified':
        return Colors.blue;
      case 'payment_pending':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
