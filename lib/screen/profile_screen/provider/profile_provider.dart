import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utility/constants.dart';

class ProfileProvider extends ChangeNotifier {
  final GetStorage box = GetStorage();
  static const String _profileImagePathKey = 'profileImagePath';

  // Address form controllers
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // GPS coordinates from map picker
  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  String? _profileImagePath;

  String? get profileImagePath => _profileImagePath;

  ProfileProvider() {
    _loadProfileImage();
    retrieveSavedAddress();
  }

  void _loadProfileImage() {
    _profileImagePath = box.read(_profileImagePathKey);
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
        box.write(_profileImagePathKey, _profileImagePath);

        notifyListeners();
        Get.snackbar('Success', 'Profile picture updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  void clearProfileData() {
    _profileImagePath = null;
    box.remove(_profileImagePathKey);
    notifyListeners();
  }

  void storeAddress() {
    if (!addressFormKey.currentState!.validate()) {
      return;
    }

    addressFormKey.currentState!.save();

    box.write(phoneKey, phoneController.text);
    box.write(streetKey, streetController.text);
    box.write(cityKey, cityController.text);
    box.write(stateKey, stateController.text);
    box.write(postalCodeKey, postalCodeController.text);
    box.write(countryKey, countryController.text);
    // Also save GPS coordinates if available
    if (_latitude != null) box.write('LATITUDE_KEY', _latitude!);
    if (_longitude != null) box.write('LONGITUDE_KEY', _longitude!);

    Get.snackbar('Success', 'Address stored successfully');
    notifyListeners();
  }

  void retrieveSavedAddress() {
    phoneController.text = box.read(phoneKey) ?? '';
    streetController.text = box.read(streetKey) ?? '';
    cityController.text = box.read(cityKey) ?? '';
    stateController.text = box.read(stateKey) ?? '';
    postalCodeController.text = box.read(postalCodeKey) ?? '';
    countryController.text = box.read(countryKey) ?? '';
    _latitude = box.read('LATITUDE_KEY');
    _longitude = box.read('LONGITUDE_KEY');
  }

  void clearAddress() {
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();

    box.remove(phoneKey);
    box.remove(streetKey);
    box.remove(cityKey);
    box.remove(stateKey);
    box.remove(postalCodeKey);
    box.remove(countryKey);
    box.remove('LATITUDE_KEY');
    box.remove('LONGITUDE_KEY');
    _latitude = null;
    _longitude = null;

    notifyListeners();
  }

  // Set GPS coordinates from map picker
  void setCoordinates(double? lat, double? lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  // Synchronize address from CartProvider
  void syncFromCartProvider(phone, street, city, state, postalCode, country, {lat, lng}) {
    phoneController.text = phone ?? '';
    streetController.text = street ?? '';
    cityController.text = city ?? '';
    stateController.text = state ?? '';
    postalCodeController.text = postalCode ?? '';
    countryController.text = country ?? '';
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }
}
