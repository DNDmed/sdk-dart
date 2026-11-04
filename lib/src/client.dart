import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

class DndException implements Exception {
  DndException(this.statusCode, this.code, this.message);

  final int statusCode;
  final int? code;
  final String? message;

  @override
  String toString() => 'DndException($statusCode, $message)';
}

/// Owns the HTTP client for the public API.
///
/// [accessToken] is read on every request and sent as `Authorization: Bearer <token>`.
class DndClient {
  DndClient({required String? Function() accessToken, http.Client? httpClient})
      : this.fromBaseUrl(
          baseUrl: Uri.parse(defaultBaseUrl),
          accessToken: accessToken,
          httpClient: httpClient,
        );

  DndClient.fromBaseUrl({required Uri baseUrl, required this.accessToken, http.Client? httpClient})
      : baseUrl = baseUrl.path.endsWith('/') ? baseUrl : baseUrl.replace(path: '${baseUrl.path}/'),
        _http = httpClient ?? http.Client();

  static const defaultBaseUrl = 'https://web.mydnd.ru/api/';

  final Uri baseUrl;
  final String? Function() accessToken;
  final http.Client _http;

  late final patients = Patients._(this);
  late final exams = Exams._(this);
  late final provisionDetails = ProvisionDetails._(this);
  late final mediaFiles = MediaFiles._(this);

  /// Closes the underlying HTTP client. Requests made after this fail.
  void close() => _http.close();

  Map<String, String> _headers() {
    final token = accessToken();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(String method, String path, {Object? body, Map<String, String>? query}) async {
    final request = http.Request(method, baseUrl.resolve(path).replace(queryParameters: query))
      ..headers.addAll(_headers());
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    return _check(await http.Response.fromStream(await _http.send(request)));
  }

  http.Response _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      Object? error;
      try {
        error = jsonDecode(response.body);
      } catch (_) {}
      final body = error is Map<String, dynamic> ? error : const <String, dynamic>{};
      final code = body['code'];
      final message = body['message'];
      throw DndException(response.statusCode, code is int ? code : null, message is String ? message : null);
    }
    return response;
  }

  Future<dynamic> _json(String method, String path, {Object? body, Map<String, String>? query}) async =>
      jsonDecode((await _send(method, path, body: body, query: query)).body);
}

class Patients {
  Patients._(this._client);

  final DndClient _client;

  Future<List<Patient>> getPatientList() async =>
      (await _client._json('GET', 'patient') as List).map((e) => Patient.fromJson(e)).toList();

  Future<Patient> getPatient(int patientId) async => Patient.fromJson(await _client._json('GET', 'patient/$patientId'));

  Future<Patient> addPatient({required String fullName, required DateTime birthDate}) async => Patient.fromJson(
      await _client._json('POST', 'patient', body: Patient.named(fullName: fullName, birthDate: birthDate)));

  Future<Patient> updatePatient(int patientId, Patient patient) async =>
      Patient.fromJson(await _client._json('PUT', 'patient/$patientId', body: patient));
}

class Exams {
  Exams._(this._client);

  final DndClient _client;

  Future<Exam> addExam(Exam exam) async => Exam.fromJson(await _client._json('POST', 'exam', body: exam));

  Future<Exam> getExam(int examId) async => Exam.fromJson(await _client._json('GET', 'exam/$examId'));

  Future<List<Exam>> getExamList(int patientId) async =>
      (await _client._json('GET', 'exam', query: {'byPatient': '$patientId'}) as List)
          .map((e) => Exam.fromJson(e))
          .toList();

  Future<ExamPointData> addExamPointData(ExamPointData data) async =>
      ExamPointData.fromJson(await _client._json('POST', 'exam-data', body: data));
}

class ProvisionDetails {
  ProvisionDetails._(this._client);

  final DndClient _client;

  Future<Provision> getProvision() async => Provision.fromJson(await _client._json('GET', 'provision'));
}

class MediaFiles {
  MediaFiles._(this._client);

  final DndClient _client;

  Future<void> uploadMediaFile({required int mediaId, required XFile file}) async {
    final request = http.MultipartRequest('POST', _client.baseUrl.resolve('media/$mediaId'))
      ..headers.addAll(_client._headers())
      ..fields['fps'] = '0.0'
      ..files.add(http.MultipartFile(
        'file',
        file.openRead(),
        await file.length(),
        filename: file.name,
      ));
    _client._check(await http.Response.fromStream(await _client._http.send(request)));
  }

  Future<Uint8List> getMediaFile(int mediaId) async => (await _client._send('GET', 'media/$mediaId/file')).bodyBytes;
}
