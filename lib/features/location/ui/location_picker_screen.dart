import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import 'package:taptime/core/config/supabase_config.dart';
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
  final _searchController = TextEditingController();

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

  /// 현재 위치
  LatLng? _currentPosition;

  /// 검색 결과 목록
  List<_SearchResult> _searchResults = [];

  /// 검색 중 여부
  bool _isSearching = false;

  /// 검색 패널 표시 여부
  bool _showSearchPanel = false;

  /// 검색 디바운스 타이머
  Timer? _searchDebounce;

  // 현재 위치를 가져오지 못하면 서울시청으로 fallback
  static const _fallbackCenter = LatLng(37.5665, 126.978);
  static const _defaultZoom = 15.0;

  @override
  void initState() {
    super.initState();
    if (widget.existingTriggerId != null) {
      _loadExistingTrigger();
    } else {
      _loadCurrentLocation();
    }
  }

  /// 현재 위치를 가져와서 지도 초기 중심으로 사용한다.
  /// 권한 거부 또는 오류 시 서울시청 fallback.
  Future<void> _loadCurrentLocation() async {
    try {
      // 위치 서비스가 꺼져 있으면 시도하지 않는다
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();

      // denied면 권한 요청 (deniedForever면 시스템 설정에서만 변경 가능)
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() => _currentPosition = latLng);

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(latLng, _defaultZoom);
        });
      }
    } on Exception {
      // 위치 가져오기 실패 — fallback 사용
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
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingTriggerId != null;

    return Scaffold(
      // 키보드가 올라와도 레이아웃을 밀어올리지 않는다.
      // 하단 입력 패널이 지도와 검색을 가리는 것을 방지.
      resizeToAvoidBottomInset: false,
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
                Expanded(
                  child: Stack(
                    children: [
                      _buildMap(theme),
                      _buildMapControls(theme),
                      if (_showSearchPanel) _buildSearchPanel(theme),
                    ],
                  ),
                ),
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
        initialCenter: _selectedPosition ?? _currentPosition ?? _fallbackCenter,
        initialZoom: _defaultZoom,
        onTap: (tapPosition, latLng) {
          setState(() {
            _selectedPosition = latLng;
            _showSearchPanel = false;
          });
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
                width: 48,
                height: 48,
                alignment: Alignment.topCenter,
                child: const _MapPin(),
              ),
            ],
          ),

        // 현재 위치 마커 (선택 위치와 별도)
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ── 지도 컨트롤 (줌, 검색, 현재 위치) ─────────────────────────

  Widget _buildMapControls(ThemeData theme) {
    return Positioned(
      right: AppSpacing.gap,
      top: AppSpacing.gap,
      child: Column(
        children: [
          // 검색 버튼
          _MapControlButton(
            icon: Icons.search,
            onTap: () => setState(() => _showSearchPanel = !_showSearchPanel),
          ),
          const SizedBox(height: AppSpacing.grid),
          // 현재 위치 버튼
          _MapControlButton(
            icon: Icons.my_location,
            onTap: _moveToCurrentLocation,
          ),
          const SizedBox(height: AppSpacing.grid),
          // 줌 인
          _MapControlButton(
            icon: Icons.add,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 4),
          // 줌 아웃
          _MapControlButton(
            icon: Icons.remove,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
        ],
      ),
    );
  }

  void _moveToCurrentLocation() {
    final target = _currentPosition;
    if (target != null) {
      _mapController.move(target, _defaultZoom);
    } else {
      // 현재 위치 없으면 다시 시도
      _loadCurrentLocation();
    }
  }

  // ── 검색 패널 ──────────────────────────────────────────────

  Widget _buildSearchPanel(ThemeData theme) {
    return Positioned(
      left: AppSpacing.gap,
      right: 56, // 컨트롤 버튼과 겹치지 않게
      top: AppSpacing.gap,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 검색 입력
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '주소 또는 장소명 검색',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _showSearchPanel = false;
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _onSearchChanged,
            ),

            // 검색 결과 목록
            if (_searchResults.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on_outlined, size: 20),
                      title: Text(result.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        [if (result.category != null) result.category!, if (result.address != null) result.address!]
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => _selectSearchResult(result),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 500), () => _performSearch(query.trim()));
  }

  /// Kakao Local API (키워드 검색)로 장소를 검색한다.
  /// REST API 키는 .env → String.fromEnvironment로 주입된다.
  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    final apiKey = SupabaseConfig.kakaoRestApiKey;
    if (apiKey == null) {
      // API 키 없으면 검색 불가
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      // 현재 위치가 있으면 가까운 순으로 정렬
      final pos = _currentPosition;
      final locationParams = pos != null ? '&x=${pos.longitude}&y=${pos.latitude}&sort=distance' : '';

      final uri = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json'
        '?query=${Uri.encodeComponent(query)}'
        '&size=7'
        '$locationParams',
      );

      final response = await http.get(uri, headers: {'Authorization': 'KakaoAK $apiKey'});

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final documents = (body['documents'] as List<dynamic>?) ?? [];
        setState(() {
          _searchResults = documents.cast<Map<String, dynamic>>().map((item) {
            return _SearchResult(
              name: item['place_name'] as String? ?? '',
              address: item['road_address_name'] as String? ?? item['address_name'] as String?,
              lat: double.parse(item['y'] as String),
              lon: double.parse(item['x'] as String),
              category: item['category_group_name'] as String?,
            );
          }).toList();
        });
      }
    } on Exception {
      // 검색 실패 — 무시
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(_SearchResult result) {
    final latLng = LatLng(result.lat, result.lon);
    setState(() {
      _selectedPosition = latLng;
      _showSearchPanel = false;
      _searchResults = [];
      _searchController.clear();
    });

    // 검색 결과의 장소명을 이름 필드에 자동 입력
    if (_nameController.text.isEmpty) {
      final name = result.name.length <= AppConstants.locationNameMaxLength
          ? result.name
          : result.name.substring(0, AppConstants.locationNameMaxLength);
      _nameController.text = name;
    }

    _mapController.move(latLng, _defaultZoom);
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
        '지도를 탭하거나 검색하여 장소를 선택하세요',
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

// ── 지도 핀 위젯 ──────────────────────────────────────────────

/// 드롭 핀 형태의 커스텀 마커.
/// 기본 Icons.location_on보다 시인성이 높다.
class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: AppColors.coral, size: 40),
        // 핀 아래 그림자 점
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 6, height: 3),
        ),
      ],
    );
  }
}

// ── 지도 컨트롤 버튼 ────────────────────────────────────────────

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

// ── 검색 결과 모델 ──────────────────────────────────────────────

class _SearchResult {
  const _SearchResult({
    required this.name,
    required this.lat,
    required this.lon,
    this.address,
    this.category,
  });

  final String name;
  final double lat;
  final double lon;
  final String? address;

  /// Kakao 카테고리 그룹명 (음식점, 카페, 편의점 등)
  final String? category;
}
