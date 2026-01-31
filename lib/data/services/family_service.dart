import '../../core/network/api_client.dart';
import '../models/family_group.dart';

class FamilyService {
  final ApiClient _api;

  FamilyService({ApiClient? api}) : _api = api ?? ApiClient();

  /// Creates a family group by POSTing to /FamilyGroups
  Future<void> createFamilyGroup(FamilyGroupRequest req) async {
    await _api.post('/FamilyGroups', body: req.toJson());
  }
}
