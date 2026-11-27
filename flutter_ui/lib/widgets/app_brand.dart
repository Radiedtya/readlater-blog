import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBrand extends StatelessWidget {
  const AppBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.bookmark_added,
          color: Color(0xFFD87A59),
          size: 28,
        ),
        const SizedBox(width: 8),
        Text(
          'ReadLater',
          style: GoogleFonts.fraunces(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}
