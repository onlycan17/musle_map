import 'package:flutter_test/flutter_test.dart';
import 'package:musle_map/models/body_view.dart';
import 'package:musle_map/models/muscle_mark.dart';

void main() {
  test('학습 포인트가 학습 노트와 학습 기록에 저장된다', () {
    final profile = UserBodyProfile.create('상체 근육 복습');
    profile.painPoints[BodyView.front]!.add(
      BodyPainPoint.create(x: 120, y: 240),
    );

    final snapshot = profile.createSnapshot();
    final restoredProfile = UserBodyProfile.fromJson(profile.toJson());
    final restoredSnapshot = BodySnapshot.fromJson(snapshot.toJson());

    expect(profile.painPointCount, 1);
    expect(snapshot.painPointCount, 1);
    expect(restoredProfile.painPoints[BodyView.front], hasLength(1));
    expect(restoredSnapshot.painPoints[BodyView.front], hasLength(1));
    expect(restoredProfile.totalCount, 1);
  });

  test('학습 노트에는 개인 신상 정보가 저장되지 않는다', () {
    final json = UserBodyProfile.create('기본 학습 노트').toJson();

    expect(json, isNot(contains('birthDate')));
  });
}
