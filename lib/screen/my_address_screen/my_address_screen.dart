import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/forms.dart';
import '../profile_screen/provider/profile_provider.dart';
import '../product_cart_screen/provider/cart_provider.dart';

class MyAddressPage extends StatelessWidget {
  const MyAddressPage({super.key});

  Future<void> _showMapPicker(BuildContext context) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    LatLng? selectedLocation;
    
    // Use existing coordinates if available
    final initialLocation =
        profileProvider.latitude != null && profileProvider.longitude != null
            ? LatLng(profileProvider.latitude!, profileProvider.longitude!)
            : const LatLng(9.0108, 38.7612); // Addis Ababa center

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Delivery Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                ),
                // Map
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: initialLocation,
                        zoom: 14,
                      ),
                      onTap: (latLng) {
                        selectedLocation = latLng;
                      },
                      markers: selectedLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('selected-location'),
                                position: selectedLocation!,
                                infoWindow: const InfoWindow(
                                  title: 'Delivery Location',
                                ),
                              ),
                            }
                          : {},
                    ),
                  ),
                ),
                // Footer with Confirm button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: selectedLocation == null
                              ? null
                              : () async {
                                  // Reverse geocode the selected location
                                  try {
                                    final placemarks =
                                        await placemarkFromCoordinates(
                                      selectedLocation!.latitude,
                                      selectedLocation!.longitude,
                                    );

                                    if (placemarks.isNotEmpty) {
                                      final placemark = placemarks.first;
                                      profileProvider.streetController.text =
                                          placemark.street?.isNotEmpty == true
                                              ? placemark.street!
                                              : placemark.thoroughfare ?? '';
                                      profileProvider.cityController.text =
                                          placemark.locality ??
                                              placemark.subAdministrativeArea ??
                                              '';
                                      profileProvider.stateController.text =
                                          placemark.administrativeArea ?? '';
                                      profileProvider.postalCodeController
                                          .text = placemark.postalCode ?? '';
                                      profileProvider.countryController.text =
                                          placemark.country ?? '';
                                    }

                                    // Save GPS coordinates to ProfileProvider
                                    profileProvider.setCoordinates(
                                      selectedLocation!.latitude,
                                      selectedLocation!.longitude,
                                    );

                                    // Also sync with CartProvider
                                    cartProvider.setCoordinates(
                                      selectedLocation!.latitude,
                                      selectedLocation!.longitude,
                                    );
                                    cartProvider.streetController.text =
                                        profileProvider.streetController.text;
                                    cartProvider.cityController.text =
                                        profileProvider.cityController.text;
                                    cartProvider.stateController.text =
                                        profileProvider.stateController.text;
                                    cartProvider.postalCodeController.text =
                                        profileProvider.postalCodeController.text;
                                    cartProvider.countryController.text =
                                        profileProvider.countryController.text;

                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                  } catch (e) {
                                    // Even if geocoding fails, still save coordinates
                                    profileProvider.setCoordinates(
                                      selectedLocation!.latitude,
                                      selectedLocation!.longitude,
                                    );
                                    cartProvider.setCoordinates(
                                      selectedLocation!.latitude,
                                      selectedLocation!.longitude,
                                    );
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                  }
                                },
                          icon: const Icon(Icons.check),
                          label: const Text('Confirm Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.darkOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.profileProvider;
    final cartProvider = context.read<CartProvider>();
    profileProvider.retrieveSavedAddress();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          context.dataProvider.translate('my_address'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkOrange,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: profileProvider.addressFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FormSection(
                  title: context.dataProvider.translate('update_address'),
                  children: [
                    AddressFormFields(
                      phoneController: profileProvider.phoneController,
                      streetController: profileProvider.streetController,
                      cityController: profileProvider.cityController,
                      stateController: profileProvider.stateController,
                      postalCodeController:
                          profileProvider.postalCodeController,
                      countryController: profileProvider.countryController,
                      onMapPick: () => _showMapPicker(context),
                      validator: (value) =>
                          value!.isEmpty ? 'This field is required' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: PrimaryButton(
                    text: context.dataProvider.translate('update_address'),
                    onPressed: () {
                      if (profileProvider.addressFormKey.currentState!
                          .validate()) {
                        profileProvider.storeAddress();
                        // Sync with CartProvider
                        cartProvider.phoneController.text =
                            profileProvider.phoneController.text;
                        cartProvider.streetController.text =
                            profileProvider.streetController.text;
                        cartProvider.cityController.text =
                            profileProvider.cityController.text;
                        cartProvider.stateController.text =
                            profileProvider.stateController.text;
                        cartProvider.postalCodeController.text =
                            profileProvider.postalCodeController.text;
                        cartProvider.countryController.text =
                            profileProvider.countryController.text;
                        // Sync coordinates
                        cartProvider.setCoordinates(
                          profileProvider.latitude,
                          profileProvider.longitude,
                        );
                      }
                    },
                    width: 200,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
