import '../../core/network/api_client.dart';
import '../models/report_item.dart';
import '../models/category_report.dart';
import '../models/pie_category.dart';

class ReportService {
  final ApiClient _api;

  ReportService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<ReportItem>> getDailyMonthlyReport({required String familyGroupId, required DateTime start, required DateTime end}) async {
    final params = {
      'familyGroupId': familyGroupId,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
    };

    final res = await _api.get('/finance/report/daily-monthly', params: params);
    if (res is List) {
      return res.map((e) => ReportItem.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw ApiException('Unexpected report response');
  }

  Future<List<CategoryReport>> getCategoryWiseReport({required String familyGroupId, required DateTime start, required DateTime end}) async {
    final params = {
      'familyGroupId': familyGroupId,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
    };

    final res = await _api.get('/finance/report/category-wise', params: params);
    if (res is List) {
      return res.map((e) => CategoryReport.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw ApiException('Unexpected category report response');
  }

  Future<List<PieCategory>> getPieCategoryChart({String? familyGroupId, DateTime? start, DateTime? end}) async {
    final params = <String, String>{};
    if (familyGroupId != null) params['familyGroupId'] = familyGroupId;
    if (start != null) params['start'] = start.toUtc().toIso8601String();
    if (end != null) params['end'] = end.toUtc().toIso8601String();

    final res = await _api.get('/finance/chart/pie-category', params: params.isEmpty ? null : params);
    if (res is List) {
      return res.map((e) => PieCategory.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw ApiException('Unexpected pie chart response');
  }
}
