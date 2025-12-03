import 'package:flutter/cupertino.dart';
import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';

class ProductByCategoryProvider extends ChangeNotifier {
  Category? mySelectedCategory;
  SubCategory? mySelectedSubCategory;
  List<SubCategory> subCategories = [];
  List<Brand> brands = [];
  List<Brand> selectedBrands = [];
  List<Product> filteredProduct = [];
  List<Product> originalProducts = []; // Store original products for filtering

  filterInitialProductAndSubCategory(
    Category selectedCategory,
    List<Product> allProducts,
    List<SubCategory> allSubCategories,
    List<Brand> allBrands,
  ) {
    mySelectedSubCategory = SubCategory(name: 'All');
    mySelectedCategory = selectedCategory;
    subCategories = allSubCategories
        .where((element) => element.categoryId?.sId == selectedCategory.sId)
        .toList();
    subCategories.insert(0, SubCategory(name: 'All'));

    // Store original products
    originalProducts = allProducts
        .where(
          (element) => element.proCategoryId?.name == selectedCategory.name,
        )
        .toList();

    filteredProduct = List.from(originalProducts);

    // Get brands for this category
    brands = allBrands
        .where(
          (element) => element.subcategoryId?.name == selectedCategory.name,
        )
        .toList();

    notifyListeners();
  }

  filterProductBySubCategory(
    SubCategory subCategory,
    List<Product> allProducts,
    List<Brand> allBrands,
  ) {
    mySelectedSubCategory = subCategory;
    if (subCategory.name?.toLowerCase() == 'all') {
      filteredProduct = List.from(originalProducts);
      brands = allBrands
          .where((element) =>
              element.subcategoryId?.name == mySelectedCategory?.name)
          .toList();
    } else {
      filteredProduct = originalProducts
          .where(
            (element) => element.proSubCategoryId?.name == subCategory.name,
          )
          .toList();
      brands = allBrands
          .where((element) => element.subcategoryId?.name == subCategory.name)
          .toList();
    }

    // Apply brand filter if any brands are selected
    if (selectedBrands.isNotEmpty) {
      filterProductByBrand(originalProducts);
    }

    notifyListeners();
  }

  void filterProductByBrand(List<Product> allProducts) {
    if (selectedBrands.isEmpty) {
      // If no brands selected, show all products for current subcategory
      if (mySelectedSubCategory?.name?.toLowerCase() == 'all') {
        filteredProduct = List.from(originalProducts);
      } else {
        filteredProduct = originalProducts
            .where(
              (product) =>
                  product.proSubCategoryId?.name == mySelectedSubCategory?.name,
            )
            .toList();
      }
    } else {
      filteredProduct = originalProducts
          .where(
            (product) =>
                (mySelectedSubCategory?.name?.toLowerCase() == 'all' ||
                    product.proSubCategoryId?.name ==
                        mySelectedSubCategory?.name) &&
                selectedBrands.any(
                  (brand) => product.proBrandId?.sId == brand.sId,
                ),
          )
          .toList();
    }

    notifyListeners();
  }

  void sortProducts({required bool ascending}) {
    filteredProduct.sort((a, b) {
      final priceA = a.offerPrice ?? a.price ?? 0;
      final priceB = b.offerPrice ?? b.price ?? 0;

      if (ascending) {
        return priceA.compareTo(priceB);
      } else {
        return priceB.compareTo(priceA);
      }
    });
    notifyListeners();
  }

  void updateUI() {
    notifyListeners();
  }
}
