import 'dart:ui';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/shared/widgets/cards.dart';
import 'package:e_commerce_flutter/shared/widgets/forms.dart';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showCustomBottomSheet(BuildContext context) {
  final cartProvider = context.read<CartProvider>();
  final dataProvider = context.read<DataProvider>();
  cartProvider.retrieveSavedAddress();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: cartProvider.buyNowFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dataProvider.safeTranslate(
                              'complete_order',
                              fallback: 'Complete Order',
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Toggle Address Fields
                      CustomCard(
                        child: ListTile(
                          title: Text(
                            dataProvider.safeTranslate(
                              'enter_address',
                              fallback: 'Enter Shipping Address',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              return IconButton(
                                icon: Icon(
                                  cartProvider.isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () {
                                  cartProvider.isExpanded =
                                      !cartProvider.isExpanded;
                                  cartProvider.updateUI();
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: cartProvider.isExpanded ? null : 0,
                            child: Visibility(
                              visible: cartProvider.isExpanded,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: AddressFormFields(
                                  phoneController: cartProvider.phoneController,
                                  streetController:
                                      cartProvider.streetController,
                                  cityController: cartProvider.cityController,
                                  stateController: cartProvider.stateController,
                                  postalCodeController:
                                      cartProvider.postalCodeController,
                                  countryController:
                                      cartProvider.countryController,
                                  validator: (value) => value!.isEmpty
                                      ? 'This field is required'
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Payment Options
                      CustomCard(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataProvider.safeTranslate(
                                  'payment_method',
                                  fallback: 'Payment Method',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Consumer<CartProvider>(
                                builder: (context, cartProvider, child) {
                                  return Column(
                                    children: [
                                      // Cash on Delivery
                                      _buildPaymentOption(
                                        context,
                                        title: '💰 Cash on Delivery',
                                        subtitle:
                                            'Pay when you receive your order',
                                        value: 'cod',
                                        isSelected: cartProvider
                                                .selectedPaymentOption ==
                                            'cod',
                                        onTap: () {
                                          cartProvider.selectedPaymentOption =
                                              'cod';
                                          cartProvider.updateUI();
                                        },
                                        icon: Icons.money_off,
                                      ),
                                      const SizedBox(height: 8),
                                      // Commercial Bank of Ethiopia
                                      _buildPaymentOption(
                                        context,
                                        title: '🏦 Commercial Bank of Ethiopia',
                                        subtitle: 'Bank transfer or CBE Birr',
                                        value: 'cbe',
                                        isSelected: cartProvider
                                                .selectedPaymentOption ==
                                            'cbe',
                                        onTap: () {
                                          cartProvider.selectedPaymentOption =
                                              'cbe';
                                          cartProvider.updateUI();
                                        },
                                        icon: Icons.account_balance,
                                      ),
                                      const SizedBox(height: 8),
                                      // Telebirr
                                      _buildPaymentOption(
                                        context,
                                        title: '📱 Telebirr',
                                        subtitle: 'Mobile money payment',
                                        value: 'telebirr',
                                        isSelected: cartProvider
                                                .selectedPaymentOption ==
                                            'telebirr',
                                        onTap: () {
                                          cartProvider.selectedPaymentOption =
                                              'telebirr';
                                          cartProvider.updateUI();
                                        },
                                        icon: Icons.phone_android,
                                      ),

                                      // Show payment instructions when CBE or Telebirr is selected
                                      if (cartProvider.selectedPaymentOption ==
                                              'cbe' ||
                                          cartProvider.selectedPaymentOption ==
                                              'telebirr') ...[
                                        const SizedBox(height: 15),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blue[100]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.info,
                                                      color: Colors.blue[700],
                                                      size: 20),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Payment Instructions',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                cartProvider.selectedPaymentOption ==
                                                        'cbe'
                                                    ? 'After selecting "Complete Order", you will see detailed instructions for CBE payment and be able to upload your payment proof.'
                                                    : 'After selecting "Complete Order", you will see detailed instructions for Telebirr payment and be able to upload your payment proof.',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const SizedBox(height: 10),

                      // Total Amount Display
                      CustomCard(
                        child: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InfoCard(
                                    title: dataProvider.safeTranslate(
                                      'total_amount',
                                      fallback: 'Subtotal:',
                                    ),
                                    value:
                                        "Birr ${cartProvider.getCartSubTotal().toStringAsFixed(2)}",
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  InfoCard(
                                    title: dataProvider.safeTranslate(
                                      'grand_total',
                                      fallback: 'Grand Total:',
                                    ),
                                    value:
                                        "Birr ${cartProvider.getGrandTotal().toStringAsFixed(2)}",
                                    isTotal: true,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const Divider(),

                      // Pay Button with loading state
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return ElevatedButton(
                            onPressed: cartProvider.isProcessingPayment
                                ? null
                                : () {
                                    if (!cartProvider.isExpanded) {
                                      cartProvider.isExpanded = true;
                                      cartProvider.updateUI();
                                      return;
                                    }

                                    if (cartProvider.buyNowFormKey.currentState!
                                        .validate()) {
                                      cartProvider.buyNowFormKey.currentState!
                                          .save();
                                      cartProvider.submitOrder(context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(dataProvider.safeTranslate(
                                            'please_fill_all_fields',
                                            fallback:
                                                'Please fill all required fields',
                                          )),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.darkOrange,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '${dataProvider.safeTranslate('complete_order', fallback: 'Complete Order')} - Birr ${cartProvider.getGrandTotal().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      // Loading indicator for payment processing
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return cartProvider.isProcessingPayment
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 10),
                                      Text('Processing your order...'),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildPaymentOption(
  BuildContext context, {
  required String title,
  required String value,
  required bool isSelected,
  required VoidCallback onTap,
  required IconData icon,
  String? subtitle,
}) {
  return Card(
    elevation: isSelected ? 2 : 0,
    color: isSelected
        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
        : Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withOpacity(0.3),
        width: isSelected ? 2 : 1,
      ),
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
