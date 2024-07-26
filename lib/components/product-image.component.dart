import 'package:carousel_slider/carousel_slider.dart';
import 'package:cstyle_cashier_3/model/model.product-image.model.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductImageComponent extends StatefulWidget {
  final String id;
  bool autoPlay;
  bool bordered;

  ProductImageComponent({
    super.key,
    required this.id,
    required this.autoPlay,
    required this.bordered,
  });

  @override
  State<ProductImageComponent> createState() => _ProductImageComponentState();
}

class _ProductImageComponentState extends State<ProductImageComponent> {
  bool isLoading = true;
  List<ProductImageModel> images = [];

  _fetchProductImages() async {
    var fetchedImages = await ProductImageModel.fetchByItemID(widget.id);
    setState(() {
      images = fetchedImages;
      isLoading = false;
    });
  }

  @override
  void initState() {
    _fetchProductImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Border radius
        borderRadius: BorderRadius.circular(0),
        // Border 1px solid
        border: Border.all(
          color: widget.bordered ? Colors.grey.shade300 : Colors.transparent,
          width: 1,
        ),
      ),
      height: 200,
      width: 200,
      padding: const EdgeInsets.all(5),
      child: isLoading
          ? const CircularProgressIndicator()
          : images.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    "assets/images/lost.png",
                    opacity: const AlwaysStoppedAnimation(0.5),
                  ),
                )
              : CarouselSlider(
                  items: images.map((x) {
                    return FastCachedImage(
                      url: x.imageUrl,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    autoPlay: widget.autoPlay,
                    aspectRatio: 1,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    viewportFraction: 1.0,
                    initialPage: 0,
                  ),
                ),
    );
  }
}
