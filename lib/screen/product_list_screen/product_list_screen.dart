import 'dart:io';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widget/app_bar_action_button.dart';
import '../../widget/product_grid_view.dart';
import 'components/category_selector.dart';
import 'components/poster_section.dart';
import '../../utility/app_color.dart';
import '../profile_screen/profile_screen.dart';
import '../my_order_screen/my_order_screen.dart';
import '../my_address_screen/my_address_screen.dart';
import '../product_favorite_screen/favorite_screen.dart';
import '../product_cart_screen/cart_screen.dart';
import '../../shared/widgets/loading_states.dart';

// Change ProductListScreen to StatefulWidget
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Load data when this screen is created
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_isInitialLoad) {
      _isInitialLoad = false;
      // Small delay to ensure context is available
      await Future.delayed(const Duration(milliseconds: 300));

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final dataProvider = context.read<DataProvider>();
        final productListProvider = context.read<ProductListProvider>();

        // Load all data
        await dataProvider.refreshAllData();

        // Update product list with loaded data
        productListProvider.updateProducts(dataProvider.allProducts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.safeDataProvider.refreshAllData();
            context.productListProvider.refreshData(
              context.safeDataProvider.allProducts,
            );
          },
          child: Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              // Show loading skeleton while data is loading
              if (dataProvider.isLoading && dataProvider.allProducts.isEmpty) {
                return _buildLoadingSkeleton();
              }

              final welcomeText = dataProvider.safeTranslate(
                'welcome',
                fallback: 'Hello',
              );
              final userName = context.userProvider.getLoginUsr()?.name ??
                  dataProvider.safeTranslate('user', fallback: 'User');

              return SingleChildScrollView(
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
                      dataProvider.isPostersLoading &&
                              dataProvider.posters.isEmpty
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
                      dataProvider.isCategoriesLoading &&
                              dataProvider.categories.isEmpty
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
                      dataProvider.isProductsLoading &&
                              dataProvider.allProducts.isEmpty
                          ? _buildProductsLoadingSkeleton()
                          : Consumer2<DataProvider, ProductListProvider>(
                              builder: (context, dataProvider,
                                  productListProvider, child) {
                                // Always ensure product list is updated with current data
                                if (productListProvider
                                        .filteredProducts.isEmpty &&
                                    dataProvider.allProducts.isNotEmpty) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    productListProvider.updateProducts(
                                        dataProvider.allProducts);
                                  });
                                }

                                final displayProducts =
                                    productListProvider.searchQuery.isEmpty
                                        ? dataProvider.allProducts
                                        : productListProvider.filteredProducts;

                                return ProductGridView(
                                  items: displayProducts,
                                );
                              },
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ... rest of the file remains the same (loading skeletons, drawer, etc.)

  // YouTube-like loading skeleton for main content
  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome skeleton
          const ShimmerLoading(width: 200, height: 24),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 150, height: 18),
          const SizedBox(height: 20),

          // Posters skeleton
          _buildPostersLoadingSkeleton(),
          const SizedBox(height: 20),

          // Categories skeleton
          const ShimmerLoading(width: 120, height: 20),
          const SizedBox(height: 10),
          _buildCategoriesLoadingSkeleton(),
          const SizedBox(height: 20),

          // Products skeleton
          const ShimmerLoading(width: 80, height: 20),
          const SizedBox(height: 10),
          _buildProductsLoadingSkeleton(),
        ],
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
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 20),
            child: const ShimmerLoading(height: 170),
          );
        },
      ),
    );
  }

  // Loading skeleton for categories
  Widget _buildCategoriesLoadingSkeleton() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: const ShimmerLoading(height: 80),
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
        return const ShimmerLoading(height: 200);
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
                              context.userProvider
                                      .getLoginUsr()
                                      ?.name
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  context.safeDataProvider
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
                      context.userProvider.getLoginUsr()?.name ??
                          context.safeDataProvider.safeTranslate(
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
                      context.safeDataProvider.safeTranslate(
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
            title: context.safeDataProvider.safeTranslate(
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
            title: context.safeDataProvider.safeTranslate(
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
            title: context.safeDataProvider.safeTranslate(
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
            title: context.safeDataProvider.safeTranslate(
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
            title: context.safeDataProvider.safeTranslate(
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
              context.safeDataProvider.safeTranslate(
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
                  context.safeDataProvider.safeTranslate(
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
            title: context.safeDataProvider.safeTranslate(
              'language',
              fallback: 'Language',
            ),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.help,
            title: context.safeDataProvider.safeTranslate(
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
            title: context.safeDataProvider.safeTranslate(
              'logout',
              fallback: 'Logout',
            ),
            onTap: () {
              context.userProvider.logOutUser();
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
                context.safeDataProvider.safeTranslate(
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
      trailing: context.dataProvider.currentLanguage == languageCode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        _changeLanguage(context, languageCode);
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    final dataProvider = context.safeDataProvider;

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
            context.safeDataProvider.safeTranslate(
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
                  context.safeDataProvider.safeTranslate(
                    'telegram_support',
                    fallback: 'telegram Support',
                  ),
                ),
                subtitle: const Text('@Yoni125'),
                onTap: () {
                  _launchEmail(context);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: AppColor.darkOrange),
                title: Text(
                  context.safeDataProvider.safeTranslate(
                    'call_support',
                    fallback: 'Call Support',
                  ),
                ),
                subtitle: const Text('0922737271'),
                onTap: () {
                  _launchPhoneCall(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.safeDataProvider.safeTranslate(
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

  void _launchEmail(BuildContext context) async {
    final isAmharic = context.safeDataProvider.currentLanguage == 'am';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'yonasmarketplace@gmial.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'App Support Request',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      SnackBarHelper.showErrorSnackBar(
        isAmharic ? 'ኢሜይል መተግበሪያ ማስጀመር አልተቻለም' : 'Could not launch email app',
      );
    }
  }

  void _launchPhoneCall(BuildContext context) async {
    final isAmharic = context.safeDataProvider.currentLanguage == 'am';

    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+0922737271');

    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      SnackBarHelper.showErrorSnackBar(
        isAmharic ? 'የስልክ መተግበሪያ ማስጀመር አልተቻለም' : 'Could not launch phone app',
      );
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}

// Custom App Bar for Product List Screen
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
                    hintText: context.safeDataProvider.safeTranslate(
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

// Universal Search Bar Component
class UniversalSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final VoidCallback? onClear;

  const UniversalSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.hintText,
    this.onClear,
  });

  @override
  State<UniversalSearchBar> createState() => _UniversalSearchBarState();
}

class _UniversalSearchBarState extends State<UniversalSearchBar> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          hintText: widget.hintText ??
              context.safeDataProvider.safeTranslate(
                'search_hint',
                fallback: 'Search...',
              ),
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.search,
              color: AppColor.darkOrange,
              size: 20,
            ),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                    _focusNode.requestFocus();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
