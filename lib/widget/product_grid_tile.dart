import 'package:e_commerce_flutter/screen/product_details_screen/product_detail_screen.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'custom_network_image.dart';
import '../shared/widgets/cards.dart';

class ProductGridTile extends StatelessWidget {
  final Product product;

  const ProductGridTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.favoriteProvider;
    final isFavorite = favoriteProvider.checkIsItemFavorite(product.sId!);

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product),
          ),
        );
      },
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
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
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () {
                    favoriteProvider.updateToFavoriteList(product.sId!);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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

          // Price
          Row(
            children: [
              Text(
                "Birr ${product.offerPrice ?? product.price}",
                style: const TextStyle(
                  fontSize: 12, // Reduce from 14 or 16
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkOrange,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Add ellipsis if too long
              ),
              if (product.offerPrice != null &&
                  product.offerPrice != product.price) ...[
                const SizedBox(width: 4),
                Text(
                  'Birr ${product.price}',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
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
    );
  }
}
