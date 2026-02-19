import '../models/church_registry_person.dart';

class ChurchRegistryDummy {
  static const persons = <ChurchRegistryPerson>[
    ChurchRegistryPerson(
      name: '홍길동',
      phone: '01012345678',
      position: '집사',
      parish: '1교구',
      district: '3구역',
      isDistrictLeader: true,
    ),
    ChurchRegistryPerson(
      name: '김영희',
      phone: '01022223333',
      position: '권사',
      parish: '2교구',
      district: '1구역',
      isDistrictLeader: false,
    ),
    ChurchRegistryPerson(
      name: '박철수',
      phone: '01099998888',
      position: '성도',
      parish: '3교구',
      district: '2구역',
      isDistrictLeader: false,
    ),
  ];
}
