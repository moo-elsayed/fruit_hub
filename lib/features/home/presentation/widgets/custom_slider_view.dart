import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'custom_slider_item.dart';

class CustomSliderView extends StatelessWidget {
  const CustomSliderView({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (context, index, realIndex) => const CustomSliderItem(),
      options: CarouselOptions(
        viewportFraction: 0.912,
        aspectRatio: 342 / 158,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        // autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
