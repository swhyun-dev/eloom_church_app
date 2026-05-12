// donation_receipt_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/donation_receipt_repository.dart';
import 'domain/models/donation_receipt_id_kind.dart';
import 'presentation/providers/donation_receipt_providers.dart';

class DonationReceiptPage extends ConsumerStatefulWidget {
  const DonationReceiptPage({super.key});

  @override
  ConsumerState<DonationReceiptPage> createState() => _DonationReceiptPageState();
}

class _DonationReceiptPageState extends ConsumerState<DonationReceiptPage> {
  final _formKey = GlobalKey<FormState>();

  // 동의 체크
  bool agreePrivacy = false;
  bool agreeUniqueId = false;

  // 컨트롤러
  final applicantName = TextEditingController();
  final donorName = TextEditingController();
  final idNumber = TextEditingController();
  final address = TextEditingController();
  final contact = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final affiliation = TextEditingController();
  final dependents = TextEditingController();
  final password = TextEditingController();
  final memo = TextEditingController();

  // 번호 종류 (주민/사업자)
  DonationReceiptIdKind idKind = DonationReceiptIdKind.resident;

  // 기간 (드롭다운)
  int year = 2025;
  int startMonth = 1, startDay = 1;
  int endMonth = 12, endDay = 31;

  bool _submitting = false;

  @override
  void dispose() {
    applicantName.dispose();
    donorName.dispose();
    idNumber.dispose();
    address.dispose();
    contact.dispose();
    phone.dispose();
    email.dispose();
    affiliation.dispose();
    dependents.dispose();
    password.dispose();
    memo.dispose();
    super.dispose();
  }

