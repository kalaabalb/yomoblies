import 'dart:io';

import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/login_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/screen/my_address_screen/my_address_screen.dart';
import 'package:e_commerce_flutter/screen/my_order_screen/my_order_screen.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/cart_screen.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/favorite_screen.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/category_selector.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/custom_app_bar.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/poster_section.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/screen/profile_screen/profile_screen.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:e_commerce_flutter/widget/product_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/category_selector.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/custom_app_bar.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/poster_section.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:e_commerce_flutter/widget/product_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

// Change ProductListScreen to StatefulWidget
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isInitialLoad = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_isInitialLoad) {
      _isInitialLoad = false;
      await Future.delayed(const Duration(milliseconds: 300));

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final dataProvider = context.read<DataProvider>();
          final productListProvider = context.read<ProductListProvider>();

          // Load essential data first
          await dataProvider.refreshAllData();

          // Update product list with loaded data
          productListProvider.updateProducts(dataProvider.allProducts);
        } catch (e) {
          print('Error in initial data load: $e');
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            // Show loading skeleton while data is loading
            if (dataProvider.isLoading && dataProvider.allProducts.isEmpty) {
              return _buildLoadingSkeleton();
            }

            return RefreshIndicator(
              onRefresh: () async {
                try {
                  await dataProvider.refreshAllData();
                  context.read<ProductListProvider>().refreshData(
                        dataProvider.allProducts,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data refreshed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Refresh failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: _buildContent(context, dataProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DataProvider dataProvider) {
    final welcomeText = dataProvider.safeTranslate(
      'welcome',
      fallback: 'Hello',
    );
    final userName = context.read<UserProvider>().getLoginUsr()?.name ??
        dataProvider.safeTranslate('user', fallback: 'User');

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Text(
              "$welcomeText $userName",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              dataProvider.safeTranslate(
                'get_something',
                fallback: 'Let\'s get something!',
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Posters section with loading state
            dataProvider.isPostersLoading && dataProvider.posters.isEmpty
                ? _buildPostersLoadingSkeleton()
                : const PosterSection(),

            const SizedBox(height: 20),

            // Categories section
            Text(
              dataProvider.safeTranslate(
                'top_categories',
                fallback: 'Top Categories',
              ),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),

            // Categories with loading state
            dataProvider.isCategoriesLoading && dataProvider.categories.isEmpty
                ? _buildCategoriesLoadingSkeleton()
                : Consumer<DataProvider>(
                    builder: (context, dataProvider, child) {
                      return CategorySelector(
                        categories: dataProvider.categories,
                      );
                    },
                  ),

            const SizedBox(height: 20),

            Text(
              'Products',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),

            // Products with loading state
            dataProvider.isProductsLoading && dataProvider.allProducts.isEmpty
                ? _buildProductsLoadingSkeleton()
                : Consumer2<DataProvider, ProductListProvider>(
                    builder:
                        (context, dataProvider, productListProvider, child) {
                      // Always ensure product list is updated with current data
                      if (productListProvider.filteredProducts.isEmpty &&
                          dataProvider.allProducts.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          productListProvider
                              .updateProducts(dataProvider.allProducts);
                        });
                      }

                      final displayProducts =
                          productListProvider.searchQuery.isEmpty
                              ? dataProvider.allProducts
                              : productListProvider.filteredProducts;

                      if (displayProducts.isEmpty) {
                        return _buildNoProductsState(dataProvider);
                      }

                      return ProductGridView(
                        items: displayProducts,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProductsState(DataProvider dataProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        // Wrap with Center widget
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Add this
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center, // Add this
            ),
            const SizedBox(height: 10),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center, // Add this
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                dataProvider.refreshAllData();
                context
                    .read<ProductListProvider>()
                    .clearSearch(dataProvider.allProducts);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  // YouTube-like loading skeleton for main content
  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome skeleton
          _buildShimmerLoader(width: 200, height: 28),
          const SizedBox(height: 8),
          _buildShimmerLoader(width: 150, height: 20),
          const SizedBox(height: 20),

          // Posters skeleton
          _buildPostersLoadingSkeleton(),
          const SizedBox(height: 20),

          // Categories skeleton
          _buildShimmerLoader(width: 120, height: 24),
          const SizedBox(height: 10),
          _buildCategoriesLoadingSkeleton(),
          const SizedBox(height: 20),

          // Products skeleton
          _buildShimmerLoader(width: 80, height: 24),
          const SizedBox(height: 10),
          _buildProductsLoadingSkeleton(),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader({double? width, double height = 20}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // Loading skeleton for posters
  Widget _buildPostersLoadingSkeleton() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 300,
              height: 170,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  // Loading skeleton for categories
  Widget _buildCategoriesLoadingSkeleton() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 80,
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Loading skeleton for products
  Widget _buildProductsLoadingSkeleton() {
    return GridView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 10 / 16,
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                // Title placeholder
                Container(
                  height: 16,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                // Price placeholder
                Container(
                  height: 14,
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                // Stock placeholder
                Container(
                  height: 12,
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColor.darkOrange),
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: profileProvider.profileImagePath != null
                          ? FileImage(File(profileProvider.profileImagePath!))
                              as ImageProvider
                          : const AssetImage('assets/images/profile_pic.png')
                              as ImageProvider,
                      child: profileProvider.profileImagePath == null
                          ? Text(
                              context
                                      .read<UserProvider>()
                                      .getLoginUsr()
                                      ?.name
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  context
                                      .read<DataProvider>()
                                      .safeTranslate('user', fallback: 'U')
                                      .substring(0, 1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColor.darkOrange,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.read<UserProvider>().getLoginUsr()?.name ??
                          context.read<DataProvider>().safeTranslate(
                                'user',
                                fallback: 'User',
                              ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      context.read<DataProvider>().safeTranslate(
                            'welcome_back',
                            fallback: 'Welcome back!',
                          ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: context.read<DataProvider>().safeTranslate(
                  'my_profile',
                  fallback: 'My Profile',
                ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.shopping_bag,
            title: context.read<DataProvider>().safeTranslate(
                  'my_orders',
                  fallback: 'My Orders',
                ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOrderScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.location_on,
            title: context.read<DataProvider>().safeTranslate(
                  'my_address',
                  fallback: 'My Address',
                ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyAddressPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.favorite,
            title: context.read<DataProvider>().safeTranslate(
                  'my_favorites',
                  fallback: 'My Favorites',
                ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart,
            title: context.read<DataProvider>().safeTranslate(
                  'my_cart',
                  fallback: 'My Cart',
                ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              context.read<DataProvider>().safeTranslate(
                    'settings',
                    fallback: 'SETTINGS',
                  ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return SwitchListTile(
                secondary: const Icon(
                  Icons.dark_mode,
                  color: AppColor.darkOrange,
                ),
                title: Text(
                  context.read<DataProvider>().safeTranslate(
                        'dark_mode',
                        fallback: 'Dark Mode',
                      ),
                ),
                value: dataProvider.isDarkMode,
                onChanged: (value) {
                  dataProvider.toggleDarkMode();
                },
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.language,
            title: context.read<DataProvider>().safeTranslate(
                  'language',
                  fallback: 'Language',
                ),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.help,
            title: context.read<DataProvider>().safeTranslate(
                  'help_support',
                  fallback: 'Help & Support',
                ),
            onTap: () {
              _showHelpSupportDialog(context);
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: context.read<DataProvider>().safeTranslate(
                  'logout',
                  fallback: 'Logout',
                ),
            onTap: () {
              context.read<UserProvider>().logOutUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColor.darkOrange),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                context.read<DataProvider>().safeTranslate(
                      'select_language',
                      fallback: 'Select Language',
                    ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageTile(context, 'English', 'en'),
                  _buildLanguageTile(context, 'Amharic', 'am'),
                  _buildLanguageTile(context, 'Spanish', 'es'),
                  _buildLanguageTile(context, 'French', 'fr'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String languageName,
    String languageCode,
  ) {
    return ListTile(
      title: Text(languageName),
      leading: const Icon(Icons.language),
      trailing: context.read<DataProvider>().currentLanguage == languageCode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        _changeLanguage(context, languageCode);
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    final dataProvider = context.read<DataProvider>();

    // Change language
    dataProvider.changeLanguage(languageCode);

    // Close dialog
    Navigator.pop(context);

    // Force rebuild of the entire app by going back to HomeScreen
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            context.read<DataProvider>().safeTranslate(
                  'help_support',
                  fallback: 'Help & Support',
                ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email, color: AppColor.darkOrange),
                title: Text(
                  context.read<DataProvider>().safeTranslate(
                        'telegram_support',
                        fallback: 'Telegram Support',
                      ),
                ),
                subtitle: const Text('@Yoni125'),
                onTap: () {
                  _launchUrl('https://t.me/Yoni125');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: AppColor.darkOrange),
                title: Text(
                  context.read<DataProvider>().safeTranslate(
                        'call_support',
                        fallback: 'Call Support',
                      ),
                ),
                subtitle: const Text('+251922737271'),
                onTap: () {
                  _launchUrl('tel:+251922737271');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.read<DataProvider>().safeTranslate(
                      'close',
                      fallback: 'Close',
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch URL'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
