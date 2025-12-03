import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColor.darkOrange : Colors.black,
          ),
        ),
      ],
    );
  }
}
