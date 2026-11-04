import 'dart:convert';

import 'package:dnd_sdk/dnd_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  DndClient clientFor(http.Client inner, {String? token}) => DndClient.fromBaseUrl(
        baseUrl: Uri.parse('https://example.com/api'),
        accessToken: () => token,
        httpClient: inner,
      );

  test('sends the bearer token and resolves paths under the base URL', () async {
    late http.Request captured;
    final client = clientFor(
      MockClient((request) async {
        captured = request;
        return http.Response('[]', 200);
      }),
      token: 'abc',
    );

    await client.exams.getExamList(1);

    expect(captured.url.toString(), 'https://example.com/api/exam?byPatient=1');
    expect(captured.headers['Authorization'], 'Bearer abc');
  });

  test('default constructor targets web.mydnd.ru/api', () async {
    late http.Request captured;
    final client = DndClient(
      accessToken: () => null,
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('[]', 200);
      }),
    );

    await client.patients.getPatientList();

    expect(captured.url.toString(), 'https://web.mydnd.ru/api/patient');
  });

  test('throws DndException with code and message from a JSON error body', () async {
    final client = clientFor(MockClient((_) async => http.Response('{"code": 403, "message": "Forbidden"}', 403)));

    await expectLater(
      client.exams.getExam(1),
      throwsA(isA<DndException>()
          .having((e) => e.statusCode, 'statusCode', 403)
          .having((e) => e.code, 'code', 403)
          .having((e) => e.message, 'message', 'Forbidden')),
    );
  });

  test('throws DndException without details for an empty error body', () async {
    final client = clientFor(MockClient((_) async => http.Response('', 404)));

    await expectLater(
      client.exams.getExam(1),
      throwsA(isA<DndException>()
          .having((e) => e.statusCode, 'statusCode', 404)
          .having((e) => e.code, 'code', isNull)
          .having((e) => e.message, 'message', isNull)),
    );
  });

  test('throws DndException when the error body is not an object', () async {
    final client = clientFor(MockClient((_) async => http.Response(jsonEncode([1, 2]), 500)));

    await expectLater(client.exams.getExam(1), throwsA(isA<DndException>()));
  });
}
