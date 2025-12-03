import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utility/app_color.dart';
import '../models/product.dart';
import '../utility/utility_extention.dart';
import 'custom_network_image.dart';

class CarouselSlider extends StatefulWidget {
  const CarouselSlider({
    super.key,
    required this.items,
  });

  final List<Images> items;

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  int newIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300, // Fixed height for consistency
          child: PageView.builder(
            itemCount: widget.items.length,
            onPageChanged: (int currentIndex) {
              setState(() {
                newIndex = currentIndex;
              });
            },
            itemBuilder: (_, index) {
              return Container(
                margin: const EdgeInsets.all(20),
                child: CustomNetworkImage(
                  imageUrl: widget.items.safeElementAt(index)?.url ?? '',
                  fit: BoxFit
                      .contain, // Changed to contain for consistent sizing
                  width: double.infinity,
                  height: 300,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          effect: const WormEffect(
            dotColor: Colors.white,
            activeDotColor: AppColor.darkOrange,
          ),
          count: widget.items.length,
          activeIndex: newIndex,
        )
      ],
    );
  }
}
