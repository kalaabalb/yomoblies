import 'dart:io';

import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/main.dart';
import 'package:e_commerce_flutter/screen/login_screen/login_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/screen/product_by_category_screen/provider/product_by_category_provider.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/provider/product_detail_provider.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/provider/rating_provider.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final storageDir = await Directory.systemTemp.createTemp(
          'get_storage',
        );
        return storageDir.path;
      }
      return null;
    });

    await GetStorage.init();
  });

  testWidgets('app boots to the login screen when no user is stored',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => ProductListProvider()),
          ChangeNotifierProvider(create: (_) => ProductByCategoryProvider()),
          ChangeNotifierProvider(create: (_) => ProductDetailProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => RatingProvider()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
