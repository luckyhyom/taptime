import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import 'package:taptime/core/constants/app_constants.dart';
import 'package:taptime/core/providers/app_providers.dart';
import 'package:taptime/core/theme/app_colors.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/shared/models/location_trigger.dart';

/// 지도에서 장소를 선택하고 LocationTrigger를 생성하는 화면.
///
/// 사용자가 지도를 탭하면 핀 + 반경 원이 표시되고,
/// 하단 패널에서 장소 이름과 반경을 설정한 뒤 저장한다.
///
/// 저장 시 LocationTrigger를 DB에 생성하고, 그 ID를 pop 결과로 반환한다.
/// 프리셋 폼에서 이 ID를 받아 프리셋에 연결한다.
///
/// [existingTriggerId]가 있으면 기존 트리거를 로드하여 수정 모드로 동작한다.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, this.existingTriggerId});

  final String? existingTriggerId;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _mapController = MapController();
  final _nameController = TextEditingController();

  // ── 폼 상태 ──────────────────────────────────────────────────
  // 이 화면에서만 사용하고 버려지는 일시적 상태이므로
  // 별도 Notifier 없이 setState로 관리한다.

  /// 사용자가 선택한 좌표. null이면 아직 선택 전.
  LatLng? _selectedPosition;

  /// 지오펜스 반경 (미터)
  double _radiusMeters = AppConstants.locationRadiusDefault.toDouble();

  /// 진입 시 알림 여부
  bool _notifyOnEntry = true;

  /// 퇴장 시 알림 여부
  bool _notifyOnExit = false;

  /// 확인 없이 타이머 자동 시작 여부
  bool _autoStart = false;

  /// 저장 중 여부 (중복 저장 방지)
  bool _isSaving = false;

  /// 기존 트리거 로딩 중 여부
  bool _isLoading = false;

  // 향후 기기의 현재 위치를 사용하도록 개선 예정
  static const _defaultCenter = LatLng(37.5665, 126.978);
  static const _defaultZoom = 15.0;

  @override
  void initState() {
    super.initState();
    if (widget.existingTriggerId != null) {
      _loadExistingTrigger();
    }
  }

  /// 수정 모드: 기존 트리거 데이터를 불러온다.
  Future<void> _loadExistingTrigger() async {
    setState(() => _isLoading = true);

    final repo = ref.read(locationTriggerRepositoryProvider);
    final trigger = await repo.getTriggerById(widget.existingTriggerId!);

    if (trigger != null && mounted) {
      setState(() {
        _selectedPosition = LatLng(trigger.latitude, trigger.longitude);
        _radiusMeters = trigger.radiusMeters.toDouble();
        _notifyOnEntry = trigger.notifyOnEntry;
        _notifyOnExit = trigger.notifyOnExit;
        _autoStart = trigger.autoStart;
        _nameController.text = trigger.placeName;
        _isLoading = false;
      });

      // MapController는 FlutterMap이 빌드된 후에만 사용 가능하다.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedPosition != null) {
          _mapController.move(_selectedPosition!, _defaultZoom);
        }
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingTriggerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '장소 수정' : '장소 등록'),
        actions: [
          // 저장 버튼: ValueListenableBuilder로 이름 입력 변화 시에만 리빌드한다.
          // 지도 전체를 리빌드하지 않기 위해 별도로 감싼다.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nameController,
            builder: (context, value, _) {
              final canSave = _selectedPosition != null && value.text.trim().isNotEmpty && !_isSaving;
              return TextButton(
                onPressed: canSave ? () => _save(isEditing) : null,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('저장'),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _buildMap(theme)),
                if (_selectedPosition != null) _buildInputPanel(theme) else _buildHintPanel(theme),
              ],
            ),
    );
  }

  // ── 지도 ───────────────────────────────────────────────────

  Widget _buildMap(ThemeData theme) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _selectedPosition ?? _defaultCenter,
        initialZoom: _defaultZoom,
        onTap: (tapPosition, latLng) {
          setState(() => _selectedPosition = latLng);
        },
      ),
      children: [
        // 무료 OSM 타일. 상용 앱에서는 이용약관 확인 필요.
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.taptime.taptime',
        ),

        if (_selectedPosition != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _selectedPosition!,
                radius: _radiusMeters,
                useRadiusInMeter: true,
                color: AppColors.coral.withValues(alpha: 0.15),
                borderColor: AppColors.coral.withValues(alpha: 0.6),
                borderStrokeWidth: 2,
              ),
            ],
          ),

        if (_selectedPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: AppColors.coral, size: 40),
              ),
            ],
          ),
      ],
    );
  }

  // ── 안내 패널 (좌표 선택 전) ─────────────────────────────────

  Widget _buildHintPanel(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sectionGap),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
      ),
      child: Text(
        '지도를 탭하여 장소를 선택하세요',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  // ── 입력 패널 (좌표 선택 후) ─────────────────────────────────

  Widget _buildInputPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.padding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 장소 이름 ────────────────────────────────
            TextField(
              controller: _nameController,
              maxLength: AppConstants.locationNameMaxLength,
              decoration: const InputDecoration(
                labelText: '장소 이름',
                hintText: '예: 도서관, 헬스장, 카페',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: AppSpacing.gap),

            // ── 반경 슬라이더 ────────────────────────────
            Row(
              children: [
                Text('반경', style: theme.textTheme.labelLarge),
                const Spacer(),
                Text('${_radiusMeters.round()}m', style: theme.textTheme.bodyMedium),
              ],
            ),
            // divisions로 19단계(50m씩)로 snap된다.
            Slider(
              value: _radiusMeters,
              min: AppConstants.locationRadiusMin.toDouble(),
              max: AppConstants.locationRadiusMax.toDouble(),
              divisions: 19,
              label: '${_radiusMeters.round()}m',
              onChanged: (value) => setState(() => _radiusMeters = value),
            ),

            const SizedBox(height: AppSpacing.gap),

            // ── 옵션 토글 ─────────────────────────────
            SwitchListTile(
              title: const Text('도착 시 알림'),
              subtitle: const Text('이 장소에 도착하면 알림을 받습니다'),
              value: _notifyOnEntry,
              onChanged: (v) => setState(() => _notifyOnEntry = v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('떠날 때 알림'),
              value: _notifyOnExit,
              onChanged: (v) => setState(() => _notifyOnExit = v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('자동 시작'),
              subtitle: const Text('도착 시 확인 없이 타이머를 바로 시작합니다'),
              value: _autoStart,
              onChanged: (v) => setState(() => _autoStart = v),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  // ── 저장 ───────────────────────────────────────────────────

  Future<void> _save(bool isEditing) async {
    final name = _nameController.text.trim();
    if (_selectedPosition == null || name.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(locationTriggerRepositoryProvider);
      final now = DateTime.now();

      if (isEditing) {
        final existing = await repo.getTriggerById(widget.existingTriggerId!);
        if (existing == null) throw Exception('위치 트리거를 찾을 수 없습니다.');

        await repo.updateTrigger(existing.copyWith(
          placeName: name,
          latitude: _selectedPosition!.latitude,
          longitude: _selectedPosition!.longitude,
          radiusMeters: _radiusMeters.round(),
          notifyOnEntry: _notifyOnEntry,
          notifyOnExit: _notifyOnExit,
          autoStart: _autoStart,
          updatedAt: now,
        ));

        if (mounted) context.pop(widget.existingTriggerId);
      } else {
        final trigger = LocationTrigger(
          id: const Uuid().v4(),
          placeName: name,
          latitude: _selectedPosition!.latitude,
          longitude: _selectedPosition!.longitude,
          radiusMeters: _radiusMeters.round(),
          notifyOnEntry: _notifyOnEntry,
          notifyOnExit: _notifyOnExit,
          autoStart: _autoStart,
          createdAt: now,
        );

        await repo.createTrigger(trigger);

        if (mounted) context.pop(trigger.id);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}
