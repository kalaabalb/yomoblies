import 'package:flutter/material.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import '../utility/app_color.dart';

class UniversalSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final VoidCallback? onClear;

  const UniversalSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.hintText,
    this.onClear,
  });

  @override
  State<UniversalSearchBar> createState() => _UniversalSearchBarState();
}

class _UniversalSearchBarState extends State<UniversalSearchBar> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          hintText: widget.hintText ??
              context.safeDataProvider.safeTranslate(
                'search_hint',
                fallback: 'Search...',
              ),
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.search,
              color: AppColor.darkOrange,
              size: 20,
            ),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                    _focusNode.requestFocus();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
