import 'package:dnd_sdk/dnd_sdk.dart';
import 'package:test/test.dart';

void main() {
  test('reads dates as UTC from the API format', () {
    final exam = Exam.fromJson({'id': 7, 'date': '2026-10-22 09:26:27', 'status': 'OPEN'});

    expect(exam.date, DateTime.utc(2026, 10, 22, 9, 26, 27));
    expect(exam.status, ExamStatus.OPEN);
  });

  test('writes dates back in the API format', () {
    final json = Exam(date: DateTime.utc(2026, 10, 22, 9, 26, 27)).toJson();

    expect(json['date'], '2026-10-22 09:26:27');
  });

  test('sends a new patient birth date as the date written, whatever the timezone', () {
    final json = Patient.named(fullName: 'Test', birthDate: DateTime(1990, 1, 1)).toJson();

    expect(json['profile']['data']['birthDate'], '1990-01-01');
  });

  test('reads snake_case provision settings', () {
    final provision = Provision.fromJson({
      'settings': {'demo_doctor_group_id': 5, 'demo_patient_group_id': 6},
    });

    expect(provision.settings?.demoDoctorGroupId, 5);
    expect(provision.settings?.demoPatientGroupId, 6);
  });
}
