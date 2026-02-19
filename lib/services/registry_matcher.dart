import '../../dummy/church_registry_dummy.dart';
import '../models/church_registry_person.dart';

class RegistryMatcher {
  /// phone은 숫자만(01012345678) 기준
  static ChurchRegistryPerson? match({required String name, required String phone}) {
    final normalizedName = name.trim();
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    for (final p in ChurchRegistryDummy.persons) {
      if (p.name == normalizedName && p.phone == normalizedPhone) return p;
    }
    return null;
  }
}
