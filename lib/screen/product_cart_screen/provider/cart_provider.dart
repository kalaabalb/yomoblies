import 'dart:io';
import 'dart:convert';
import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../login_screen/provider/user_provider.dart';
import '../../profile_screen/provider/profile_provider.dart';
import '../../../services/http_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/api_response.dart';
import '../../../utility/snack_bar_helper.dart';
import '../../../utility/constants.dart';

class CartProvider extends ChangeNotifier {
  final HttpService service = HttpService();
  final box = GetStorage();
  final FlutterCart flutterCart = FlutterCart();
  List<CartModel> myCartItems = [];

  // Use shared storage keys for address synchronization with ProfileProvider
  static const String _savedAddressKey = 'savedAddress';
  static const String _defaultPaymentOption = 'cod';

  final GlobalKey<FormState> buyNowFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  bool isExpanded = false;

  // GPS coordinates from map picker
  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  String selectedPaymentOption = _defaultPaymentOption;

  File? _paymentProofImage;
  File? get paymentProofImage => _paymentProofImage;
  bool _isUploadingPaymentProof = false;
  bool get isUploadingPaymentProof => _isUploadingPaymentProof;
  String? _paymentProofUrl;
  String? get paymentProofUrl => _paymentProofUrl;

  bool _showPaymentInstructions = false;
  bool get showPaymentInstructions => _showPaymentInstructions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isProcessingPayment = false;
  bool get isProcessingPayment => _isProcessingPayment;

  CartProvider() {
    getCartItems();
    retrieveSavedAddress();
  }

  void getCartItems() {
    try {
      myCartItems = List<CartModel>.from(flutterCart.cartItemsList);

      notifyListeners();
    } catch (e) {
      myCartItems = [];
      notifyListeners();
    }
  }

  void updateUI() => notifyListeners();

  void addToCart({
    required String productId,
    required String productName,
    required double price,
    required List<String> productImages,
    List<ProductVariant>? variants,
    int quantity = 1,
  }) {
    try {
      final cartVariants =
          variants ?? [ProductVariant(price: price, color: null, size: null)];

      bool itemExists = myCartItems.any(
        (item) =>
            item.productId == productId &&
            _areVariantsEqual(item.variants, cartVariants),
      );

      if (itemExists) {
        var existingItem = myCartItems.firstWhere(
          (item) =>
              item.productId == productId &&
              _areVariantsEqual(item.variants, cartVariants),
        );

        flutterCart.updateQuantity(
          productId,
          cartVariants,
          existingItem.quantity + 1,
        );
      } else {
        CartModel newItem = CartModel(
          productId: productId,
          productName: productName,
          productDetails: productName,
          productImages: productImages,
          variants: cartVariants,
          quantity: quantity,
        );

        flutterCart.addToCart(cartModel: newItem);
      }

      getCartItems();
      SnackBarHelper.showSuccessSnackBar('Item added to cart');
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Failed to add item to cart');
    }
  }

  void updateCart(CartModel cartItem, int quantity) {
    try {
      int newQuantity = cartItem.quantity + quantity;

      if (newQuantity <= 0) {
        flutterCart.removeItem(cartItem.productId, cartItem.variants);
        SnackBarHelper.showSuccessSnackBar('Item removed from cart');
      } else {
        flutterCart.updateQuantity(
          cartItem.productId,
          cartItem.variants,
          newQuantity,
        );
      }

      getCartItems();
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Failed to update cart');
    }
  }

  bool _areVariantsEqual(List<ProductVariant>? v1, List<ProductVariant>? v2) {
    if (v1 == null && v2 == null) return true;
    if (v1 == null || v2 == null) return false;
    if (v1.length != v2.length) return false;

    for (int i = 0; i < v1.length; i++) {
      if (v1[i].color != v2[i].color || v1[i].price != v2[i].price) {
        return false;
      }
    }
    return true;
  }

  double getCartSubTotal() {
    return flutterCart.subtotal;
  }

  void clearCartItems() {
    flutterCart.clearCart();
    getCartItems();
    SnackBarHelper.showSuccessSnackBar('Cart cleared');
  }

  double getGrandTotal() {
    final grandTotal = getCartSubTotal();
    return grandTotal > 0 ? grandTotal : 0;
  }

  Future<void> pickPaymentProofImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        _paymentProofImage = File(image.path);
        _paymentProofUrl = null;
        notifyListeners();
        SnackBarHelper.showSuccessSnackBar('Payment proof image selected');

