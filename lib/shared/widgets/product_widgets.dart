import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../utility/app_color.dart';
import 'package:provider/provider.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onFavoriteTap,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.offerPrice != null &&
        product.offerPrice != product.price &&
        product.offerPrice! < product.price!;
    final discountPercent = hasDiscount
        ? ((product.price! - product.offerPrice!) / product.price! * 100)
            .round()
        : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Discount Badge
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: CustomNetworkImage(
                      imageUrl: product.images?.isNotEmpty == true
                          ? product.images!.first.url ?? ''
                          : '',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Discount Badge
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discountPercent% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Favorite Button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Product Name
              Text(
                product.name ?? 'Unknown Product',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              Consumer<FavoriteProvider>(
                builder: (context, favoriteProvider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Birr ${product.offerPrice ?? product.price}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkOrange,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Stock status
              const SizedBox(height: 4),
              Text(
                product.quantity != 0 ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  color: product.quantity != 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
