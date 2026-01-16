import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  
  const AppLogo({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/app_icon.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon if asset not found
        return Icon(
          Icons.menu_book,
          size: size,
          color: const Color(0xFF2D5A27), // deepSageGreen
        );
      },
    );
  }
}
