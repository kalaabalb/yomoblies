import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '../../../shared/widgets/cards.dart';

class CartListSection extends StatelessWidget {
  final List<CartModel> cartProducts;

  const CartListSection({super.key, required this.cartProducts});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
            horizontal: 0, vertical: 8), // NO horizontal padding
        itemCount: cartProducts.length,
        itemBuilder: (context, index) {
          CartModel cartItem = cartProducts[index];
          return _buildCartItem(context, cartItem, index);
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartModel cartItem, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4), // Minimal padding
      child: CustomCard(
        padding: const EdgeInsets.all(8), // Minimal padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 60, // Even smaller
              height: 60, // Even smaller
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  (cartItem.productImages?.isNotEmpty ?? false)
                      ? cartItem.productImages!.first
                      : '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200]!,
                      child: Icon(
                        Icons.shopping_bag,
                        color: Colors.grey[400],
                        size: 24, // Smaller
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8), // Minimal spacing

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // Even smaller
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Variant info
                  if ((cartItem.variants.isNotEmpty) &&
                      (cartItem.variants.first.color != null))
                    Text(
                      'Variant: ${cartItem.variants.first.color}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),

                  const SizedBox(height: 4),

                  // Price and Quantity
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Birr ${_getItemPrice(context, cartItem).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFEC6813),
                          ),
                        ),
                      ),

                      // Quantity Controls - Ultra compact
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove,
                                size: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              onPressed: () {
                                context.read<CartProvider>().updateCart(
                                      cartItem,
                                      -1,
                                    );
                              },
                              padding: const EdgeInsets.all(1),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
                              child: Text(
                                '${cartItem.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              onPressed: () {
                                context.read<CartProvider>().updateCart(
                                      cartItem,
                                      1,
                                    );
                              },
                              padding: const EdgeInsets.all(1),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Subtotal
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Subtotal: Birr ${(cartItem.quantity * _getItemPrice(context, cartItem)).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getItemPrice(BuildContext context, CartModel cartItem) {
    if (cartItem.variants.isNotEmpty) {
      return cartItem.variants.first.price;
    }

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final product = dataProvider.allProducts.firstWhere(
        (p) => p.sId == cartItem.productId,
      );
      return product.offerPrice ?? product.price ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
