import 'package:flutter/material.dart';
import '../utility/app_color.dart';

class NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const NavigationTile({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Theme.of(context).cardColor, // Use theme card color
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.darkOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}