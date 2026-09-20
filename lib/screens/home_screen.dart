import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/back_muscles.dart';
import '../data/front_muscles.dart';
import '../data/region_names.dart';
import '../l10n/app_localizations.dart';
import '../models/body_view.dart';
import '../models/muscle_mark.dart';
import '../painters/body_painter.dart';
import '../privacy_policy.dart';
import '../services/profile_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String _viewLabel(AppLocalizations l10n, BodyView view) =>
    view == BodyView.front ? l10n.viewFront : l10n.viewBack;

String _markTypeLabel(AppLocalizations l10n, MuscleMarkType type) =>
    type == MuscleMarkType.weak ? l10n.markTypeWeak : l10n.markTypeRelease;

String _toolLabel(AppLocalizations l10n, MarkTool tool) => switch (tool) {
  MarkTool.weak => l10n.toolWeak,
  MarkTool.release => l10n.toolRelease,
  MarkTool.painPoint => l10n.toolPainPoint,
};

class _HomeScreenState extends State<HomeScreen> {
  final ProfileStore _profileStore = ProfileStore();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  late final Map<BodyView, BodyViewConfig> _configs;
  final Map<BodyView, ui.Image?> _images = {};
  final Map<BodyView, _RegionMask?> _regionMasks = {};
  final Map<BodyView, ui.Image?> _markOverlayImages = {};
  final Map<BodyView, ui.Image?> _baselineOverlayImages = {};
  final Map<BodyView, Object?> _imageErrors = {};
  final Map<BodyView, String?> _lastTappedRegionIds = {};
  final Map<BodyView, Offset?> _lastTapRefPoint = {};
  int _overlayRequestToken = 0;

  List<UserBodyProfile> _profiles = [];
  String? _selectedProfileId;
  BodySnapshot? _baselineSnapshot;
  BodyView _currentView = BodyView.front;
  MarkTool _selectedTool = MarkTool.weak;
  bool _calibrationMode = false;
  bool _loadingProfiles = true;

  @override
  void initState() {
    super.initState();
    _configs = {
      BodyView.front: buildFrontViewConfig(),
      BodyView.back: buildBackViewConfig(),
    };
    for (final view in BodyView.values) {
      _loadImage(view);
    }
    unawaited(_loadProfiles());
  }

  UserBodyProfile? get _selectedProfile {
    if (_profiles.isEmpty) return null;
    return _profiles.firstWhere(
      (profile) => profile.id == _selectedProfileId,
      orElse: () => _profiles.first,
    );
  }

  Map<String, MuscleMarkType> get _currentMuscleMarks {
    return _selectedProfile?.marks[_currentView] ?? const {};
  }

  List<BodyPainPoint> get _currentPainPoints {
    return _selectedProfile?.painPoints[_currentView] ?? const [];
  }

  MuscleMarkType? get _lastTappedMarkType {
    final regionId = _lastTappedRegionIds[_currentView];
    if (regionId == null) return null;
    return _currentMuscleMarks[regionId];
  }

  RegionInfo? get _lastTappedRegionInfo {
    final regionId = _lastTappedRegionIds[_currentView];
    if (regionId == null) return null;
    final languageCode = Localizations.localeOf(context).languageCode;
    final info = regionInfoFor(_currentView, regionId, languageCode);
    return info.$1.isEmpty ? null : info;
  }

  int get _totalMarkCount => _selectedProfile?.totalCount ?? 0;

  int get _currentWeakCount => _currentMuscleMarks.values
      .where((mark) => mark == MuscleMarkType.weak)
      .length;

  int get _currentReleaseCount => _currentMuscleMarks.values
      .where((mark) => mark == MuscleMarkType.release)
      .length;

  int get _currentPainPointCount => _currentPainPoints.length;

  Future<void> _loadProfiles() async {
    final profiles = await _profileStore.loadProfiles();
    final selectedProfileId = await _profileStore.loadSelectedProfileId();
    if (!mounted) return;

    setState(() {
      _profiles = profiles;
      _selectedProfileId =
          profiles.any((profile) => profile.id == selectedProfileId)
          ? selectedProfileId
          : profiles.first.id;
      _loadingProfiles = false;
    });
    _pruneUnknownRegionMarks();
    unawaited(_refreshAllOverlays());
  }

