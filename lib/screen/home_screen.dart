import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/product_list_screen.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/cart_screen.dart';
import 'package:e_commerce_flutter/screen/profile_screen/profile_screen.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/favorite_screen.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProductListScreen(),
    const FavoriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedItemColor: AppColor.darkOrange,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: dataProvider.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite),
                label: dataProvider.translate('favorites'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_cart),
                label: dataProvider.translate('cart'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: dataProvider.translate('profile'),
              ),
            ],
          ),
        );
      },
    );
  }
}
