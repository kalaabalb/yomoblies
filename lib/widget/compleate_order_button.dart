import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../shared/widgets/buttons.dart';

class CompleteOrderButton extends StatelessWidget {
  final String? labelText;
  final Function()? onPressed;

  const CompleteOrderButton({super.key, this.onPressed, this.labelText});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: labelText ?? context.dataProvider.translate('complete_order'),
      onPressed: onPressed,
    );
  }
}
