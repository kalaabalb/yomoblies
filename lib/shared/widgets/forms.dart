import 'package:flutter/material.dart';
import '../../utility/app_color.dart';
import '../../widget/custom_text_field.dart';
import 'cards.dart';

class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange,
            ),
          ),
        ),
        CustomCard(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class AddressFormFields extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;
  final String? Function(String?)? validator;

  const AddressFormFields({
    super.key,
    required this.phoneController,
    required this.streetController,
    required this.cityController,
    required this.stateController,
    required this.postalCodeController,
    required this.countryController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: phoneController,
          labelText: 'Phone',
          inputType: TextInputType.phone,
          validator: validator ??
              (value) => value!.isEmpty ? 'Please enter phone' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: streetController,
          labelText: 'Street',
          validator: validator ??
              (value) => value!.isEmpty ? 'Please enter street' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: cityController,
          labelText: 'City',
          validator: validator ??
              (value) => value!.isEmpty ? 'Please enter city' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: stateController,
          labelText: 'State',
          validator: validator ??
              (value) => value!.isEmpty ? 'Please enter state' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: postalCodeController,
                labelText: 'Postal Code',
                inputType: TextInputType.number,
                validator: validator ??
                    (value) =>
                        value!.isEmpty ? 'Please enter postal code' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: countryController,
                labelText: 'Country',
                validator: validator ??
                    (value) => value!.isEmpty ? 'Please enter country' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
