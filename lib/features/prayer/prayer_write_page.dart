import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'prayer_models.dart';
import '../../services/prayer_service.dart';

class PrayerWritePage extends ConsumerStatefulWidget {
  final MyPrayerItem? initial;
  const PrayerWritePage({super.key, this.initial});

  @override
  ConsumerState<PrayerWritePage> createState() => _PrayerWritePageState();
}

class _PrayerWritePageState extends ConsumerState<PrayerWritePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  bool isPublic = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final x = widget.initial;
    if (x != null) {
      _titleCtrl.text = x.title;
      _contentCtrl.text = x.content;
      isPublic = x.isPublic;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 입력해주세요.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      if (widget.initial != null) {
        final id = int.tryParse(widget.initial!.id) ?? -1;
        await PrayerService().update(
          id,
          title: title,
          content: content,
          isPublic: isPublic,
        );
      } else {
        await PrayerService().create(
          content: content,
          title: title,
          isPublic: isPublic,
        );
      }
      if (!mounted) return;
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.initial != null ? '기도제목이 수정되었습니다.' : '기도제목이 등록되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? '기도제목' : '기도제목 수정'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        children: [
          Text(
            '작성 유의 사항',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: cs.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: Text(
              '※ 개인 기도 리스트를 작성하시면 소속된 구역기본방 내의 기도 리스트가 자동 공유됩니다.\n\n'
                  '※ 구역원에게 공개를 원하지 않으시면 반드시 비공개에 체크하시기 바랍니다.\n\n'
                  '※ 공개된 기도 리스트는 구역과 본인 이외에는 절대 열람이 불가능하오니 참고하시기 바랍니다.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: Colors.black.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),

          _FieldLabel('기도제목*'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            enabled: !_busy,
            decoration: const InputDecoration(
              hintText: '',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),

          _FieldLabel('기도내용*'),
          const SizedBox(height: 6),
          TextField(
            controller: _contentCtrl,
            enabled: !_busy,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: '',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),

          _FieldLabel('공개여부*'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ChoiceButton(
                  label: '공개',
                  active: isPublic,
                  enabled: !_busy,
                  onTap: () => setState(() => isPublic = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChoiceButton(
                  label: '비공개',
                  active: !isPublic,
                  enabled: !_busy,
                  onTap: () => setState(() => isPublic = false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('작성완료'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: _busy ? null : () => context.pop(),
              child: const Text('취소'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final hasStar = text.contains('*');
    final base = text.replaceAll('*', '');

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: base),
          if (hasStar)
            TextSpan(
              text: '*',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? cs.primary : Colors.black.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: active ? cs.onPrimary : Colors.black.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}
