import 'body_view.dart';

enum MarkTool { weak, release, painPoint }

extension MarkToolLabel on MarkTool {
  String get koreanLabel {
    switch (this) {
      case MarkTool.weak:
        return '약한 근육';
      case MarkTool.release:
        return '풀어야 할 근육';
      case MarkTool.painPoint:
        return '통증 포인트';
    }
  }

  MuscleMarkType? get fillMarkType {
    switch (this) {
      case MarkTool.weak:
        return MuscleMarkType.weak;
      case MarkTool.release:
        return MuscleMarkType.release;
      case MarkTool.painPoint:
        return null;
    }
  }
}

enum MuscleMarkType { weak, release }

extension MuscleMarkTypeLabel on MuscleMarkType {
  String get storageKey => name;

  String get koreanLabel {
    switch (this) {
      case MuscleMarkType.weak:
        return '약한 근육';
      case MuscleMarkType.release:
        return '통증/과활성';
    }
  }

  String get shortLabel {
    switch (this) {
      case MuscleMarkType.weak:
        return '약화';
      case MuscleMarkType.release:
        return '통증';
    }
  }
}

typedef BodyMarkMap = Map<BodyView, Map<String, MuscleMarkType>>;
typedef BodyPainPointMap = Map<BodyView, List<BodyPainPoint>>;

BodyMarkMap emptyBodyMarks() => {
  for (final view in BodyView.values) view: <String, MuscleMarkType>{},
};

BodyMarkMap cloneBodyMarks(BodyMarkMap source) => {
  for (final view in BodyView.values)
    view: Map<String, MuscleMarkType>.from(source[view] ?? const {}),
};

BodyPainPointMap emptyBodyPainPoints() => {
  for (final view in BodyView.values) view: <BodyPainPoint>[],
};

BodyPainPointMap cloneBodyPainPoints(BodyPainPointMap source) => {
  for (final view in BodyView.values)
    view: (source[view] ?? const <BodyPainPoint>[])
        .map((point) => point.copy())
        .toList(),
};

Map<String, dynamic> bodyMarksToJson(BodyMarkMap marks) => {
  for (final view in BodyView.values)
    view.name: {
      for (final entry
          in (marks[view] ?? const <String, MuscleMarkType>{}).entries)
        entry.key: entry.value.storageKey,
    },
};

BodyMarkMap bodyMarksFromJson(Object? json) {
  final result = emptyBodyMarks();
  if (json is! Map) return result;

  for (final view in BodyView.values) {
    final rawViewMarks = json[view.name];
    if (rawViewMarks is! Map) continue;

    for (final entry in rawViewMarks.entries) {
      final muscleId = entry.key;
      final markKey = entry.value;
      if (muscleId is! String || markKey is! String) continue;

      final markType = MuscleMarkType.values.where(
        (type) => type.storageKey == markKey,
      );
      if (markType.isEmpty) continue;
      result[view]![muscleId] = markType.first;
    }
  }

  return result;
}

Map<String, dynamic> bodyPainPointsToJson(BodyPainPointMap points) => {
  for (final view in BodyView.values)
    view.name: (points[view] ?? const <BodyPainPoint>[])
        .map((point) => point.toJson())
        .toList(),
};

BodyPainPointMap bodyPainPointsFromJson(Object? json) {
  final result = emptyBodyPainPoints();
  if (json is! Map) return result;

  for (final view in BodyView.values) {
    final rawPoints = json[view.name];
    if (rawPoints is! List) continue;
    result[view] = rawPoints
        .whereType<Map>()
        .map(
          (point) => BodyPainPoint.fromJson(Map<String, dynamic>.from(point)),
        )
        .toList();
  }

  return result;
}

class BodyPainPoint {
  BodyPainPoint({
    required this.id,
    required this.x,
    required this.y,
    required this.createdAt,
  });

  final String id;
  final double x;
  final double y;
  final DateTime createdAt;

