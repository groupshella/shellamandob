import 'package:flutter/material.dart';
import 'package:sixam_mart/util/images.dart';

class SarCurrencyWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const SarCurrencyWidget({
    super.key,
    this.size = 15,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Images.sar,
      width: size,
      height: size,
      color: color,
      cacheWidth: 48,
      cacheHeight: 48,
    );
  }
}
