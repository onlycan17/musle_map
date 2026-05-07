import 'package:flutter/material.dart';
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

  testWidgets('작은 화면에서도 사용자 정보 다이얼로그가 넘치지 않는다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('사용자 정보'));
    await tester.pumpAndSettle();

    expect(find.text('사용자 정보'), findsOneWidget);
    expect(find.text('이름'), findsOneWidget);
    expect(find.text('생년월일'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('사용자 정보 수정 후 이름과 생년월일이 다시 불러와진다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('사용자 정보'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '이름'), '홍길동');
    await tester.enterText(
      find.widgetWithText(TextFormField, '생년월일'),
      '19900101',
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.text('홍길동 (1990-01-01)'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();
    expect(find.text('홍길동 (1990-01-01)'), findsOneWidget);

    await tester.tap(find.byTooltip('사용자 정보'));
    await tester.pumpAndSettle();

    expect(find.text('홍길동'), findsWidgets);
    expect(find.text('1990-01-01'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
