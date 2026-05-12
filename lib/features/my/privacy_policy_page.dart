import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/async_value_builder.dart';
import '../policy/domain/models/privacy_policy.dart';
import '../policy/presentation/providers/privacy_policy_providers.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  static const _fallback =
      '개인정보처리방침을 일시적으로 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(privacyPolicyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: AsyncValueBuilder<PrivacyPolicy?>(
        value: async,
        onRetry: () => ref.invalidate(privacyPolicyProvider),
        builder: (policy) {
          final body = policy?.body ?? _fallback;
          final version = policy?.version ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (version.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '버전: $version',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                Text(body, style: const TextStyle(height: 1.6)),
              ],
            ),
          );
        },
      ),
    );
  }
}
