import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:musle_map/main.dart';

void main() {
  testWidgets('근육 지도 앱이 렌더링된다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();

    expect(find.text('근육 지도'), findsOneWidget);
    expect(find.text('영역을 눌러보세요'), findsOneWidget);
    expect(find.text('통증 점 0'), findsOneWidget);
    expect(find.byTooltip('사용자 정보'), findsOneWidget);
  });

  testWidgets('태블릿 가로 화면에서도 주요 조작부와 인체 영역이 렌더링된다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1210, 834);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('tablet_landscape_shell')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('tablet_body_stage')), findsOneWidget);
    expect(find.text('근육 지도'), findsOneWidget);
    expect(find.text('정면'), findsWidgets);
    expect(find.text('약한 근육 0'), findsOneWidget);
    expect(find.text('통증 점 0'), findsOneWidget);
    expect(find.text('영역을 눌러보세요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
