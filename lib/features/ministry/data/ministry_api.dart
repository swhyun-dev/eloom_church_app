import '../../../services/api_service.dart';
import '../domain/models/ministry_dept.dart';
import 'dto/ministry_application_dto.dart';

class MinistryApi {
  MinistryApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/ministry-applications/me
  Future<List<MinistryApplicationDto>> fetchMine() async {
    final data = await _api.get('/api/v1/ministry-applications/me');
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(MinistryApplicationDto.fromJson)
        .toList();
  }

  /// POST /api/v1/ministry-applications
  Future<MinistryApplicationDto> submit({
    required MinistryDept department,
    required String motivation,
    String? experience,
  }) async {
    final data = await _api.post('/api/v1/ministry-applications', {
      'department': department.apiValue,
      'motivation': motivation,
      if (experience != null && experience.isNotEmpty) 'experience': experience,
    });
    final item = data['item'] as Map<String, dynamic>?;
    if (item == null) {
      throw Exception('신청 응답 형식이 올바르지 않습니다.');
    }
    return MinistryApplicationDto.fromJson(item);
  }

  /// PATCH /api/v1/ministry-applications/:id/cancel
  Future<MinistryApplicationDto> cancel(int id) async {
    final data = await _api.patch(
      '/api/v1/ministry-applications/$id/cancel',
      const {},
    );
    final item = data['item'] as Map<String, dynamic>?;
    if (item == null) {
      throw Exception('취소 응답 형식이 올바르지 않습니다.');
    }
    return MinistryApplicationDto.fromJson(item);
  }
}
