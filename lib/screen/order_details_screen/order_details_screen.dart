import 'package:flutter/material.dart';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/cards.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkOrange,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card - SIMPLIFIED
            _buildOrderSummaryCard(context),
            const SizedBox(height: 16),

            // Order Items - MAIN CONTENT
            _buildOrderItemsCard(context),
            const SizedBox(height: 16),

            // Shipping Address
            _buildAddressCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange,
            ),
          ),
          const SizedBox(height: 12),
          InfoCard(title: 'Order Date', value: _formatDate(order.orderDate)),
          InfoCard(title: 'Status', value: _formatStatus(order.orderStatus)),
          const Divider(),
          InfoCard(
            title: 'Subtotal',
            value:
                'Birr ${order.orderTotal?.subtotal?.toStringAsFixed(2) ?? '0.00'}',
          ),
          if ((order.orderTotal?.discount ?? 0) > 0)
            InfoCard(
              title: 'Discount',
              value:
                  '-Birr ${order.orderTotal?.discount?.toStringAsFixed(2) ?? '0.00'}',
            ),
          InfoCard(
            title: 'Total',
            value:
                'Birr ${order.orderTotal?.total?.toStringAsFixed(2) ?? '0.00'}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${order.shippingAddress?.street}',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            '${order.shippingAddress?.city}, ${order.shippingAddress?.state}',
          ),
          Text(
            '${order.shippingAddress?.country} - ${order.shippingAddress?.postalCode}',
          ),
          Text('Phone: ${order.shippingAddress?.phone}'),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context) {
    // Get category name from first item
    String categoryName = _getCategoryName(context, order);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkOrange,
                ),
              ),
              if (categoryName.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.darkOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      color: AppColor.darkOrange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...(order.items ?? [])
              .map((item) => _buildOrderItem(context, item))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Items item) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final product = dataProvider.allProducts.firstWhere(
      (p) => p.sId == item.productID,
      orElse: () => Product(),
    );

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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomNetworkImage(
                imageUrl: product.images?.isNotEmpty == true
                    ? product.images!.first.url ?? ''
                    : '',
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
                  item.productName ?? 'Unknown Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.variant?.isNotEmpty == true)
                  Text(
                    'Variant: ${item.variant}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Birr ${(item.price ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(BuildContext context, Order order) {
    if (order.items?.isNotEmpty == true) {
      final firstItemId = order.items!.first.productID;
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final product = dataProvider.allProducts.firstWhere(
        (p) => p.sId == firstItemId,
        orElse: () => Product(),
      );
      return product.proCategoryId?.name ?? '';
    }
    return '';
  }

  String _formatStatus(String? status) {
    if (status == null) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
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
