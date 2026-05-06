import 'package:flutter/material.dart';

Future<Color?> showHighlightColorPicker(BuildContext context, {required Color initial}) async {
  final colors = <Color>[
    const Color(0xFFFFF59D), // yellow
    const Color(0xFFA5D6A7), // green
    const Color(0xFF90CAF9), // blue
    const Color(0xFFCE93D8), // purple
    const Color(0xFFFFAB91), // orange
    const Color(0xFFFFCDD2), // pink
  ];

  Color selected = initial;

  return showModalBottomSheet<Color?>(
    context: context,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('형광펜 색상 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((c) {
                final isSel = c.toARGB32() == selected.toARGB32();
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    selected = c;
                    Navigator.pop(ctx, selected);
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: isSel ? 3 : 1,
                        color: isSel ? Colors.black87 : Colors.black26,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            const Text('선택한 색상은 이후 메모 저장 시 함께 기록됩니다.'),
          ],
        ),
      );
    },
  );
}
