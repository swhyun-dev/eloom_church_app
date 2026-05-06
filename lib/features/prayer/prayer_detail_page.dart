import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'prayer_models.dart';

class PrayerDetailPage extends StatelessWidget {
  final PrayerItem item;

  const PrayerDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기도제목'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.black.withValues(alpha: 0.45)),
              const SizedBox(width: 8),
              Text(
                formatYmd(item.date),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: Text(
              item.content,
              style: const TextStyle(fontSize: 14.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('목록보기'),
            ),
          ),
        ],
      ),
    );
  }
}
