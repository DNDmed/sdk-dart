# dnd_sdk

Dart client for the Diagnostics At Home public API. Works on mobile, desktop, and Flutter web.

## Install

The package is not on pub.dev yet. Add it to `pubspec.yaml` as a git dependency:

```yaml
dependencies:
  dnd_sdk:
    git:
      url: https://github.com/DNDmed/sdk-dart.git
      ref: v1.0.0
```

Then run `dart pub get` or `flutter pub get`.

## Usage

Create an API key in the web app under Settings and pass it to `accessToken`. The key is shown once when created. Revoking it in the web app stops it working immediately.

```dart
import 'package:cross_file/cross_file.dart';
import 'package:dnd_sdk/dnd_sdk.dart';

Future<void> main() async {
  const apiKey = String.fromEnvironment('DND_API_KEY');
  final client = DndClient(accessToken: () => apiKey);

  try {
    // 1. Pick an exam type that records audio.
    final provision = await client.provisionDetails.getProvision();
    final examType = provision.examTypes!.firstWhere((type) => type.mediaType == MediaType.AUDIO);

    // 2. Create the patient.
    final patient = await client.patients.addPatient(
      fullName: 'Test Patient',
      birthDate: DateTime(1990, 1, 1),
    );

    // 3. Create an exam for the patient.
    final exam = await client.exams.addExam(
      Exam(patientId: patient.id, examTypeId: examType.id),
    );

    // 4. Add the first point; the response carries the media record to upload into.
    final point = await client.exams.addExamPointData(
      ExamPointData(examId: exam.id, pointTypeId: examType.points!.first.id, pointNumber: 1),
    );

    // 5. Upload the recording.
    await client.mediaFiles.uploadMediaFile(
      mediaId: point.media!.id!,
      file: XFile('point1.wav'),
    );

    // 6. Read the exam status.
    final status = (await client.exams.getExam(exam.id!)).status;
    print('Exam ${exam.id} for patient ${patient.id} is ${status?.name}');
  } on DndException catch (e) {
    print('API error ${e.statusCode}: ${e.message}');
  } finally {
    client.close();
  }
}
```

## Resources

| Property | Methods |
| --- | --- |
| `patients` | `getPatientList`, `getPatient`, `addPatient`, `updatePatient` |
| `exams` | `addExam`, `getExam`, `getExamList`, `addExamPointData` |
| `provisionDetails` | `getProvision` |
| `mediaFiles` | `uploadMediaFile`, `getMediaFile` |

## Dates

Dates and times are `DateTime` values. Date-times are converted to UTC when sent and read back as UTC.

A patient's birth date is a `DateTime` where only the year, month and day are used. They are sent as written, without timezone conversion.

## Errors

Non-2xx responses throw `DndException`, which carries `statusCode`, and `code` and `message` when the API returns them. Some error responses have an empty body, so both fields can be `null`.

## Media uploads

`uploadMediaFile` takes an `XFile` from [`cross_file`](https://pub.dev/packages/cross_file) and streams it with its known length. Pickers from `image_picker` and `file_picker` return `XFile`, so their results can be passed directly.

