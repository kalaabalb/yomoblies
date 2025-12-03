import 'package:e_commerce_flutter/screen/product_details_screen/components/rating_section.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'provider/product_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widget/carousel_slider.dart';
import '../../widget/page_wrapper.dart';
import '../../models/product.dart';
import '../../widget/horizondal_list.dart';
import '../../shared/widgets/buttons.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    final proDetailProvider = context.proDetailProvider;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
        ),
        title: Text(
          context.dataProvider.translate('product_details') ??
              'Product Details',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: PageWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image section
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E6E8),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(200),
                      bottomLeft: Radius.circular(200),
                    ),
                  ),
                  child: CarouselSlider(items: product.images ?? []),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        '${product.name}',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 10),
                      // Product rating section
                      RatingSection(product: product),
                      const SizedBox(height: 10),
                      // Product rate, offer, stock section
                      Row(
                        children: [
                          Text(
                            product.offerPrice != null
                                ? "Birr ${product.offerPrice}"
                                : "Birr ${product.price}",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(width: 3),
                          Visibility(
                            visible: product.offerPrice != product.price,
                            child: Text(
                              "Birr ${product.price}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            product.quantity != 0
                                ? "${context.dataProvider.translate('available_stock')} : ${product.quantity}"
                                : context.dataProvider.translate(
                                    'not_available',
                                  ),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      product.proVariantId!.isNotEmpty
                          ? Text(
                              '${context.dataProvider.translate('available')} ${product.proVariantTypeId?.type ?? context.dataProvider.translate('options')}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            )
                          : const SizedBox(),
                      Consumer<ProductDetailProvider>(
                        builder: (context, proDetailProvider, child) {
                          return HorizontalList(
                            items: product.proVariantId ?? [],
                            itemToString: (val) => val,
                            selected: proDetailProvider.selectedVariant,
                            onSelect: (val) {
                              proDetailProvider.selectedVariant = val;
                              proDetailProvider.updateUI();
                            },
                          );
                        },
                      ),
                      // Product description
                      const SizedBox(height: 20),
                      Text(
                        context.dataProvider.translate('about'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text("${product.description}"),
                      const SizedBox(height: 40),
                      // Add to cart button
                      PrimaryButton(
                        text: context.dataProvider.translate('add_to_cart'),
                        onPressed: product.quantity != 0
                            ? () {
                                proDetailProvider.addToCart(product, context);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
