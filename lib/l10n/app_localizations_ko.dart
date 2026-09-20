// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '근육 학습 지도';

  @override
  String get viewFront => '정면';

  @override
  String get viewBack => '후면';

  @override
  String get markTypeWeak => '학습 완료 근육';

  @override
  String get markTypeRelease => '관심 근육';

  @override
  String get markTypePainPoint => '학습 포인트';

  @override
  String get toolWeak => '학습 완료';

  @override
  String get toolRelease => '관심';

  @override
  String get toolPainPoint => '학습 포인트';

  @override
  String get noMark => '표시 없음';

  @override
  String tapToMark(String tool) {
    return '$tool 도구로 신체 부위를 탭하세요';
  }

  @override
  String get selectedRegion => '선택한 표시 영역';

  @override
  String get studyPointTitle => '학습 포인트';

  @override
  String get pressToExplore => '영역을 눌러보세요';

  @override
  String coordinatesLabel(String x, String y) {
    return '좌표: ($x, $y)';
  }

  @override
  String get hintBlue => '파란색: 학습 완료';

  @override
  String get hintRed => '빨간색: 관심';

  @override
  String get hintFaint => '옅은 색: 이전';

  @override
  String get hintDot => '점: 학습 주석';

  @override
  String get badgeSummary => '파랑/빨강/점';

  @override
  String get noteAdd => '학습 노트 추가';

  @override
  String get noteInfo => '학습 노트 정보';

  @override
  String get noteInfoSaved => '학습 노트 정보를 저장했습니다';

  @override
  String get noteNameRequired => '학습 노트 이름을 입력해주세요';

  @override
  String get noteNameLabel => '학습 노트 이름';

  @override
  String get noteNameHint => '예: 상체 근육 복습';

  @override
  String get noteNameHelper => '주제별로 학습 표시를 나누어 관리합니다';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get nothingToSave => '저장할 표시가 없습니다';

  @override
  String get snapshotSaved => '현재 표시를 학습 기록에 저장했습니다';

  @override
  String get snapshotRestored => '선택한 학습 기록을 현재 표시로 복원했습니다';

  @override
  String historyTitle(String name) {
    return '$name 학습 기록';
  }

  @override
  String get noHistory => '저장된 기록이 없습니다';

  @override
  String get compare => '비교';

  @override
  String get restoreTooltip => '현재 표시로 복원';

  @override
  String clearedView(String view) {
    return '$view 표시를 지웠습니다';
  }

  @override
  String get clearedAll => '전체 표시를 지웠습니다';

  @override
  String get rotatePromptTitle => '화면을 세로로 돌려주세요';

  @override
  String get rotatePromptBody => '이 화면은 세로 모드에서 사용할 수 있어요.';

  @override
  String marksCount(int count) {
    return '표시 $count';
  }

  @override
  String get calibrationOnTooltip => '캘리브레이션 끄기';

  @override
  String get calibrationOffTooltip => '캘리브레이션 켜기';

  @override
  String get appMenuTooltip => '앱 메뉴';

  @override
  String clearViewOnly(String view) {
    return '$view만 지우기';
  }

  @override
  String get clearAll => '전체 지우기';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get snapshotSaveTooltip => '학습 기록 저장';

  @override
  String get snapshotViewTooltip => '학습 기록 보기';

  @override
  String comparingWith(String time) {
    return '$time 학습 기록과 비교 중';
  }

  @override
  String get compareOffTooltip => '비교 해제';

  @override
  String viewTooltip(String view) {
    return '$view 보기';
  }

  @override
  String get missingAsset => '이미지 에셋이 없습니다';

  @override
  String learnedCount(int count) {
    return '학습 완료 $count';
  }

  @override
  String interestedCount(int count) {
    return '관심 $count';
  }

  @override
  String painPointCount(int count) {
    return '학습 포인트 $count';
  }

  @override
  String get privacyBody1 =>
      '근육 학습 지도는 사용자가 입력한 학습 노트 이름, 근육 학습 표시, 학습 포인트와 기록 시각을 앱 기능 제공을 위해 사용합니다.';

  @override
  String get privacyBody2 =>
      '이 정보는 사용자의 기기에만 저장됩니다. 개발자 서버로 전송하거나 제3자와 공유하지 않으며, 광고 또는 분석 목적으로 사용하지 않습니다.';

  @override
  String get privacyBody3 =>
      '앱을 삭제하면 기기에 저장된 정보도 함께 삭제됩니다. 문의: mkael0316@gmail.com';

  @override
  String get privacyBody4 => '이 앱은 인체 근육의 위치와 명칭을 익히기 위한 교육용 도구입니다.';

  @override
  String privacyEffectiveDate(String date) {
    return '시행일: $date';
  }

  @override
  String get ok => '확인';
}
