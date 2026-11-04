typedef Json = Map<String, dynamic>;

Map<String, dynamic> _compact(Map<String, dynamic> json) => json..removeWhere((_, value) => value == null);

List<T>? _list<T>(dynamic json, T Function(Json) fromJson) => (json as List?)?.map((e) => fromJson(e as Json)).toList();

List<T>? _values<T>(dynamic json) => (json as List?)?.cast<T>();

double? _double(dynamic json) => (json as num?)?.toDouble();

/// The API sends and accepts dates as `yyyy-MM-dd HH:mm:ss` in UTC.
DateTime? _date(dynamic json) => json == null ? null : DateTime.parse('${(json as String).replaceFirst(' ', 'T')}Z');

String? _dateJson(DateTime? date) => date?.toUtc().toIso8601String().substring(0, 19).replaceFirst('T', ' ');

DateTime? _day(dynamic json) => json == null ? null : DateTime.parse(json as String);

String _dayJson(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

enum MediaType { JPEG, AUDIO, VIDEO, FILE, DOCUMENT, PNG, WAV, SVG }

enum DataType { NUMBER, DOUBLE, INTEGER, PERCENT, STRING }

enum ExamStatus { OPEN, CLOSED, ACTIVE, INACTIVE }

T? _enum<T extends Enum>(List<T> values, dynamic json) =>
    json == null ? null : values.where((v) => v.name == json).firstOrNull;

class Patient {
  Patient({this.id, this.userId, this.doctorId, this.started, this.createdAt, this.profile, this.status});

  /// A new patient with a name and birth date. Only the day of [birthDate] is sent.
  Patient.named({required String fullName, required DateTime birthDate})
      : this(profile: Profile(data: ProfileData(fullName: fullName, birthDate: birthDate)));

  factory Patient.fromJson(Json json) => Patient(
        id: json['id'],
        userId: json['userId'],
        doctorId: json['doctorId'],
        started: _date(json['started']),
        createdAt: _date(json['createdAt']),
        profile: json['profile'] == null ? null : Profile.fromJson(json['profile']),
        status: json['status'],
      );

  final int? id;
  final int? userId;
  final int? doctorId;

  final DateTime? started;
  final DateTime? createdAt;
  final Profile? profile;
  final String? status;

  Json toJson() => _compact({
        'id': id,
        'userId': userId,
        'doctorId': doctorId,
        'started': _dateJson(started),
        'createdAt': _dateJson(createdAt),
        'profile': profile?.toJson(),
        'status': status,
      });
}

class Profile {
  Profile({this.id, this.type, this.data});

  factory Profile.fromJson(Json json) => Profile(
        id: json['id'],
        type: json['type'],
        data: json['data'] == null ? null : ProfileData.fromJson(json['data']),
      );

  final int? id;
  final String? type;
  final ProfileData? data;

  Json toJson() => _compact({'id': id, 'type': type, 'data': data?.toJson()});
}

class ProfileData {
  ProfileData(
      {this.fullName,
      this.identityNumber,
      this.birthDate,
      this.gender,
      this.height,
      this.weight,
      this.allergy,
      this.chronic,
      this.anamnesis,
      this.comments,
      this.doctor,
      this.isConfirmed,
      this.externalId,
      this.diagnosis,
      this.quality});

  factory ProfileData.fromJson(Json json) => ProfileData(
        fullName: json['fullName'],
        identityNumber: json['identityNumber'],
        birthDate: _day(json['birthDate']),
        gender: json['gender'],
        height: _double(json['height']),
        weight: _double(json['weight']),
        allergy: json['allergy'],
        chronic: json['chronic'],
        anamnesis: json['anamnesis'],
        comments: json['comments'],
        doctor: json['doctor'],
        isConfirmed: json['isConfirmed'],
        externalId: json['externalId'],
        diagnosis: json['diagnosis'],
        quality: json['quality'],
      );

  final String? fullName;
  final String? identityNumber;
  final DateTime? birthDate;
  final String? gender;
  final double? height;
  final double? weight;
  final String? allergy;
  final String? chronic;
  final String? anamnesis;
  final String? comments;
  final String? doctor;
  final bool? isConfirmed;
  final String? externalId;
  final String? diagnosis;
  final String? quality;

  Json toJson() => _compact({
        'fullName': fullName,
        'identityNumber': identityNumber,
        'birthDate': birthDate == null ? null : _dayJson(birthDate!),
        'gender': gender,
        'height': height,
        'weight': weight,
        'allergy': allergy,
        'chronic': chronic,
        'anamnesis': anamnesis,
        'comments': comments,
        'doctor': doctor,
        'isConfirmed': isConfirmed,
        'externalId': externalId,
        'diagnosis': diagnosis,
        'quality': quality,
      });
}

class Exam {
  Exam(
      {this.id,
      this.patientId,
      this.doctorId,
      this.examTypeId,
      this.points,
      this.remaining,
      this.newPoints,
      this.comments,
      this.status,
      this.isViewed,
      this.startDate,
      this.date,
      this.started,
      this.data,
      this.profile,
      this.byDoctor,
      this.owner});

  factory Exam.fromJson(Json json) => Exam(
        id: json['id'],
        patientId: json['patientId'],
        doctorId: json['doctorId'],
        examTypeId: json['examTypeId'],
        points: _values<int>(json['points']),
        remaining: _values<int>(json['remaining']),
        newPoints: json['newPoints'],
        comments: _list(json['comments'], ExamComment.fromJson),
        status: _enum(ExamStatus.values, json['status']),
        isViewed: json['isViewed'],
        startDate: _date(json['startDate']),
        date: _date(json['date']),
        started: _date(json['started']),
        data: _list(json['data'], ExamPointData.fromJson),
        profile: json['profile'] == null ? null : Profile.fromJson(json['profile']),
        byDoctor: json['byDoctor'],
        owner: json['owner'],
      );

  final int? id;
  final int? patientId;
  final int? doctorId;
  final int? examTypeId;
  final List<int>? points;
  final List<int>? remaining;
  final int? newPoints;
  final List<ExamComment>? comments;
  final ExamStatus? status;
  final bool? isViewed;
  final DateTime? startDate;
  final DateTime? date;
  final DateTime? started;
  final List<ExamPointData>? data;
  final Profile? profile;
  final bool? byDoctor;
  final int? owner;

  Json toJson() => _compact({
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'examTypeId': examTypeId,
        'points': points,
        'remaining': remaining,
        'newPoints': newPoints,
        'status': status?.name,
        'isViewed': isViewed,
        'startDate': _dateJson(startDate),
        'date': _dateJson(date),
        'started': _dateJson(started),
        'data': data?.map((e) => e.toJson()).toList(),
        'profile': profile?.toJson(),
        'byDoctor': byDoctor,
        'owner': owner,
      });
}

class ExamComment {
  ExamComment({this.id, this.doctorId, this.examId, this.createdAt, this.comment, this.pathology, this.noise});

  factory ExamComment.fromJson(Json json) => ExamComment(
        id: json['id'],
        doctorId: json['doctorId'],
        examId: json['examId'],
        createdAt: _date(json['createdAt']),
        comment: json['comment'],
        pathology: json['pathology'],
        noise: json['noise'],
      );

  final int? id;
  final int? doctorId;
  final int? examId;
  final DateTime? createdAt;
  final String? comment;
  final bool? pathology;
  final bool? noise;
}

class ExamPointData {
  ExamPointData(
      {this.id,
      this.examId,
      this.pointTypeId,
      this.pointNumber,
      this.date,
      this.started,
      this.data,
      this.comments,
      this.media,
      this.isViewed});

  factory ExamPointData.fromJson(Json json) => ExamPointData(
        id: json['id'],
        examId: json['examId'],
        pointTypeId: json['pointTypeId'],
        pointNumber: json['pointNumber'],
        date: _date(json['date']),
        started: _date(json['started']),
        data: json['data'],
        comments: json['comments'],
        media: json['media'] == null ? null : Media.fromJson(json['media']),
        isViewed: json['isViewed'],
      );

  final int? id;
  final int? examId;
  final int? pointTypeId;
  final int? pointNumber;
  final DateTime? date;
  final DateTime? started;
  final String? data;
  final String? comments;
  final Media? media;
  final bool? isViewed;

  Json toJson() => _compact({
        'id': id,
        'examId': examId,
        'pointTypeId': pointTypeId,
        'pointNumber': pointNumber,
        'date': _dateJson(date),
        'started': _dateJson(started),
        'data': data,
        'comments': comments,
        'isViewed': isViewed,
      });
}

class Decision {
  Decision({this.id, this.doctorId, this.mediaId, this.updatedAt, this.profile, this.verifiedBy, this.declinedBy});

  factory Decision.fromJson(Json json) => Decision(
        id: json['id'],
        doctorId: json['doctorId'],
        mediaId: json['mediaId'],
        updatedAt: _date(json['updatedAt']),
        profile: json['profile'] == null ? null : Profile.fromJson(json['profile']),
        verifiedBy: _values<int>(json['verifiedBy']),
        declinedBy: _values<int>(json['declinedBy']),
      );

  final int? id;
  final int? doctorId;
  final int? mediaId;
  final DateTime? updatedAt;
  final Profile? profile;
  final List<int>? verifiedBy;
  final List<int>? declinedBy;
}

class Media {
  Media({this.id, this.mediaType, this.fileName, this.fileMime, this.fileSize, this.mediaUri, this.consilium});

  factory Media.fromJson(Json json) => Media(
        id: json['id'],
        mediaType: _enum(MediaType.values, json['mediaType']),
        fileName: json['fileName'],
        fileMime: json['fileMime'],
        fileSize: json['fileSize'],
        mediaUri: json['mediaUri'],
        consilium: _list(json['consilium'], Decision.fromJson),
      );

  final int? id;
  final MediaType? mediaType;
  final String? fileName;
  final String? fileMime;
  final int? fileSize;
  final String? mediaUri;
  final List<Decision>? consilium;
}

class Provision {
  Provision({this.version, this.examTypes, this.questionnaire, this.settings});

  factory Provision.fromJson(Json json) => Provision(
        version: json['version'],
        examTypes: _list(json['examTypes'], ExamType.fromJson),
        questionnaire: (json['questionnaire'] as Json?)
            ?.map((key, value) => MapEntry(key, (value as Json).cast<String, String>())),
        settings: json['settings'] == null ? null : ProvisionSettings.fromJson(json['settings']),
      );

  final int? version;
  final List<ExamType>? examTypes;
  final Map<String, Map<String, String>>? questionnaire;
  final ProvisionSettings? settings;
}

class ProvisionSettings {
  ProvisionSettings({this.demoDoctorGroupId, this.demoPatientGroupId});

  factory ProvisionSettings.fromJson(Json json) => ProvisionSettings(
        demoDoctorGroupId: json['demo_doctor_group_id'],
        demoPatientGroupId: json['demo_patient_group_id'],
      );

  final int? demoDoctorGroupId;
  final int? demoPatientGroupId;
}

class ExamType {
  ExamType(
      {this.id,
      this.title,
      this.description,
      this.mediaType,
      this.dataType,
      this.multiPoint,
      this.minPoints,
      this.duration,
      this.external,
      this.settings,
      this.status,
      this.points,
      this.examInfoId,
      this.info});

  factory ExamType.fromJson(Json json) => ExamType(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        mediaType: _enum(MediaType.values, json['mediaType']),
        dataType: _enum(DataType.values, json['dataType']),
        multiPoint: json['multiPoint'],
        minPoints: json['minPoints'],
        duration: json['duration'],
        external: json['external'],
        settings: (json['settings'] as Json?)?.cast<String, String>(),
        status: _enum(ExamStatus.values, json['status']),
        points: _list(json['points'], ExamPoint.fromJson),
        examInfoId: json['examInfoId'],
        info: json['info'] == null ? null : ExamInfo.fromJson(json['info']),
      );

  final int? id;
  final String? title;
  final String? description;
  final MediaType? mediaType;
  final DataType? dataType;
  final bool? multiPoint;
  final int? minPoints;
  final int? duration;
  final bool? external;
  final Map<String, String>? settings;
  final ExamStatus? status;
  final List<ExamPoint>? points;
  final int? examInfoId;
  final ExamInfo? info;
}

class ExamPoint {
  ExamPoint(
      {this.id,
      this.title,
      this.description,
      this.notes,
      this.dataType,
      this.examTypeId,
      this.pointNumber,
      this.assets});

  factory ExamPoint.fromJson(Json json) => ExamPoint(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        notes: json['notes'],
        dataType: _enum(DataType.values, json['dataType']),
        examTypeId: json['examTypeId'],
        pointNumber: json['pointNumber'],
        assets: _list(json['assets'], ExamPointAsset.fromJson),
      );

  final int? id;
  final String? title;
  final String? description;
  final String? notes;
  final DataType? dataType;
  final int? examTypeId;
  final int? pointNumber;
  final List<ExamPointAsset>? assets;
}

class ExamPointAsset {
  ExamPointAsset({this.id, this.media, this.tag});

  factory ExamPointAsset.fromJson(Json json) => ExamPointAsset(
        id: json['id'],
        media: json['media'] == null ? null : Media.fromJson(json['media']),
        tag: json['tag'],
      );

  final int? id;
  final Media? media;
  final String? tag;
}

class ExamInfo {
  ExamInfo({this.id, this.title, this.pages});

  factory ExamInfo.fromJson(Json json) => ExamInfo(
        id: json['id'],
        title: json['title'],
        pages: _list(json['pages'], ExamInfoPage.fromJson),
      );

  final int? id;
  final String? title;
  final List<ExamInfoPage>? pages;
}

class ExamInfoPage {
  ExamInfoPage(
      {this.id,
      this.examInfoId,
      this.pageOrder,
      this.title,
      this.description,
      this.optional,
      this.actionable,
      this.b2b,
      this.media});

  factory ExamInfoPage.fromJson(Json json) => ExamInfoPage(
        id: json['id'],
        examInfoId: json['examInfoId'],
        pageOrder: json['pageOrder'],
        title: json['title'],
        description: json['description'],
        optional: json['optional'],
        actionable: json['actionable'],
        b2b: json['b2b'],
        media: _list(json['media'], Media.fromJson),
      );

  final int? id;
  final int? examInfoId;
  final int? pageOrder;
  final String? title;
  final String? description;
  final bool? optional;
  final bool? actionable;
  final bool? b2b;
  final List<Media>? media;
}