  Future<void> _loadImage(BodyView view) async {
    final config = _configs[view]!;
    try {
      final data = await rootBundle.load(config.assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final maskData = await rootBundle.load(config.regionMaskPath);
      final maskCodec = await ui.instantiateImageCodec(
        maskData.buffer.asUint8List(),
      );
      final maskFrame = await maskCodec.getNextFrame();
      final maskByteData = await maskFrame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      final regionMask = maskByteData == null
          ? null
          : _RegionMask(
              width: maskFrame.image.width,
              height: maskFrame.image.height,
              pixels: Uint8List.fromList(maskByteData.buffer.asUint8List()),
              regionIds: _collectRegionIds(maskByteData.buffer.asUint8List()),
            );
      if (!mounted) return;
      setState(() {
        _images[view] = frame.image;
        _regionMasks[view] = regionMask;
      });
      _pruneUnknownRegionMarks();
      unawaited(_refreshOverlay(view));
      unawaited(_refreshOverlay(view, baseline: true));
    } catch (e) {
      if (!mounted) return;
      setState(() => _imageErrors[view] = e);
    }
  }

  Future<void> _persistProfiles() async {
    await _profileStore.saveProfiles(_profiles);
    await _profileStore.saveSelectedProfileId(_selectedProfileId);
  }

  Set<String> _collectRegionIds(Uint8List pixels) {
    final ids = <String>{};
    for (var index = 0; index < pixels.length; index += 4) {
      if (pixels[index + 3] <= 32) continue;
      ids.add(
        _RegionMask.regionId(
          pixels[index],
          pixels[index + 1],
          pixels[index + 2],
        ),
      );
    }
    return ids;
  }

  void _pruneUnknownRegionMarks() {
    if (_profiles.isEmpty || _regionMasks.isEmpty) return;
    var changed = false;

    void prune(BodyMarkMap marks) {
      for (final view in BodyView.values) {
        final validIds = _regionMasks[view]?.regionIds;
        if (validIds == null) continue;
        final before = marks[view]?.length ?? 0;
        marks[view]?.removeWhere((regionId, _) => !validIds.contains(regionId));
        changed = changed || before != (marks[view]?.length ?? 0);
      }
    }

    void prunePainPoints(BodyPainPointMap points) {
      for (final view in BodyView.values) {
        final mask = _regionMasks[view];
        if (mask == null) continue;
        final before = points[view]?.length ?? 0;
        points[view]?.removeWhere(
          (point) => !mask.containsAround(Offset(point.x, point.y)),
        );
        changed = changed || before != (points[view]?.length ?? 0);
      }
    }

    for (final profile in _profiles) {
      prune(profile.marks);
      prunePainPoints(profile.painPoints);
      for (final snapshot in profile.history) {
        prune(snapshot.marks);
        prunePainPoints(snapshot.painPoints);
      }
    }

    if (changed) {
      unawaited(_persistProfiles());
      unawaited(_refreshAllOverlays());
    }
  }

  Future<void> _refreshAllOverlays() async {
    for (final view in BodyView.values) {
      unawaited(_refreshOverlay(view));
      unawaited(_refreshOverlay(view, baseline: true));
    }
  }

  Future<void> _refreshOverlay(BodyView view, {bool baseline = false}) async {
    final requestToken = ++_overlayRequestToken;
    final regionMask = _regionMasks[view];
    if (regionMask == null) return;

    final marks = baseline
        ? _baselineSnapshot?.marks[view] ?? const <String, MuscleMarkType>{}
        : _selectedProfile?.marks[view] ?? const <String, MuscleMarkType>{};
    final overlayPixels = regionMask.buildOverlayPixels(
      marks,
      baseline: baseline,
    );
    final overlayImage = await _decodeRgbaImage(
      overlayPixels,
      regionMask.width,
      regionMask.height,
    );
    if (!mounted || requestToken < _overlayRequestToken - 4) return;

    setState(() {
      if (baseline) {
        _baselineOverlayImages[view] = overlayImage;
      } else {
        _markOverlayImages[view] = overlayImage;
      }
    });
  }

  Future<ui.Image> _decodeRgbaImage(Uint8List pixels, int width, int height) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  void _handleTapDown(TapDownDetails details, Size canvasSize) {
    final profile = _selectedProfile;
    if (profile == null) return;

    final config = _configs[_currentView]!;
    final transform = CanvasTransform.contain(canvasSize, config.referenceSize);
    final refPoint = transform.toReference(details.localPosition);
    final regionMask = _regionMasks[_currentView];
    final regionId = regionMask?.regionIdAt(refPoint);

    if (_selectedTool == MarkTool.painPoint) {
      if (regionMask?.containsAround(refPoint) != true) {
        if (_calibrationMode) {
          setState(() => _lastTapRefPoint[_currentView] = refPoint);
        }
        return;
      }

      setState(() {
        _lastTapRefPoint[_currentView] = refPoint;
        _lastTappedRegionIds[_currentView] = null;
        final points = profile.painPoints[_currentView]!;
        final existingIndex = _nearestPainPointIndex(points, refPoint);
        if (existingIndex == null) {
          points.add(BodyPainPoint.create(x: refPoint.dx, y: refPoint.dy));
        } else {
          points.removeAt(existingIndex);
        }
        profile.updatedAt = DateTime.now();
      });
      unawaited(_persistProfiles());
      return;
    }

    if (regionId == null) {
      if (_calibrationMode) {
        setState(() => _lastTapRefPoint[_currentView] = refPoint);
      }
      return;
    }

    final markType = _selectedTool.fillMarkType;
    if (markType == null) return;

    setState(() {
      _lastTapRefPoint[_currentView] = refPoint;
      final marks = profile.marks[_currentView]!;
      if (marks[regionId] == markType) {
        marks.remove(regionId);
      } else {
        marks[regionId] = markType;
      }
      profile.updatedAt = DateTime.now();
      _lastTappedRegionIds[_currentView] = regionId;
    });
    unawaited(_refreshOverlay(_currentView));
    unawaited(_persistProfiles());
  }

  int? _nearestPainPointIndex(List<BodyPainPoint> points, Offset refPoint) {
    const removeDistance = 18.0;
    for (var index = 0; index < points.length; index += 1) {
      final point = points[index];
      final distance = (Offset(point.x, point.y) - refPoint).distance;
      if (distance <= removeDistance) return index;
    }
    return null;
  }

  void _selectProfile(String profileId) {
    setState(() {
      _selectedProfileId = profileId;
      _baselineSnapshot = null;
      _lastTappedRegionIds.clear();
      _lastTapRefPoint.clear();
    });
    unawaited(_refreshAllOverlays());
    unawaited(_persistProfiles());
  }

  Future<void> _showAddUserDialog() async {
    final result = await _showProfileFormDialog(title: _l10n.noteAdd);
    if (result == null) return;

    final profile = UserBodyProfile.create(result.name);
    setState(() {
      _profiles.add(profile);
      _selectedProfileId = profile.id;
      _baselineSnapshot = null;
    });
    unawaited(_refreshAllOverlays());
    await _persistProfiles();
  }

  Future<void> _showEditUserDialog() async {
    final profile = _selectedProfile;
    if (profile == null) return;

    final result = await _showProfileFormDialog(
      title: _l10n.noteInfo,
      initialName: profile.name,
    );
    if (result == null) return;

    setState(() {
      profile.name = result.name;
      profile.updatedAt = DateTime.now();
    });
    await _persistProfiles();
    _showSnackBar(_l10n.noteInfoSaved);
  }

  Future<_ProfileFormResult?> _showProfileFormDialog({
    required String title,
    String initialName = '',
  }) async {
    var inputName = initialName;
    String? errorText;

    return showDialog<_ProfileFormResult>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final name = inputName.trim();
              if (name.isEmpty) {
                setDialogState(() => errorText = _l10n.noteNameRequired);
                return;
              }
              Navigator.of(context).pop(_ProfileFormResult(name: name));
            }

            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: initialName.isEmpty,
                      initialValue: initialName,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: _l10n.noteNameLabel,
                        hintText: _l10n.noteNameHint,
                        helperText: _l10n.noteNameHelper,
                        errorText: errorText,
                      ),
                      onChanged: (value) {
                        inputName = value;
                        if (errorText != null) {
                          setDialogState(() => errorText = null);
                        }
                      },
                      onFieldSubmitted: (_) => submit(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(onPressed: submit, child: Text(l10n.save)),
              ],
            );
          },
        );
      },
    );
  }

  void _saveCurrentSnapshot() {
    final profile = _selectedProfile;
    if (profile == null) return;
    if (profile.totalCount == 0) {
      _showSnackBar(_l10n.nothingToSave);
      return;
    }

    setState(() {
      profile.history.insert(0, profile.createSnapshot());
      if (profile.history.length > 30) {
        profile.history.removeRange(30, profile.history.length);
      }
      profile.updatedAt = DateTime.now();
    });
    unawaited(_persistProfiles());
    _showSnackBar(_l10n.snapshotSaved);
  }

  void _applySnapshot(BodySnapshot snapshot) {
    final profile = _selectedProfile;
    if (profile == null) return;

    setState(() {
      profile.marks = cloneBodyMarks(snapshot.marks);
      profile.painPoints = cloneBodyPainPoints(snapshot.painPoints);
      profile.updatedAt = DateTime.now();
      _baselineSnapshot = null;
      _lastTappedRegionIds.clear();
      _lastTapRefPoint.clear();
    });
    unawaited(_refreshAllOverlays());
    unawaited(_persistProfiles());
    _showSnackBar(_l10n.snapshotRestored);
  }

  void _showHistorySheet() {
    final profile = _selectedProfile;
    if (profile == null) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyTitle(profile.name),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                if (profile.history.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.noHistory)),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: profile.history.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final snapshot = profile.history[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_formatDateTime(snapshot.createdAt)),
                          subtitle: Text(
                            '${l10n.learnedCount(snapshot.weakCount)} · '
                            '${l10n.interestedCount(snapshot.releaseCount)} · '
                            '${l10n.painPointCount(snapshot.painPointCount)}',
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() => _baselineSnapshot = snapshot);
                                  unawaited(_refreshAllOverlays());
                                },
                                child: Text(l10n.compare),
                              ),
                              IconButton(
                                tooltip: l10n.restoreTooltip,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _applySnapshot(snapshot);
                                },
                                icon: const Icon(Icons.restore),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetCurrentView() {
    final profile = _selectedProfile;
    if (profile == null) return;
    final marks = profile.marks[_currentView]!;
    final painPoints = profile.painPoints[_currentView]!;
    if (marks.isEmpty &&
        painPoints.isEmpty &&
        _lastTapRefPoint[_currentView] == null) {
      return;
    }

    setState(() {
      marks.clear();
      painPoints.clear();
      profile.updatedAt = DateTime.now();
      _lastTappedRegionIds[_currentView] = null;
      _lastTapRefPoint[_currentView] = null;
    });
    unawaited(_refreshOverlay(_currentView));
    unawaited(_persistProfiles());
    _showSnackBar(_l10n.clearedView(_viewLabel(_l10n, _currentView)));
  }

  void _resetAllViews() {
    final profile = _selectedProfile;
    if (profile == null) return;

    setState(() {
      for (final view in BodyView.values) {
        profile.marks[view]!.clear();
        profile.painPoints[view]!.clear();
        _lastTappedRegionIds[view] = null;
        _lastTapRefPoint[view] = null;
      }
      profile.updatedAt = DateTime.now();
      _baselineSnapshot = null;
    });
    unawaited(_refreshAllOverlays());
    unawaited(_persistProfiles());
    _showSnackBar(_l10n.clearedAll);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _selectedProfile;
    final tapRef = _lastTapRefPoint[_currentView];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: SafeArea(
        child: _loadingProfiles
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape =
                      constraints.maxWidth > constraints.maxHeight;
                  // 최단 변은 가용 크기(max) 기준 — min은 환경에 따라 0이 될 수 있음.
                  final shortestSide =
                      constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
                  // 폰 가로(웹 등 회전 잠금이 안 되는 환경)에서는 세로 회전을 안내.
                  if (isLandscape && shortestSide < 600) {
                    return _buildRotatePrompt();
                  }
                  final useTabletLandscape =
                      constraints.maxWidth >= 840 &&
                      constraints.maxWidth > constraints.maxHeight;
                  if (useTabletLandscape) {
                    return _buildTabletLandscapeLayout(
                      constraints,
                      profile,
                      tapRef,
                    );
                  }
                  return _buildPortraitLayout(profile, tapRef);
                },
              ),
      ),
    );
  }

  Widget _buildRotatePrompt() {
    final l10n = _l10n;
    return ColoredBox(
      color: const Color(0xFFFFF8F6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.screen_rotation_alt,
              size: 56,
              color: const Color(0xFFD84A3A),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.rotatePromptTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B1D1B),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.rotatePromptBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF8F2018)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(UserBodyProfile? profile, Offset? tapRef) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.48,
              ),
              child: SingleChildScrollView(
                child: Column(children: _buildControlWidgets(profile)),
              ),
            ),
            Expanded(child: _BodyStage(child: _buildBody())),
            _buildInfoBar(tapRef),
          ],
        );
      },
    );
  }

  Widget _buildTabletLandscapeLayout(
    BoxConstraints constraints,
    UserBodyProfile? profile,
    Offset? tapRef,
  ) {
    final panelWidth = (constraints.maxWidth * 0.28)
        .clamp(312.0, 360.0)
        .toDouble();
    return Row(
      key: const ValueKey('tablet_landscape_shell'),
      children: [
        SizedBox(
          width: panelWidth,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF8F6), Color(0xFFFFECE8)],
              ),
              border: Border(right: BorderSide(color: Color(0x188F2018))),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  ..._buildControlWidgets(profile),
                  _buildInfoBar(tapRef),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
            child: _BodyStage(
              key: const ValueKey('tablet_body_stage'),
              margin: EdgeInsets.zero,
              borderRadius: 24,
              child: _buildBody(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildControlWidgets(UserBodyProfile? profile) {
    return [
      _AppHeader(
        currentView: _currentView,
        totalMarkCount: _totalMarkCount,
        calibrationMode: _calibrationMode,
        onToggleCalibration: () =>
            setState(() => _calibrationMode = !_calibrationMode),
        onResetCurrent: _resetCurrentView,
        onResetAll: _resetAllViews,
        onShowPrivacyPolicy: () => PrivacyPolicyDialog.show(context),
      ),
      _ProfileBar(
        profiles: _profiles,
        selectedProfile: profile,
        baselineSnapshot: _baselineSnapshot,
        onProfileChanged: _selectProfile,
        onEditProfile: _showEditUserDialog,
        onAddProfile: _showAddUserDialog,
        onSaveSnapshot: _saveCurrentSnapshot,
        onShowHistory: _showHistorySheet,
        onClearBaseline: () {
          setState(() => _baselineSnapshot = null);
          unawaited(_refreshAllOverlays());
        },
      ),
      _ViewSwitcher(
        currentView: _currentView,
        markCounts: {
          for (final v in BodyView.values) v: profile?.viewCount(v) ?? 0,
        },
        onChanged: (v) => setState(() => _currentView = v),
      ),
      _MarkToolSwitcher(
        selectedTool: _selectedTool,
        weakCount: profile?.weakCount ?? 0,
        releaseCount: profile?.releaseCount ?? 0,
        painPointCount: profile?.painPointCount ?? 0,
        onChanged: (tool) => setState(() => _selectedTool = tool),
      ),
    ];
  }

  Widget _buildInfoBar(Offset? tapRef) {
    return _InfoBar(
      hasSelection: _lastTappedRegionIds[_currentView] != null,
      selectedTool: _selectedTool,
      muscleMarkType: _lastTappedMarkType,
      regionInfo: _lastTappedRegionInfo,
      lastTapRef: tapRef,
      weakCount: _currentWeakCount,
      releaseCount: _currentReleaseCount,
      painPointCount: _currentPainPointCount,
      totalMarkCount: _totalMarkCount,
      showCoords: _calibrationMode,
      isComparing: _baselineSnapshot != null,
    );
  }

  Widget _buildBody() {
    final error = _imageErrors[_currentView];
    if (error != null) {
      return _MissingAssetView(
        error: error,
        assetPath: _configs[_currentView]!.assetPath,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handleTapDown(details, size),
          child: CustomPaint(
            size: size,
            painter: BodyPainter(
              config: _configs[_currentView]!,
              bodyImage: _images[_currentView],
              markOverlayImage: _markOverlayImages[_currentView],
              baselineOverlayImage: _baselineOverlayImages[_currentView],
              painPoints: List<BodyPainPoint>.of(
                _selectedProfile?.painPoints[_currentView] ?? const [],
              ),
              baselinePainPoints: List<BodyPainPoint>.of(
                _baselineSnapshot?.painPoints[_currentView] ?? const [],
              ),
              calibrationMode: _calibrationMode,
              lastTapPoint: _calibrationMode
                  ? _lastTapRefPoint[_currentView]
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _RegionMask {
  const _RegionMask({
    required this.width,
    required this.height,
    required this.pixels,
    required this.regionIds,
  });

  final int width;
  final int height;
  final Uint8List pixels;
  final Set<String> regionIds;

  String? regionIdAt(Offset point) {
    final x = point.dx.round();
    final y = point.dy.round();
    if (x < 0 || y < 0 || x >= width || y >= height) return null;
    final index = (y * width + x) * 4;
    final alpha = pixels[index + 3];
    if (alpha <= 32) return null;
    return regionId(pixels[index], pixels[index + 1], pixels[index + 2]);
  }

  bool containsAround(Offset point, {int radius = 4}) {
    final centerX = point.dx.round();
    final centerY = point.dy.round();
    if (centerX < 0 || centerY < 0 || centerX >= width || centerY >= height) {
      return false;
    }

    for (var y = centerY - radius; y <= centerY + radius; y += 1) {
      if (y < 0 || y >= height) continue;
      for (var x = centerX - radius; x <= centerX + radius; x += 1) {
        if (x < 0 || x >= width) continue;
        final index = (y * width + x) * 4;
        if (pixels[index + 3] > 32) return true;
      }
    }
    return false;
  }

  Uint8List buildOverlayPixels(
    Map<String, MuscleMarkType> marks, {
    required bool baseline,
  }) {
    final out = Uint8List(width * height * 4);
    if (marks.isEmpty) return out;

    for (var index = 0; index < pixels.length; index += 4) {
      final alpha = pixels[index + 3];
      if (alpha <= 32) continue;
      final id = regionId(pixels[index], pixels[index + 1], pixels[index + 2]);
      final markType = marks[id];
      if (markType == null) continue;

      final color = _overlayColor(markType, baseline: baseline);
      out[index] = color.red;
      out[index + 1] = color.green;
      out[index + 2] = color.blue;
      out[index + 3] = color.alpha;
    }
    return out;
  }

  static String regionId(int r, int g, int b) {
    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    return '${hex(r)}${hex(g)}${hex(b)}';
  }

  _OverlayRgba _overlayColor(MuscleMarkType type, {required bool baseline}) {
    switch (type) {
      case MuscleMarkType.weak:
        return _OverlayRgba(37, 119, 217, baseline ? 72 : 178);
      case MuscleMarkType.release:
        return _OverlayRgba(216, 74, 58, baseline ? 76 : 190);
    }
  }
}

class _OverlayRgba {
  const _OverlayRgba(this.red, this.green, this.blue, this.alpha);

  final int red;
  final int green;
  final int blue;
  final int alpha;
}

class _ProfileFormResult {
  const _ProfileFormResult({required this.name});

  final String name;
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({
    required this.currentView,
    required this.totalMarkCount,
    required this.calibrationMode,
    required this.onToggleCalibration,
    required this.onResetCurrent,
    required this.onResetAll,
    required this.onShowPrivacyPolicy,
  });

  final BodyView currentView;
  final int totalMarkCount;
  final bool calibrationMode;
  final VoidCallback onToggleCalibration;
  final VoidCallback onResetCurrent;
  final VoidCallback onResetAll;
  final VoidCallback onShowPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8F6), Color(0xFFFFECE8)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFD84A3A),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD84A3A).withValues(alpha: 0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.accessibility_new, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _StatusChip(
                      icon: currentView == BodyView.front
                          ? Icons.front_hand
                          : Icons.accessibility_new,
                      label: _viewLabel(l10n, currentView),
                    ),
                    _StatusChip(
                      icon: Icons.touch_app,
                      label: l10n.marksCount(totalMarkCount),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            tooltip: calibrationMode
                ? l10n.calibrationOnTooltip
                : l10n.calibrationOffTooltip,
            icon: calibrationMode ? Icons.grid_off : Icons.grid_on,
            selected: calibrationMode,
            onPressed: onToggleCalibration,
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            tooltip: l10n.appMenuTooltip,
            onSelected: (value) {
              if (value == 'view') onResetCurrent();
              if (value == 'all') onResetAll();
              if (value == 'privacy') onShowPrivacyPolicy();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'view',
                child: Text(l10n.clearViewOnly(_viewLabel(l10n, currentView))),
              ),
              PopupMenuItem(value: 'all', child: Text(l10n.clearAll)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'privacy', child: Text(l10n.privacyPolicy)),
            ],
            child: const _HeaderIconButtonShell(icon: Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

class _ProfileBar extends StatelessWidget {
  const _ProfileBar({
    required this.profiles,
    required this.selectedProfile,
    required this.baselineSnapshot,
    required this.onProfileChanged,
    required this.onEditProfile,
    required this.onAddProfile,
    required this.onSaveSnapshot,
    required this.onShowHistory,
    required this.onClearBaseline,
  });

  final List<UserBodyProfile> profiles;
  final UserBodyProfile? selectedProfile;
  final BodySnapshot? baselineSnapshot;
  final ValueChanged<String> onProfileChanged;
  final VoidCallback onEditProfile;
  final VoidCallback onAddProfile;
  final VoidCallback onSaveSnapshot;
  final VoidCallback onShowHistory;
  final VoidCallback onClearBaseline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = selectedProfile;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x1F8F2018)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selected?.id,
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more),
                      items: profiles
                          .map(
                            (profile) => DropdownMenuItem(
                              value: profile.id,
                              child: Text(
                                profile.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onProfileChanged(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SmallIconButton(
                tooltip: l10n.noteInfo,
                icon: Icons.edit_note,
                onPressed: onEditProfile,
              ),
              const SizedBox(width: 6),
              _SmallIconButton(
                tooltip: l10n.noteAdd,
                icon: Icons.note_add_outlined,
                onPressed: onAddProfile,
              ),
              const SizedBox(width: 6),
              _SmallIconButton(
                tooltip: l10n.snapshotSaveTooltip,
                icon: Icons.bookmark_add,
                onPressed: onSaveSnapshot,
              ),
              const SizedBox(width: 6),
              _SmallIconButton(
                tooltip: l10n.snapshotViewTooltip,
                icon: Icons.history,
                onPressed: onShowHistory,
              ),
            ],
          ),
          if (baselineSnapshot != null) ...[
            const SizedBox(height: 8),
            _CompareBanner(
              label: l10n.comparingWith(
                _formatDateTime(baselineSnapshot!.createdAt),
              ),
              onClear: onClearBaseline,
            ),
          ],
        ],
      ),
    );
  }
}

class _MarkToolSwitcher extends StatelessWidget {
  const _MarkToolSwitcher({
    required this.selectedTool,
    required this.weakCount,
    required this.releaseCount,
    required this.painPointCount,
    required this.onChanged,
  });

  final MarkTool selectedTool;
  final int weakCount;
  final int releaseCount;
  final int painPointCount;
  final ValueChanged<MarkTool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segments = [
            _ToolSegment(
              label: l10n.toolWeak,
              count: weakCount,
              icon: Icons.water_drop,
              color: const Color(0xFF2577D9),
              selected: selectedTool == MarkTool.weak,
              onTap: () => onChanged(MarkTool.weak),
            ),
            _ToolSegment(
              label: l10n.toolRelease,
              count: releaseCount,
              icon: Icons.radio_button_checked,
              color: const Color(0xFFD84A3A),
              selected: selectedTool == MarkTool.release,
              onTap: () => onChanged(MarkTool.release),
            ),
            _ToolSegment(
              label: l10n.toolPainPoint,
              count: painPointCount,
              icon: Icons.add_location_alt,
              color: const Color(0xFFE53935),
              selected: selectedTool == MarkTool.painPoint,
              onTap: () => onChanged(MarkTool.painPoint),
            ),
          ];

          if (constraints.maxWidth >= 390) {
            return Row(
              children: [
                for (var index = 0; index < segments.length; index += 1) ...[
                  if (index > 0) const SizedBox(width: 6),
                  Expanded(child: segments[index]),
                ],
              ],
            );
          }

          final itemWidth = (constraints.maxWidth - 6) / 2;
          return Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SizedBox(width: itemWidth, child: segments[0]),
              SizedBox(width: itemWidth, child: segments[1]),
              SizedBox(width: constraints.maxWidth, child: segments[2]),
            ],
          );
        },
      ),
    );
  }
}

