import '../../utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../utility/app_color.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/forms.dart';

class MyAddressPage extends StatelessWidget {
  const MyAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.profileProvider;
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
