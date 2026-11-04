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

```dart
import 'package:cross_file/cross_file.dart';
import 'package:dnd_sdk/dnd_sdk.dart';

Future<void> example(String apiKey) async {
  final client = DndClient(accessToken: () => apiKey);

  try {
    final patients = await client.patients.getPatientList();
    final exams = await client.exams.getExamList(patients.first.id!);
    final point = exams.first.data!.first;

    await client.mediaFiles.uploadMediaFile(
      mediaId: point.media!.id!,
      fps: 1.0,
      file: XFile('point1.wav'),
    );
  } on DndException catch (e) {
    print('API error ${e.statusCode}: ${e.message}');
  } finally {
    client.close();
  }
}
```

Create API keys in the web app under Settings. Pass the key to `accessToken`; it is sent as `Authorization: Bearer <key>` on every request. A key is shown only once when created. Revoking it in the web app stops it working immediately.

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

