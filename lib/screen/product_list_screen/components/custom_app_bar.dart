import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/widget/app_bar_action_button.dart';
import 'package:e_commerce_flutter/widget/universal_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(100);

  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    final productListProvider = context.read<ProductListProvider>();
    _searchController =
        TextEditingController(text: productListProvider.searchQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBarActionButton(
              icon: Icons.menu,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Expanded(
              child: Consumer2<DataProvider, ProductListProvider>(
                builder: (context, dataProvider, productListProvider, child) {
                  // Only update controller if the search query changed from external source
                  if (_searchController.text !=
                          productListProvider.searchQuery &&
                      !_searchFocusNode.hasFocus) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _searchController.text = productListProvider.searchQuery;
                    });
                  }

                  return UniversalSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (val) {
                      productListProvider.searchProducts(
                        val,
                        dataProvider.allProducts,
                      );
                    },
                    hintText: dataProvider.safeTranslate(
                      'search_hint',
                      fallback: 'Search...',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
