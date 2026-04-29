import 'package:flutter_test/flutter_test.dart';
import 'package:musle_map/models/body_view.dart';
import 'package:musle_map/models/muscle_mark.dart';

void main() {
  test('통증 포인트가 사용자 프로필과 히스토리에 저장된다', () {
    final profile = UserBodyProfile.create('테스트 사용자');
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

  test('사용자 생년월일은 선택 값으로 저장된다', () {
    final profile = UserBodyProfile.create('기본 사용자', birthDate: '1990-01-01');
    final restoredProfile = UserBodyProfile.fromJson(profile.toJson());
    final emptyBirthDateProfile = UserBodyProfile.fromJson(
      UserBodyProfile.create('생년월일 없음').toJson(),
    );

    expect(restoredProfile.birthDate, '1990-01-01');
    expect(emptyBirthDateProfile.birthDate, isNull);
  });
}
