import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.radius = 22,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final avatar = ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: imageUrl == null
            ? _fallback()
            : Image.network(
                imageUrl!,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(),
              ),
      ),
    );

    if (onTap == null) return avatar;
    return Semantics(
      button: true,
      label: 'Ganti foto profil',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(2), child: avatar),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: const Color(0xFFE9E2D6),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: TextStyle(
            color: const Color(0xFF554B3F),
            fontSize: radius * 0.72,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
