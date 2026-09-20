import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/muscle_mark.dart';

class ProfileStore {
  static const _profilesKey = 'muscle_learning_maps_v2';
  static const _selectedProfileKey = 'muscle_learning_selected_map_v2';
  static const _legacyProfilesKey = 'muscle_map_profiles_v1';
  static const _legacySelectedProfileKey = 'muscle_map_selected_profile_v1';

  Future<List<UserBodyProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyProfilesKey);
    await prefs.remove(_legacySelectedProfileKey);
    final rawProfiles = prefs.getString(_profilesKey);
    if (rawProfiles == null || rawProfiles.isEmpty) {
      final defaultProfile = UserBodyProfile.create('기본 학습 노트');
      await saveProfiles([defaultProfile]);
      await saveSelectedProfileId(defaultProfile.id);
      return [defaultProfile];
    }

    try {
      final decoded = jsonDecode(rawProfiles);
      if (decoded is! List) throw const FormatException('Invalid profile list');
      final profiles = decoded
          .whereType<Map>()
          .map(
            (item) => UserBodyProfile.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      if (profiles.isNotEmpty) return profiles;
    } catch (_) {
      // 손상된 로컬 데이터는 기본 학습 노트로 복구한다.
    }

    final fallbackProfile = UserBodyProfile.create('기본 학습 노트');
    await saveProfiles([fallbackProfile]);
    await saveSelectedProfileId(fallbackProfile.id);
    return [fallbackProfile];
  }

  Future<void> saveProfiles(List<UserBodyProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      profiles.map((profile) => profile.toJson()).toList(),
    );
    await prefs.setString(_profilesKey, encoded);
  }

  Future<String?> loadSelectedProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedProfileKey);
  }

  Future<void> saveSelectedProfileId(String? profileId) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileId == null) {
      await prefs.remove(_selectedProfileKey);
      return;
    }
    await prefs.setString(_selectedProfileKey, profileId);
  }
}
