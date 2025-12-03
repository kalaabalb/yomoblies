import 'package:flutter/material.dart';

import '../../../shared/widgets/loading_states.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Empty Cart',
      subtitle: 'Your cart is empty',
      icon: Icons.shopping_cart_outlined,
    );
  }
}
