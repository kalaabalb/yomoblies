import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utility/constants.dart';

class ProfileProvider extends ChangeNotifier {
  final GetStorage box = GetStorage();

  // Address form controllers
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String? _profileImagePath;

  String? get profileImagePath => _profileImagePath;

  ProfileProvider() {
    _loadProfileImage();
    retrieveSavedAddress();
  }

  void _loadProfileImage() {
    _profileImagePath = box.read('profileImagePath');
  }

  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String savePath = '${appDir.path}/$fileName';

        final File savedImage = File(image.path).copySync(savePath);
        _profileImagePath = savedImage.path;
        box.write('profileImagePath', _profileImagePath);

        notifyListeners();
        Get.snackbar('Success', 'Profile picture updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  void clearProfileData() {
    box.remove('profileImagePath');
    notifyListeners();
  }

  // FIXED: Address management methods
  void storeAddress() {
    // Validate the form first
    if (!addressFormKey.currentState!.validate()) {
      return;
    }

    addressFormKey.currentState!.save();

    box.write(PHONE_KEY, phoneController.text);
    box.write(STREET_KEY, streetController.text);
    box.write(CITY_KEY, cityController.text);
    box.write(STATE_KEY, stateController.text);
    box.write(POSTAL_CODE_KEY, postalCodeController.text);
    box.write(COUNTRY_KEY, countryController.text);

    Get.snackbar('Success', 'Address stored successfully');
    notifyListeners();
  }

  void retrieveSavedAddress() {
    phoneController.text = box.read(PHONE_KEY) ?? '';
    streetController.text = box.read(STREET_KEY) ?? '';
    cityController.text = box.read(CITY_KEY) ?? '';
    stateController.text = box.read(STATE_KEY) ?? '';
    postalCodeController.text = box.read(POSTAL_CODE_KEY) ?? '';
    countryController.text = box.read(COUNTRY_KEY) ?? '';
  }

  void clearAddress() {
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();

    box.remove(PHONE_KEY);
    box.remove(STREET_KEY);
    box.remove(CITY_KEY);
    box.remove(STATE_KEY);
    box.remove(POSTAL_CODE_KEY);
    box.remove(COUNTRY_KEY);

    notifyListeners();
  }
}
