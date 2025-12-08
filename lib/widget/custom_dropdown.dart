// widgets/custom_dropdown.dart
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String hintText;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T) displayItem;
  final TextStyle? hintStyle;
  final TextStyle? itemStyle;
  final Color? dropdownColor;

  const CustomDropdown({
    super.key,
    required this.hintText,
    required this.items,
    this.value,
    this.onChanged,
    required this.displayItem,
    this.hintStyle,
    this.itemStyle,
    this.dropdownColor,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: widget.value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.hintText,
              style: widget.hintStyle ??
                  TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
          ),
          isExpanded: true,
          items: widget.items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.displayItem(item),
                  style: widget.itemStyle ??
                      TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                ),
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
          dropdownColor: widget.dropdownColor ??
              (isDarkMode ? Colors.grey[900] : Colors.white),
          icon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.arrow_drop_down,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