class _ToolSegment extends StatelessWidget {
  const _ToolSegment({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : const Color(0x1F8F2018),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$label $count',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? color : const Color(0xFF6D4B46),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onPressed,
        child: _HeaderIconButtonShell(icon: icon, selected: selected),
      ),
    );
  }
}

class _HeaderIconButtonShell extends StatelessWidget {
  const _HeaderIconButtonShell({required this.icon, this.selected = false});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD84A3A) : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0x1F8F2018)),
      ),
      child: Icon(
        icon,
        color: selected ? Colors.white : const Color(0xFF6D4B46),
        size: 22,
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onPressed,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0x1F8F2018)),
          ),
          child: Icon(icon, color: const Color(0xFF6D4B46), size: 21),
        ),
      ),
    );
  }
}

class _CompareBanner extends StatelessWidget {
  const _CompareBanner({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x332577D9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, size: 17, color: Color(0xFF2577D9)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF245084),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.compareOffTooltip,
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x18A43A2F)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFD84A3A)),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF6D4B46),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({
    required this.currentView,
    required this.markCounts,
    required this.onChanged,
  });

  final BodyView currentView;
  final Map<BodyView, int> markCounts;
  final ValueChanged<BodyView> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1F8F2018)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8F2018).withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: BodyView.values.map((view) {
            final selected = currentView == view;
            final count = markCounts[view] ?? 0;
            return Expanded(
              child: Tooltip(
                message: l10n.viewTooltip(_viewLabel(l10n, view)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(view),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFDDD7)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: selected
                              ? const Icon(
                                  Icons.check_circle,
                                  key: ValueKey('selected'),
                                  size: 17,
                                  color: Color(0xFFD84A3A),
                                )
                              : Icon(
                                  view == BodyView.front
                                      ? Icons.front_hand
                                      : Icons.accessibility_new,
                                  key: ValueKey(view),
                                  size: 17,
                                  color: const Color(0xFF8A6B65),
                                ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            count > 0
                                ? '${_viewLabel(l10n, view)} $count'
                                : _viewLabel(l10n, view),
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? const Color(0xFF8F2018)
                                  : const Color(0xFF6D4B46),
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BodyStage extends StatelessWidget {
  const _BodyStage({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(14, 0, 14, 10),
    this.borderRadius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0x188F2018)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8F2018).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.18),
                  radius: 0.95,
                  colors: [
                    const Color(0xFFFFF4F1),
                    Colors.white,
                    const Color(0xFFFFF9F7),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _MissingAssetView extends StatelessWidget {
  const _MissingAssetView({required this.error, required this.assetPath});

  final Object error;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.missingAsset,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(assetPath, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              '$error',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({
    required this.hasSelection,
    required this.selectedTool,
    required this.muscleMarkType,
    required this.regionInfo,
    required this.lastTapRef,
    required this.weakCount,
    required this.releaseCount,
    required this.painPointCount,
    required this.totalMarkCount,
    required this.showCoords,
    required this.isComparing,
  });

  final bool hasSelection;
  final MarkTool selectedTool;
  final MuscleMarkType? muscleMarkType;
  final RegionInfo? regionInfo;
  final Offset? lastTapRef;
  final int weakCount;
  final int releaseCount;
  final int painPointCount;
  final int totalMarkCount;
  final bool showCoords;
  final bool isComparing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasPainPointSelection =
        !hasSelection &&
        selectedTool == MarkTool.painPoint &&
        lastTapRef != null;
    final subtitle = hasSelection
        ? () {
            final latin = regionInfo?.$2;
            final mark = muscleMarkType == null
                ? l10n.noMark
                : _markTypeLabel(l10n, muscleMarkType!);
            return latin == null ? mark : '$latin · $mark';
          }()
        : l10n.tapToMark(_toolLabel(l10n, selectedTool));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1F8F2018)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8F2018).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE7C9C3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: hasSelection || hasPainPointSelection
                      ? const Color(0xFFFFDDD7)
                      : const Color(0xFFF6EEEB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  hasSelection || hasPainPointSelection
                      ? Icons.my_location
                      : Icons.touch_app,
                  color: hasSelection || hasPainPointSelection
                      ? const Color(0xFFD84A3A)
                      : const Color(0xFF8A6B65),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSelection
                          ? (regionInfo == null || regionInfo!.$1.isEmpty
                                ? l10n.selectedRegion
                                : regionInfo!.$1)
                          : hasPainPointSelection
                          ? l10n.studyPointTitle
                          : l10n.pressToExplore,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7B625D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showCoords && lastTapRef != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.coordinatesLabel(
                          lastTapRef!.dx.toStringAsFixed(0),
                          lastTapRef!.dy.toStringAsFixed(0),
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF1B5E20),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _MarkBadge(
                weakCount: weakCount,
                releaseCount: releaseCount,
                painPointCount: painPointCount,
                total: totalMarkCount,
              ),
            ],
          ),
          if (!hasSelection || isComparing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _HintPill(
                  icon: Icons.water_drop,
                  label: l10n.hintBlue,
                  color: const Color(0xFF2577D9),
                ),
                const SizedBox(width: 6),
                _HintPill(
                  icon: Icons.radio_button_checked,
                  label: isComparing ? l10n.hintFaint : l10n.hintRed,
                  color: const Color(0xFFD84A3A),
                ),
                const SizedBox(width: 6),
                _HintPill(
                  icon: Icons.add_location_alt,
                  label: l10n.hintDot,
                  color: const Color(0xFFD84A3A),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF6D4B46),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkBadge extends StatelessWidget {
  const _MarkBadge({
    required this.weakCount,
    required this.releaseCount,
    required this.painPointCount,
    required this.total,
  });

  final int weakCount;
  final int releaseCount;
  final int painPointCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 70),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: total > 0 ? const Color(0xFF2B1D1B) : const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$weakCount/$releaseCount/$painPointCount',
            style: theme.textTheme.titleSmall?.copyWith(
              color: total > 0 ? Colors.white : const Color(0xFF8A6B65),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            l10n.badgeSummary,
            style: theme.textTheme.labelSmall?.copyWith(
              color: total > 0
                  ? Colors.white.withValues(alpha: 0.88)
                  : const Color(0xFF8A6B65),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${value.year}.${two(value.month)}.${two(value.day)} '
      '${two(value.hour)}:${two(value.minute)}';
}
