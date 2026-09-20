import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'근육 학습 지도'**
  String get appTitle;

  /// No description provided for @viewFront.
  ///
  /// In ko, this message translates to:
  /// **'정면'**
  String get viewFront;

  /// No description provided for @viewBack.
  ///
  /// In ko, this message translates to:
  /// **'후면'**
  String get viewBack;

  /// No description provided for @markTypeWeak.
  ///
  /// In ko, this message translates to:
  /// **'학습 완료 근육'**
  String get markTypeWeak;

  /// No description provided for @markTypeRelease.
  ///
  /// In ko, this message translates to:
  /// **'관심 근육'**
  String get markTypeRelease;

  /// No description provided for @markTypePainPoint.
  ///
  /// In ko, this message translates to:
  /// **'학습 포인트'**
  String get markTypePainPoint;

  /// No description provided for @toolWeak.
  ///
  /// In ko, this message translates to:
  /// **'학습 완료'**
  String get toolWeak;

  /// No description provided for @toolRelease.
  ///
  /// In ko, this message translates to:
  /// **'관심'**
  String get toolRelease;

  /// No description provided for @toolPainPoint.
  ///
  /// In ko, this message translates to:
  /// **'학습 포인트'**
  String get toolPainPoint;

  /// No description provided for @noMark.
  ///
  /// In ko, this message translates to:
  /// **'표시 없음'**
  String get noMark;

  /// No description provided for @tapToMark.
  ///
  /// In ko, this message translates to:
  /// **'{tool} 도구로 신체 부위를 탭하세요'**
  String tapToMark(String tool);

  /// No description provided for @selectedRegion.
  ///
  /// In ko, this message translates to:
  /// **'선택한 표시 영역'**
  String get selectedRegion;

  /// No description provided for @studyPointTitle.
  ///
  /// In ko, this message translates to:
  /// **'학습 포인트'**
  String get studyPointTitle;

  /// No description provided for @pressToExplore.
  ///
  /// In ko, this message translates to:
  /// **'영역을 눌러보세요'**
  String get pressToExplore;

  /// No description provided for @coordinatesLabel.
  ///
  /// In ko, this message translates to:
  /// **'좌표: ({x}, {y})'**
  String coordinatesLabel(String x, String y);

  /// No description provided for @hintBlue.
  ///
  /// In ko, this message translates to:
  /// **'파란색: 학습 완료'**
  String get hintBlue;

  /// No description provided for @hintRed.
  ///
  /// In ko, this message translates to:
  /// **'빨간색: 관심'**
  String get hintRed;

  /// No description provided for @hintFaint.
  ///
  /// In ko, this message translates to:
  /// **'옅은 색: 이전'**
  String get hintFaint;

  /// No description provided for @hintDot.
  ///
  /// In ko, this message translates to:
  /// **'점: 학습 주석'**
  String get hintDot;

  /// No description provided for @badgeSummary.
  ///
  /// In ko, this message translates to:
  /// **'파랑/빨강/점'**
  String get badgeSummary;

  /// No description provided for @noteAdd.
  ///
  /// In ko, this message translates to:
  /// **'학습 노트 추가'**
  String get noteAdd;

  /// No description provided for @noteInfo.
  ///
  /// In ko, this message translates to:
  /// **'학습 노트 정보'**
  String get noteInfo;

  /// No description provided for @noteInfoSaved.
  ///
  /// In ko, this message translates to:
  /// **'학습 노트 정보를 저장했습니다'**
  String get noteInfoSaved;

  /// No description provided for @noteNameRequired.
  ///
  /// In ko, this message translates to:
  /// **'학습 노트 이름을 입력해주세요'**
  String get noteNameRequired;

  /// No description provided for @noteNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'학습 노트 이름'**
  String get noteNameLabel;

  /// No description provided for @noteNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 상체 근육 복습'**
  String get noteNameHint;

  /// No description provided for @noteNameHelper.
  ///
  /// In ko, this message translates to:
  /// **'주제별로 학습 표시를 나누어 관리합니다'**
  String get noteNameHelper;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @nothingToSave.
  ///
  /// In ko, this message translates to:
  /// **'저장할 표시가 없습니다'**
  String get nothingToSave;

  /// No description provided for @snapshotSaved.
  ///
  /// In ko, this message translates to:
  /// **'현재 표시를 학습 기록에 저장했습니다'**
  String get snapshotSaved;

  /// No description provided for @snapshotRestored.
  ///
  /// In ko, this message translates to:
  /// **'선택한 학습 기록을 현재 표시로 복원했습니다'**
  String get snapshotRestored;

  /// No description provided for @historyTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} 학습 기록'**
  String historyTitle(String name);

  /// No description provided for @noHistory.
  ///
  /// In ko, this message translates to:
  /// **'저장된 기록이 없습니다'**
  String get noHistory;

  /// No description provided for @compare.
  ///
  /// In ko, this message translates to:
  /// **'비교'**
  String get compare;

  /// No description provided for @restoreTooltip.
  ///
  /// In ko, this message translates to:
  /// **'현재 표시로 복원'**
  String get restoreTooltip;

  /// No description provided for @clearedView.
  ///
  /// In ko, this message translates to:
  /// **'{view} 표시를 지웠습니다'**
  String clearedView(String view);

  /// No description provided for @clearedAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 표시를 지웠습니다'**
  String get clearedAll;

  /// No description provided for @rotatePromptTitle.
  ///
  /// In ko, this message translates to:
  /// **'화면을 세로로 돌려주세요'**
  String get rotatePromptTitle;

  /// No description provided for @rotatePromptBody.
  ///
  /// In ko, this message translates to:
  /// **'이 화면은 세로 모드에서 사용할 수 있어요.'**
  String get rotatePromptBody;

  /// No description provided for @marksCount.
  ///
  /// In ko, this message translates to:
  /// **'표시 {count}'**
  String marksCount(int count);

  /// No description provided for @calibrationOnTooltip.
  ///
  /// In ko, this message translates to:
  /// **'캘리브레이션 끄기'**
  String get calibrationOnTooltip;

  /// No description provided for @calibrationOffTooltip.
  ///
  /// In ko, this message translates to:
  /// **'캘리브레이션 켜기'**
  String get calibrationOffTooltip;

  /// No description provided for @appMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'앱 메뉴'**
  String get appMenuTooltip;

  /// No description provided for @clearViewOnly.
  ///
  /// In ko, this message translates to:
  /// **'{view}만 지우기'**
  String clearViewOnly(String view);

  /// No description provided for @clearAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 지우기'**
  String get clearAll;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get privacyPolicy;

  /// No description provided for @snapshotSaveTooltip.
  ///
  /// In ko, this message translates to:
  /// **'학습 기록 저장'**
  String get snapshotSaveTooltip;

  /// No description provided for @snapshotViewTooltip.
  ///
  /// In ko, this message translates to:
  /// **'학습 기록 보기'**
  String get snapshotViewTooltip;

  /// No description provided for @comparingWith.
  ///
  /// In ko, this message translates to:
  /// **'{time} 학습 기록과 비교 중'**
  String comparingWith(String time);

  /// No description provided for @compareOffTooltip.
  ///
  /// In ko, this message translates to:
  /// **'비교 해제'**
  String get compareOffTooltip;

  /// No description provided for @viewTooltip.
  ///
  /// In ko, this message translates to:
  /// **'{view} 보기'**
  String viewTooltip(String view);

  /// No description provided for @missingAsset.
  ///
  /// In ko, this message translates to:
  /// **'이미지 에셋이 없습니다'**
  String get missingAsset;

  /// No description provided for @learnedCount.
  ///
  /// In ko, this message translates to:
  /// **'학습 완료 {count}'**
  String learnedCount(int count);

  /// No description provided for @interestedCount.
  ///
  /// In ko, this message translates to:
  /// **'관심 {count}'**
  String interestedCount(int count);

  /// No description provided for @painPointCount.
  ///
  /// In ko, this message translates to:
  /// **'학습 포인트 {count}'**
  String painPointCount(int count);

  /// No description provided for @privacyBody1.
  ///
  /// In ko, this message translates to:
  /// **'근육 학습 지도는 사용자가 입력한 학습 노트 이름, 근육 학습 표시, 학습 포인트와 기록 시각을 앱 기능 제공을 위해 사용합니다.'**
  String get privacyBody1;

  /// No description provided for @privacyBody2.
  ///
  /// In ko, this message translates to:
  /// **'이 정보는 사용자의 기기에만 저장됩니다. 개발자 서버로 전송하거나 제3자와 공유하지 않으며, 광고 또는 분석 목적으로 사용하지 않습니다.'**
  String get privacyBody2;

  /// No description provided for @privacyBody3.
  ///
  /// In ko, this message translates to:
  /// **'앱을 삭제하면 기기에 저장된 정보도 함께 삭제됩니다. 문의: mkael0316@gmail.com'**
  String get privacyBody3;

  /// No description provided for @privacyBody4.
  ///
  /// In ko, this message translates to:
  /// **'이 앱은 인체 근육의 위치와 명칭을 익히기 위한 교육용 도구입니다.'**
  String get privacyBody4;

  /// No description provided for @privacyEffectiveDate.
  ///
  /// In ko, this message translates to:
  /// **'시행일: {date}'**
  String privacyEffectiveDate(String date);

  /// No description provided for @ok.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