  BodyPainPoint copy() =>
      BodyPainPoint(id: id, x: x, y: y, createdAt: createdAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'x': x,
    'y': y,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BodyPainPoint.create({required double x, required double y}) {
    final now = DateTime.now();
    return BodyPainPoint(
      id: 'pain_${now.microsecondsSinceEpoch}',
      x: x,
      y: y,
      createdAt: now,
    );
  }

  factory BodyPainPoint.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse('${json['createdAt']}');
    return BodyPainPoint(
      id: '${json['id'] ?? DateTime.now().microsecondsSinceEpoch}',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

class BodySnapshot {
  BodySnapshot({
    required this.id,
    required this.createdAt,
    required this.marks,
    required this.painPoints,
    this.note = '',
  });

  final String id;
  final DateTime createdAt;
  final BodyMarkMap marks;
  final BodyPainPointMap painPoints;
  final String note;

  int get weakCount => _countByType(MuscleMarkType.weak);

  int get releaseCount => _countByType(MuscleMarkType.release);

  int get painPointCount =>
      painPoints.values.fold(0, (sum, points) => sum + points.length);

  int get totalCount => weakCount + releaseCount + painPointCount;

  int _countByType(MuscleMarkType type) {
    return marks.values.fold(
      0,
      (sum, viewMarks) =>
          sum + viewMarks.values.where((mark) => mark == type).length,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
    'marks': bodyMarksToJson(marks),
    'painPoints': bodyPainPointsToJson(painPoints),
  };

  factory BodySnapshot.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse('${json['createdAt']}');
    return BodySnapshot(
      id: '${json['id'] ?? DateTime.now().microsecondsSinceEpoch}',
      createdAt: createdAt ?? DateTime.now(),
      note: '${json['note'] ?? ''}',
      marks: bodyMarksFromJson(json['marks']),
      painPoints: bodyPainPointsFromJson(json['painPoints']),
    );
  }
}

class UserBodyProfile {
  UserBodyProfile({
    required this.id,
    required this.name,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
    required this.marks,
    required this.painPoints,
    required this.history,
  });

  final String id;
  String name;
  String? birthDate;
  final DateTime createdAt;
  DateTime updatedAt;
  BodyMarkMap marks;
  BodyPainPointMap painPoints;
  final List<BodySnapshot> history;

  int get weakCount => _countByType(MuscleMarkType.weak);

  int get releaseCount => _countByType(MuscleMarkType.release);

  int get painPointCount =>
      painPoints.values.fold(0, (sum, points) => sum + points.length);

  int get totalCount => weakCount + releaseCount + painPointCount;

  int viewCount(BodyView view) =>
      (marks[view]?.length ?? 0) + (painPoints[view]?.length ?? 0);

  int _countByType(MuscleMarkType type) {
    return marks.values.fold(
      0,
      (sum, viewMarks) =>
          sum + viewMarks.values.where((mark) => mark == type).length,
    );
  }

  BodySnapshot createSnapshot() {
    final now = DateTime.now();
    return BodySnapshot(
      id: 'snapshot_${now.microsecondsSinceEpoch}',
      createdAt: now,
      marks: cloneBodyMarks(marks),
      painPoints: cloneBodyPainPoints(painPoints),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birthDate': birthDate,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'marks': bodyMarksToJson(marks),
    'painPoints': bodyPainPointsToJson(painPoints),
    'history': history.map((snapshot) => snapshot.toJson()).toList(),
  };

  factory UserBodyProfile.create(String name, {String? birthDate}) {
    final now = DateTime.now();
    return UserBodyProfile(
      id: 'profile_${now.microsecondsSinceEpoch}',
      name: name,
      birthDate: birthDate,
      createdAt: now,
      updatedAt: now,
      marks: emptyBodyMarks(),
      painPoints: emptyBodyPainPoints(),
      history: <BodySnapshot>[],
    );
  }

  factory UserBodyProfile.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse('${json['createdAt']}');
    final updatedAt = DateTime.tryParse('${json['updatedAt']}');
    final rawHistory = json['history'];

    return UserBodyProfile(
      id: '${json['id'] ?? DateTime.now().microsecondsSinceEpoch}',
      name: '${json['name'] ?? '사용자'}',
      birthDate: _nullableString(json['birthDate']),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      marks: bodyMarksFromJson(json['marks']),
      painPoints: bodyPainPointsFromJson(json['painPoints']),
      history: rawHistory is List
          ? rawHistory
                .whereType<Map>()
                .map(
                  (snapshot) => BodySnapshot.fromJson(
                    Map<String, dynamic>.from(snapshot),
                  ),
                )
                .toList()
          : <BodySnapshot>[],
    );
  }
}

String? _nullableString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
