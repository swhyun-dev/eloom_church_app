import '../domain/ministry_repository.dart';
import '../domain/models/ministry_application.dart';
import '../domain/models/ministry_dept.dart';
import 'mappers/ministry_application_mapper.dart';
import 'ministry_api.dart';

class MinistryRepositoryImpl implements MinistryRepository {
  final MinistryApi api;

  MinistryRepositoryImpl({required this.api});

  @override
  Future<List<MinistryApplication>> fetchMyApplications() async {
    final dtos = await api.fetchMine();
    return dtos.map(MinistryApplicationMapper.toDomain).toList();
  }

  @override
  Future<MinistryApplication> submit({
    required MinistryDept department,
    required String motivation,
    String? experience,
  }) async {
    final dto = await api.submit(
      department: department,
      motivation: motivation,
      experience: experience,
    );
    return MinistryApplicationMapper.toDomain(dto);
  }

  @override
  Future<MinistryApplication> cancel(int id) async {
    final dto = await api.cancel(id);
    return MinistryApplicationMapper.toDomain(dto);
  }
}
