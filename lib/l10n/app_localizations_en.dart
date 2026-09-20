// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Muscle Study Map';

  @override
  String get viewFront => 'Front';

  @override
  String get viewBack => 'Back';

  @override
  String get markTypeWeak => 'Learned muscle';

  @override
  String get markTypeRelease => 'Interested muscle';

  @override
  String get markTypePainPoint => 'Study point';

  @override
  String get toolWeak => 'Learned';

  @override
  String get toolRelease => 'Interested';

  @override
  String get toolPainPoint => 'Study point';

  @override
  String get noMark => 'No mark';

  @override
  String tapToMark(String tool) {
    return 'Tap a body area with the $tool tool';
  }

  @override
  String get selectedRegion => 'Selected area';

  @override
  String get studyPointTitle => 'Study point';

  @override
  String get pressToExplore => 'Tap an area to explore';

  @override
  String coordinatesLabel(String x, String y) {
    return 'Coords: ($x, $y)';
  }

  @override
  String get hintBlue => 'Blue: learned';

  @override
  String get hintRed => 'Red: interested';

  @override
  String get hintFaint => 'Faint: previous';

  @override
  String get hintDot => 'Dot: study note';

  @override
  String get badgeSummary => 'Blue/Red/Dot';

  @override
  String get noteAdd => 'Add study note';

  @override
  String get noteInfo => 'Study note info';

  @override
  String get noteInfoSaved => 'Study note info saved';

  @override
  String get noteNameRequired => 'Enter a study note name';

  @override
  String get noteNameLabel => 'Study note name';

  @override
  String get noteNameHint => 'e.g. Upper body review';

  @override
  String get noteNameHelper => 'Organize study marks by topic';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get nothingToSave => 'No marks to save';

  @override
  String get snapshotSaved => 'Current marks saved to history';

  @override
  String get snapshotRestored => 'Selected history restored to current view';

  @override
  String historyTitle(String name) {
    return '$name history';
  }

  @override
  String get noHistory => 'No saved history';

  @override
  String get compare => 'Compare';

  @override
  String get restoreTooltip => 'Restore to current view';

  @override
  String clearedView(String view) {
    return 'Cleared $view marks';
  }

  @override
  String get clearedAll => 'Cleared all marks';

  @override
  String get rotatePromptTitle => 'Please rotate to portrait';

  @override
  String get rotatePromptBody => 'This screen works in portrait mode.';

  @override
  String marksCount(int count) {
    return 'Marks: $count';
  }

  @override
  String get calibrationOnTooltip => 'Turn calibration off';

  @override
  String get calibrationOffTooltip => 'Turn calibration on';

  @override
  String get appMenuTooltip => 'App menu';

  @override
  String clearViewOnly(String view) {
    return 'Clear $view only';
  }

  @override
  String get clearAll => 'Clear all';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get snapshotSaveTooltip => 'Save history';

  @override
  String get snapshotViewTooltip => 'View history';

  @override
  String comparingWith(String time) {
    return 'Comparing with $time history';
  }

  @override
  String get compareOffTooltip => 'Stop comparing';

  @override
  String viewTooltip(String view) {
    return '$view view';
  }

  @override
  String get missingAsset => 'Image asset missing';

  @override
  String learnedCount(int count) {
    return 'Learned $count';
  }

  @override
  String interestedCount(int count) {
    return 'Interested $count';
  }

  @override
  String painPointCount(int count) {
    return 'Study points $count';
  }

  @override
  String get privacyBody1 =>
      'Muscle Study Map uses the study note names, muscle marks, study points and timestamps you enter to provide app features.';

  @override
  String get privacyBody2 =>
      'This information is stored only on your device. It is never sent to a developer server, shared with third parties, or used for advertising or analytics.';

  @override
  String get privacyBody3 =>
      'Deleting the app also deletes the information stored on your device. Contact: mkael0316@gmail.com';

  @override
  String get privacyBody4 =>
      'This app is an educational tool for learning the location and names of human muscles.';

  @override
  String privacyEffectiveDate(String date) {
    return 'Effective date: $date';
  }

  @override
  String get ok => 'OK';
}
