enum AccountRole {
  admin,   // 관리자
  staff,   // 교역자
  member,  // 성도(교적 매칭 완료)
  pending, // 준회원(교적 미매칭)
  guest,   // 비회원
}

extension AccountRoleX on AccountRole {
  String get label {
    switch (this) {
      case AccountRole.admin:
        return '관리자';
      case AccountRole.staff:
        return '교역자';
      case AccountRole.member:
        return '성도';
      case AccountRole.pending:
        return '준회원';
      case AccountRole.guest:
        return '비회원';
    }
  }
}
