import 'package:flutter/material.dart';

class PrivacyChipStyle {
  final String text;
  final IconData icon;
  final Color bg;
  final Color fg;

  const PrivacyChipStyle({
    required this.text,
    required this.icon,
    required this.bg,
    required this.fg,
  });
}

PrivacyChipStyle privacyChipStyle(bool isPublic) {
  if (isPublic) {
    return const PrivacyChipStyle(
      text: '공개',
      icon: Icons.public,
      bg: Color(0xFFE8F5E9),
      fg: Color(0xFF2E7D32),
    );
  }
  return const PrivacyChipStyle(
    text: '비공개',
    icon: Icons.lock_outline,
    bg: Color(0xFFFFEBEE),
    fg: Color(0xFFC62828),
  );
}

class PrivacyChip extends StatelessWidget {
  final bool isPublic;
  final double iconSize;
  final EdgeInsets padding;

  const PrivacyChip({
    super.key,
    required this.isPublic,
    this.iconSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    final st = privacyChipStyle(isPublic);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: st.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: st.fg.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(st.icon, size: iconSize, color: st.fg),
          const SizedBox(width: 6),
          Text(
            st.text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: st.fg,
            ),
          ),
        ],
      ),
    );
  }
}