        await uploadPaymentProof();
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Failed to select image: $e');
    }
  }

  void removePaymentProofImage() {
    _paymentProofImage = null;
    _paymentProofUrl = null;

    notifyListeners();
    SnackBarHelper.showSuccessSnackBar('Payment proof removed');
  }

  Future<bool> uploadPaymentProof() async {
    if (_paymentProofImage == null) {
      SnackBarHelper.showErrorSnackBar('Please select a payment proof image');
      return false;
    }

    try {
      _isUploadingPaymentProof = true;
      notifyListeners();

      List<int> imageBytes = await _paymentProofImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String fileName =
          'payment_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Map<String, dynamic> uploadData = {
        'image': base64Image,
        'fileName': fileName,
        'orderAmount': getGrandTotal(),
      };

      final response = await service.addItem(
        endpointUrl: 'payment/upload-proof-base64',
        itemData: uploadData,
      );

      if (response.isOk && response.body != null) {
        final responseMap = response.body as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          final dataMap = responseMap['data'] as Map<String, dynamic>;
          final imageUrl = dataMap['imageUrl']?.toString();

          if (imageUrl != null && imageUrl.isNotEmpty) {
            _paymentProofUrl = imageUrl;

            notifyListeners();
            return true;
          }
        }
      }

      SnackBarHelper.showErrorSnackBar('Upload failed: Invalid response');
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Upload failed: $e');
      return false;
    } finally {
      _isUploadingPaymentProof = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(BuildContext context) async {
    try {
      _isProcessingPayment = true;
      notifyListeners();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.getLoginUsr();

      if (user == null) {
        SnackBarHelper.showErrorSnackBar('Please login to place order');
        return;
      }

      // Step A: Cache the final total amount BEFORE clearing any states
      final double finalAmount = getGrandTotal();
      final double finalSubtotal = getCartSubTotal();

      final bool isCashOnDelivery = selectedPaymentOption == 'cod';
      final String orderStatus =
          isCashOnDelivery ? 'pending' : 'payment_pending';
      const String paymentStatus = 'pending';

      Map<String, dynamic> order = {
        'userID': user.sId ?? '',
        'orderStatus': orderStatus,
        'items': cartItemToOrderItem(myCartItems),
        'totalPrice': finalAmount,
        'shippingAddress': {
          'phone': phoneController.text,
          'street': streetController.text,
          'city': cityController.text,
          'state': stateController.text,
          'postalCode': postalCodeController.text,
          'country': countryController.text,
          'latitude': _latitude,
          'longitude': _longitude,
        },
        'paymentMethod': selectedPaymentOption,
        'paymentStatus': paymentStatus,
        'paymentProof': _paymentProofUrl != null
            ? {
                'imageUrl': _paymentProofUrl,
                'uploadedAt': DateTime.now().toIso8601String(),
                'verified': false,
              }
            : null,
        'orderTotal': {
          "subtotal": finalSubtotal,
          "total": finalAmount,
        },
      };

      // Step B: Process the network request to submit the order
      final response = await service.addItem(
        endpointUrl: 'orders',
        itemData: order,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Order created successfully!');
          saveAddress();
          // Synchronize address with ProfileProvider
          _syncAddressWithProfileProvider(context);
          clearCartItems();
          _paymentProofImage = null;
          _paymentProofUrl = null;

          if (context.mounted) {
            Navigator.of(context).pop();
          }

          // Step C: Pass the cached finalAmount explicitly to the dialog
          Future.delayed(const Duration(milliseconds: 500), () {
            _showOrderConfirmation(context, finalAmount: finalAmount);
          });
        } else {
          SnackBarHelper.showErrorSnackBar(
            'Failed to create order: ${apiResponse.message}',
          );
        }
      } else {
        debugPrint(
            'ADD ORDER HTTP Error: ${response.statusCode} - ${response.body}');
        SnackBarHelper.showErrorSnackBar(
          'Failed to create order: ${response.statusText}',
        );
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('Error creating order: $e');
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  // Synchronize address with ProfileProvider so both screens stay in sync
  void _syncAddressWithProfileProvider(BuildContext context) {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.phoneController.text = phoneController.text;
      profileProvider.streetController.text = streetController.text;
      profileProvider.cityController.text = cityController.text;
      profileProvider.stateController.text = stateController.text;
      profileProvider.postalCodeController.text = postalCodeController.text;
      profileProvider.countryController.text = countryController.text;
      // Persist to shared storage
      profileProvider.storeAddress();
    } catch (e) {
      debugPrint('Failed to sync address with ProfileProvider: $e');
    }
  }

  void _showOrderConfirmation(BuildContext context,
      {required double finalAmount}) {
    Get.dialog(
      AlertDialog(
        title: const Text('🎉 Order Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Payment Method: ${_getPaymentMethodDisplayName(selectedPaymentOption)}'),
            Text('Total Amount: Birr ${finalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            if (selectedPaymentOption != 'cod')
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Payment proof submitted for verification.'),
                  Text(
                      'Your order will be processed once payment is verified.'),
                  Text('You can track the status in "My Orders" section.'),
                ],
              ),
            if (selectedPaymentOption == 'cod')
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💰 Cash on Delivery order placed successfully.'),
                  Text('Pay when you receive your order.'),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // Completely reset navigation stack to home dashboard
              Get.offAllNamed('/');
            },
            child: const Text('🛍️ Continue Shopping'),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodDisplayName(String method) {
    switch (method) {
      case 'cod':
        return '💰 Cash on Delivery';
      case 'cbe':
        return '🏦 Commercial Bank of Ethiopia';
      case 'telebirr':
        return '📱 Telebirr';
      default:
        return method;
    }
  }

  void submitOrder(BuildContext context) async {
    if (!buyNowFormKey.currentState!.validate()) {
      SnackBarHelper.showErrorSnackBar('Please fill all required fields');
      return;
    }

    buyNowFormKey.currentState!.save();

    if (isExpanded) {
      if (phoneController.text.isEmpty ||
          streetController.text.isEmpty ||
          cityController.text.isEmpty ||
          stateController.text.isEmpty ||
          countryController.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar('Please fill all address fields');
        return;
      }
    }

    if (selectedPaymentOption == 'cbe') {
      final result = await _showCBEPaymentInstructions(context);
      if (result == true) {
        await addOrder(context);
      }
    } else if (selectedPaymentOption == 'telebirr') {
      final result = await _showTelebirrPaymentInstructions(context);
      if (result == true) {
        await addOrder(context);
      }
    } else {
      await addOrder(context);
    }
  }

  Future<bool?> _showCBEPaymentInstructions(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('🏦 Commercial Bank of Ethiopia Payment'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Please complete your payment using one of the methods below and upload the transaction proof:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    _buildPaymentInstructionCard(
                      icon: Icons.phone_android,
                      title: 'CBE Birr App',
                      instructions: [
                        '1. Open CBE Birr App',
                        '2. Go to "Payments" or "Send Money"',
                        '3. Scan QR code or enter merchant details',
                        '4. Amount: Birr ${getGrandTotal().toStringAsFixed(2)}',
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentInstructionCard(
                      icon: Icons.account_balance,
                      title: 'Bank Transfer',
                      instructions: [
                        'Account Name: YONAS AMBELU',
                        'Account Number: 1000402270202',
                        'Bank: Commercial Bank of Ethiopia',
                        'Reference: ORDER-${DateTime.now().millisecondsSinceEpoch}',
                        'Amount: Birr ${getGrandTotal().toStringAsFixed(2)}',
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildPaymentProofUploadSection(),
                    const SizedBox(height: 10),
                    const Text(
                      '💡 After payment, upload the screenshot and click "Confirm Payment".',
                      style:
                          TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  child: const Text('Cancel'),
                ),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final isReady = cartProvider.isPaymentProofReady;

                    return TextButton(
                      onPressed: isReady
                          ? () {
                              Get.back(result: true);
                            }
                          : null,
                      child: const Text('Confirm Payment'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showTelebirrPaymentInstructions(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('📱 Telebirr Payment'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Please complete your payment using Telebirr and upload the transaction proof:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    _buildPaymentInstructionCard(
                      icon: Icons.phone_android,
                      title: 'Telebirr App',
                      instructions: [
                        '1. Open Telebirr App',
                        '2. Go to "Send Money" or "Payments"',
                        '3. Enter merchant number: +251922737271',
                        '4. Amount: Birr ${getGrandTotal().toStringAsFixed(2)}',
                        '5. Use reference: ORDER-${DateTime.now().millisecondsSinceEpoch}',
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildPaymentProofUploadSection(),
                    const SizedBox(height: 10),
                    const Text(
                      '💡 After payment, upload the screenshot and click "Confirm Payment".',
                      style:
                          TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(result: false);
                  },
                  child: const Text('Cancel'),
                ),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final isReady = cartProvider.isPaymentProofReady;
                    return TextButton(
                      onPressed: isReady
                          ? () {
                              Get.back(result: true);
                            }
                          : null,
                      child: const Text('Confirm Payment'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentInstructionCard({
    required IconData icon,
    required String title,
    required List<String> instructions,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColor.darkOrange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...instructions
                .map((instruction) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        instruction,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProofUploadSection() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final hasProof = cartProvider.paymentProofImage != null ||
            (cartProvider.paymentProofUrl != null &&
                cartProvider.paymentProofUrl!.isNotEmpty);

        return Column(
          children: [
            const Text(
              '📸 Upload Payment Proof',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasProof ? Colors.green : Colors.grey,
                  width: hasProof ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: cartProvider.buildProofPreview(),
            ),
            const SizedBox(height: 10),
            if (hasProof)
              const Text(
                '✓ Proof uploaded successfully',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (cartProvider.isUploadingPaymentProof)
              const Text(
                'Uploading...',
                style: TextStyle(color: Colors.orange),
              )
            else
              const Text(
                'No proof uploaded yet',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: cartProvider.isUploadingPaymentProof
                      ? null
                      : () => cartProvider.pickPaymentProofImage(),
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Proof'),
                ),
                if (hasProof)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      onPressed: cartProvider.isUploadingPaymentProof
                          ? null
                          : () => cartProvider.removePaymentProofImage(),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildProofPreview() {
    if (_paymentProofImage != null) {
      return Image.file(
        _paymentProofImage!,
        fit: BoxFit.cover,
      );
    } else if (_paymentProofUrl != null && _paymentProofUrl!.isNotEmpty) {
      return Image.network(
        _paymentProofUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No proof uploaded',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  bool get isPaymentProofReady {
    final hasValidUrl =
        _paymentProofUrl != null && _paymentProofUrl!.isNotEmpty;
    final hasImage = _paymentProofImage != null;

    return hasValidUrl || hasImage;
  }

  void setCoordinates(double? lat, double? lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void retrieveSavedAddress() {
    try {
      // First try to load from ProfileProvider's shared keys
      phoneController.text = box.read(PHONE_KEY) ?? '';
      streetController.text = box.read(STREET_KEY) ?? '';
      cityController.text = box.read(CITY_KEY) ?? '';
      stateController.text = box.read(STATE_KEY) ?? '';
      postalCodeController.text = box.read(POSTAL_CODE_KEY) ?? '';
      countryController.text = box.read(COUNTRY_KEY) ?? '';
      
      // Fallback to legacy saved address if shared keys are empty
      if (phoneController.text.isEmpty && 
          streetController.text.isEmpty && 
          cityController.text.isEmpty) {
        final savedAddress = box.read(_savedAddressKey);
        if (savedAddress != null) {
          phoneController.text = savedAddress['phone'] ?? '';
          streetController.text = savedAddress['street'] ?? '';
          cityController.text = savedAddress['city'] ?? '';
          stateController.text = savedAddress['state'] ?? '';
          postalCodeController.text = savedAddress['postalCode'] ?? '';
          countryController.text = savedAddress['country'] ?? '';
        }
      }
    } catch (e) {}
  }

  void saveAddress() {
    try {
      // Save to both legacy key and shared ProfileProvider keys
      final address = {
        'phone': phoneController.text,
        'street': streetController.text,
        'city': cityController.text,
        'state': stateController.text,
        'postalCode': postalCodeController.text,
        'country': countryController.text,
      };
      box.write(_savedAddressKey, address);
      
      // Also save to shared keys for ProfileProvider synchronization
      box.write(PHONE_KEY, phoneController.text);
      box.write(STREET_KEY, streetController.text);
      box.write(CITY_KEY, cityController.text);
      box.write(STATE_KEY, stateController.text);
      box.write(POSTAL_CODE_KEY, postalCodeController.text);
      box.write(COUNTRY_KEY, countryController.text);
    } catch (e) {}
  }

  // New method to sync address from ProfileProvider (call when Profile updates)
  void syncFromProfileProvider(ProfileProvider profileProvider) {
    phoneController.text = profileProvider.phoneController.text;
    streetController.text = profileProvider.streetController.text;
    cityController.text = profileProvider.cityController.text;
    stateController.text = profileProvider.stateController.text;
    postalCodeController.text = profileProvider.postalCodeController.text;
    countryController.text = profileProvider.countryController.text;
    notifyListeners();
  }

  void togglePaymentInstructions() {
    _showPaymentInstructions = !_showPaymentInstructions;
    notifyListeners();
  }

  void setPaymentOption(String option) {
    selectedPaymentOption = option;
    notifyListeners();
  }

  void toggleExpansion() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  void clearForm() {
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();
    _paymentProofImage = null;
    _paymentProofUrl = null;
    selectedPaymentOption = _defaultPaymentOption;
    isExpanded = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> cartItemToOrderItem(List<CartModel> cartItems) {
    return cartItems.map((cartItem) {
      return {
        'productID': cartItem.productId,
        'productName': cartItem.productName,
        'quantity': cartItem.quantity,
        'price': cartItem.variants.first.price,
        'variant': cartItem.variants.first.color ?? 'Default',
      };
    }).toList();
  }

  @override
  void dispose() {
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
