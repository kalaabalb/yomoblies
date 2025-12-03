import 'provider/cart_provider.dart';
import '../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utility/animation/animated_switcher_wrapper.dart';
import '../../utility/app_color.dart';
import 'components/buy_now_bottom_sheet.dart';
import 'components/cart_list_section.dart';
import 'components/empty_cart.dart';
import '../../shared/widgets/buttons.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = context.read<CartProvider>();
      cartProvider.getCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.dataProvider.translate('my_cart'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkOrange,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final cartProvider = context.read<CartProvider>();
          cartProvider.getCartItems();
        },
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                cartProvider.myCartItems.isEmpty
                    ? const EmptyCart()
                    : CartListSection(cartProducts: cartProvider.myCartItems),

                // Total price section
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.dataProvider.translate('total'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      AnimatedSwitcherWrapper(
                        child: Text(
                          "Birr ${cartProvider.getCartSubTotal().toStringAsFixed(2)}",
                          key: ValueKey<double>(cartProvider.getCartSubTotal()),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: AppColor.darkOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Buy now button
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                  child: PrimaryButton(
                    text: context.dataProvider.translate('buy_now'),
                    onPressed: cartProvider.myCartItems.isEmpty
                        ? null
                        : () {
                            showCustomBottomSheet(context);
                          },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
