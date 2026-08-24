import 'package:e_commerce_flutter/screen/product_by_category_screen/product_by_category_screen.dart';
import 'package:e_commerce_flutter/utility/animation/open_container_wrapper.dart';
import 'package:flutter/material.dart';
import '../../../models/category.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;

  const CategorySelector({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            child: OpenContainerWrapper(
              nextScreen:
                  ProductByCategoryScreen(selectedCategory: categories[index]),
              child: Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: category.isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: category.isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: category.isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.network(
                        category.image ?? '',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.error,
                            color: colorScheme.onSurfaceVariant,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name ?? '',
                      style: TextStyle(
                        color: category.isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
