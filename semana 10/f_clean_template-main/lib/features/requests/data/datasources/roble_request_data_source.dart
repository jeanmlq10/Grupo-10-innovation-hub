import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/features/requests/data/datasources/i_request_data_source.dart';

/// Habla con Roble sobre `project_requests` y `request_decisions`.
/// No decide nada.
class RobleRequestDataSource implements IRequestDataSource {
  RobleRequestDataSource(this._client);

  final RobleClient _client;

  @override
  Future<List<Map<String, dynamic>>> readRequests({String? projectId}) =>
      _client.db.read(
        RobleClient.requests,
        filters: projectId == null ? null : {'projectId': projectId},
      );

  @override
  Future<List<Map<String, dynamic>>> readByApplicant(String userId) =>
      _client.db.read(
        RobleClient.requests,
        filters: {'applicantUserId': userId},
      );

  @override
  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> row) =>
      _client.db.create(RobleClient.requests, row);

  @override
  Future<List<Map<String, dynamic>>> readDecisions() =>
      _client.db.read(RobleClient.decisions);

  @override
  Future<Map<String, dynamic>> createDecision(Map<String, dynamic> row) =>
      _client.db.create(RobleClient.decisions, row);
}