  List<int> _daysInMonth(int y, int m) {
    final last = DateTime(y, m + 1, 0).day;
    return List.generate(last, (i) => i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final startDays = _daysInMonth(year, startMonth);
    final endDays = _daysInMonth(year, endMonth);

    // 날짜가 월 변경으로 범위를 벗어나면 보정
    if (startDay > startDays.last) startDay = startDays.last;
    if (endDay > endDays.last) endDay = endDays.last;

    return Scaffold(
      appBar: AppBar(title: const Text('기부금 영수증 신청')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const Text('개인정보 수집 및 이용 동의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),

              _CheckTile(
                value: agreePrivacy,
                title: '개인정보 수집 및 이용에 동의합니다',
                onChanged: (v) => setState(() => agreePrivacy = v),
              ),
              _CheckTile(
                value: agreeUniqueId,
                title: '고유식별정보 수집 및 이용에 동의합니다 (주민등록번호/사업자등록번호)',
                onChanged: (v) => setState(() => agreeUniqueId = v),
              ),
              const SizedBox(height: 16),

              _TextField(
                controller: applicantName,
                label: '*신청자 성명',
                validator: _required,
              ),
              _TextField(
                controller: donorName,
                label: '*기부자 성명',
                validator: _required,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Text('*번호 종류',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('주민번호'),
                      selected: idKind == DonationReceiptIdKind.resident,
                      onSelected: (_) => setState(
                          () => idKind = DonationReceiptIdKind.resident),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('사업자번호'),
                      selected: idKind == DonationReceiptIdKind.business,
                      onSelected: (_) => setState(
                          () => idKind = DonationReceiptIdKind.business),
                    ),
                  ],
                ),
              ),
              _TextField(
                controller: idNumber,
                label: idKind == DonationReceiptIdKind.resident
                    ? '*주민등록번호'
                    : '*사업자등록번호',
                hint: '숫자만 입력 또는 형식대로 입력',
                validator: (v) {
                  if (!_required(v).isNullOrEmpty) return _required(v);
                  if (!agreeUniqueId) return '고유식별정보 수집 및 이용 동의가 필요합니다.';
                  return null;
                },
              ),

              _TextField(controller: address, label: '주소'),
              _TextField(controller: contact, label: '연락처'),
              _TextField(
                controller: phone,
                label: '*핸드폰번호',
                hint: '010-0000-0000',
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              _TextField(controller: email, label: '이메일', keyboardType: TextInputType.emailAddress),
              _TextField(controller: affiliation, label: '기부자소속'),

              const SizedBox(height: 14),
              const Text('기부금납입기간', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _PeriodPicker(
                year: year,
                startMonth: startMonth,
                startDay: startDay,
                endMonth: endMonth,
                endDay: endDay,
                startDays: startDays,
                endDays: endDays,
                onChanged: (next) => setState(() {
                  year = next.year;
                  startMonth = next.startMonth;
                  startDay = next.startDay;
                  endMonth = next.endMonth;
                  endDay = next.endDay;
                }),
              ),

              const SizedBox(height: 14),
              _TextField(controller: dependents, label: '부양가족합산', keyboardType: TextInputType.number),
              _TextField(
                controller: password,
                label: '신청비밀번호',
                hint: '조회/확인용으로 사용 (예: 4~8자리)',
                obscureText: true,
              ),
              _TextField(controller: memo, label: '비고', maxLines: 3),

              const SizedBox(height: 18),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('신청하기'),
              ),
              const SizedBox(height: 10),
              const Text(
                '※ 필수 항목(*)과 동의 체크를 완료해 주세요.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? '필수 항목입니다.' : null;

  Future<void> _submit() async {
    if (!agreePrivacy || !agreeUniqueId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보 및 고유식별정보 동의가 필요합니다.')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final submission = DonationReceiptSubmission(
      applicantName: applicantName.text.trim(),
      applicantPhone: phone.text.trim(),
      donorName: donorName.text.trim(),
      idKind: idKind,
      idNumber: idNumber.text.trim(),
      donorAddress:
          address.text.trim().isEmpty ? null : address.text.trim(),
      donorContact:
          contact.text.trim().isEmpty ? null : contact.text.trim(),
      donorEmail: email.text.trim().isEmpty ? null : email.text.trim(),
      affiliation:
          affiliation.text.trim().isEmpty ? null : affiliation.text.trim(),
      periodYear: year,
      periodStart: DateTime(year, startMonth, startDay),
      periodEnd: DateTime(year, endMonth, endDay, 23, 59, 59),
      dependents:
          dependents.text.trim().isEmpty ? null : dependents.text.trim(),
      memo: memo.text.trim().isEmpty ? null : memo.text.trim(),
      password: password.text.isEmpty ? null : password.text,
      agreedPrivacy: agreePrivacy,
      agreedUniqueId: agreeUniqueId,
    );

    setState(() => _submitting = true);
    try {
      final submit = ref.read(submitDonationReceiptProvider);
      await submit(submission);
      ref.invalidate(myDonationReceiptsProvider);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('신청 완료'),
          content: const Text(
            '기부금 영수증 신청이 접수되었습니다.\n발급이 완료되면 알림으로 안내드립니다.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신청에 실패했습니다: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _CheckTile extends StatelessWidget {
  final bool value;
  final String title;
  final ValueChanged<bool> onChanged;

  const _CheckTile({required this.value, required this.title, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _PeriodValue {
  final int year, startMonth, startDay, endMonth, endDay;
  const _PeriodValue(this.year, this.startMonth, this.startDay, this.endMonth, this.endDay);
}

class _PeriodPicker extends StatelessWidget {
  final int year, startMonth, startDay, endMonth, endDay;
  final List<int> startDays, endDays;
  final ValueChanged<_PeriodValue> onChanged;

  const _PeriodPicker({
    required this.year,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.startDays,
    required this.endDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<int> months = List.generate(12, (i) => i + 1);

    Widget dd<T>(T value, List<T> items, ValueChanged<T?> onChanged) {
      return DropdownButton<T>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
        onChanged: onChanged,
        isDense: true,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: [
            const Text('시작'),
            dd<int>(year, [year], (v) {}),
            const Text('년'),
            dd<int>(startMonth, months, (v) {
              if (v == null) return;
              onChanged(_PeriodValue(year, v, startDay, endMonth, endDay));
            }),
            const Text('월'),
            dd<int>(startDay, startDays, (v) {
              if (v == null) return;
              onChanged(_PeriodValue(year, startMonth, v, endMonth, endDay));
            }),
            const Text('일'),
            const Text('~'),

            const Text('종료'),
            dd<int>(year, [year], (v) {}),
            const Text('년'),
            dd<int>(endMonth, months, (v) {
              if (v == null) return;
              onChanged(_PeriodValue(year, startMonth, startDay, v, endDay));
            }),
            const Text('월'),
            dd<int>(endDay, endDays, (v) {
              if (v == null) return;
              onChanged(_PeriodValue(year, startMonth, startDay, endMonth, v));
            }),
            const Text('일'),
          ],
        ),
      ),
    );
  }
}

extension _StrExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
