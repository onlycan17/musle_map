import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:musle_map/main.dart';

void main() {
  testWidgets('근육 학습 지도 앱이 렌더링된다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();

    expect(find.text('근육 학습 지도'), findsOneWidget);
    expect(find.text('영역을 눌러보세요'), findsOneWidget);
    expect(find.text('학습 포인트 0'), findsOneWidget);
    expect(find.byTooltip('학습 노트 정보'), findsOneWidget);
  });

  testWidgets('태블릿 가로 화면에서도 주요 조작부와 인체 영역이 렌더링된다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];
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
    expect(find.text('근육 학습 지도'), findsOneWidget);
    expect(find.text('정면'), findsWidgets);
    expect(find.text('학습 완료 0'), findsOneWidget);
    expect(find.text('학습 포인트 0'), findsOneWidget);
    expect(find.text('영역을 눌러보세요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 학습 노트 정보 다이얼로그가 넘치지 않는다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('학습 노트 정보'));
    await tester.pumpAndSettle();

    expect(find.text('학습 노트 정보'), findsOneWidget);
    expect(find.text('학습 노트 이름'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('앱 메뉴에서 교육용 개인정보 처리방침을 확인할 수 있다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('앱 메뉴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('개인정보 처리방침'));
    await tester.pumpAndSettle();

    expect(find.text('개인정보 처리방침'), findsOneWidget);
    expect(find.textContaining('개발자 서버로 전송'), findsOneWidget);
    expect(find.textContaining('교육용 도구입니다'), findsOneWidget);
    expect(find.textContaining('mkael0316@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('학습 노트 이름을 수정하면 다시 불러와진다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];

    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('학습 노트 정보'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, '학습 노트 이름'),
      '등 근육 복습',
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.text('등 근육 복습'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MuscleMapApp());
    await tester.pumpAndSettle();
    expect(find.text('등 근육 복습'), findsOneWidget);

    await tester.tap(find.byTooltip('학습 노트 정보'));
    await tester.pumpAndSettle();

    expect(find.text('등 근육 복습'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
