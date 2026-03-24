# GitHub 컨트리뷰션 그래프를 Flutter로 만들기

> 2026-03-21 | Taptime v1.1

## 배경

v1.0 MVP를 마치고 v1.1에서 "동기 부여" 기능을 추가했다. 월별 통계에 히트맵을 넣는데, 처음에는 전통적인 달력 그리드(7열 × 5~6행)를 만들었다. 그런데 프리셋별로 독립 히트맵을 보여주려 하니 한 프리셋당 달력 하나씩이 세로 공간을 너무 차지했다. GitHub의 컨트리뷰션 그래프(7행 × N열)라면 같은 정보를 3배 적은 공간에 담을 수 있었다.

## 핵심 결정

### 1. 달력 그리드 → GitHub 스타일 히트맵

전통 달력은 주(week)가 행이다. GitHub 그래프는 요일이 행이고 주가 열이다. 이 전치(transpose)만으로 세로 높이가 7칸 고정이 된다:

```dart
// lib/features/stats/ui/widgets/heatmap_calendar.dart

/// 월의 날짜를 주차별 2차원 배열로 변환한다.
/// 반환값: outer = 주차(열), inner = 요일 7개(Mon=0 ~ Sun=6).
static List<List<DateTime?>> _buildWeeks(int year, int month) {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final weeks = <List<DateTime?>>[];
  var currentWeek = List<DateTime?>.filled(7, null);

  for (var day = 1; day <= daysInMonth; day++) {
    final weekdayIndex = DateTime(year, month, day).weekday - 1;

    if (weekdayIndex == 0 && day > 1) {
      weeks.add(currentWeek);
      currentWeek = List<DateTime?>.filled(7, null);
    }
    currentWeek[weekdayIndex] = DateTime(year, month, day);
  }
  weeks.add(currentWeek);
  return weeks;
}
```

`weeks[주차][요일]` 구조로, 열이 주차, 행이 요일이 된다. 월 시작 전/종료 후 빈 칸은 `null`로 처리한다.

### 2. 4단계 상대 강도

GitHub처럼 고정 임계값(예: 1시간, 2시간, 3시간) 대신 상대 강도를 사용했다. 해당 월의 최대값 대비 비율로 색상을 결정한다:

```dart
/// 4단계 강도: 0 (없음), 0.15, 0.35, 0.6, 1.0
static double _intensity(int seconds, int maxSeconds) {
  if (seconds == 0) return 0;
  if (maxSeconds == 0) return 0;
  final ratio = seconds / maxSeconds;
  if (ratio <= 0.25) return .15;
  if (ratio <= 0.5) return 0.35;
  if (ratio <= 0.75) return 0.6;
  return 1;
}
```

이유: 사용자마다 활동량이 다르다. 하루 1시간 하는 사람에게 3시간 기준은 맞지 않는다. 상대 강도는 "내 패턴에서의 활발한 날"을 보여준다.

색상은 프리셋별로 다르다. `activeColor` 파라미터에 프리셋의 색상을 전달하면 `color.withValues(alpha: intensity)`로 투명도만 조절한다:

```dart
decoration: BoxDecoration(
  color: intensity > 0
      ? color.withValues(alpha: intensity)
      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
  borderRadius: BorderRadius.circular(2),
  border: isToday ? Border.all(color: color, width: 1.5) : null,
),
```

### 3. 반응형 셀 크기

화면 너비에 따라 셀 크기를 자동 조절하되, 너무 작거나 큰 것을 방지한다:

```dart
static double _cellSize(double availableWidth, int weekCount) {
  const dayLabelWidth = 28.0;
  const labelGap = 4.0;
  const cellSpacing = 2.0;
  final gridWidth = availableWidth - dayLabelWidth - labelGap;
  return ((gridWidth - (weekCount - 1) * cellSpacing) / weekCount)
      .clamp(8.0, 14.0);
}
```

`LayoutBuilder`로 사용 가능한 너비를 받아서 셀 크기를 계산한다. 최소 8px(정보 식별 가능), 최대 14px(공간 효율 유지).

### 4. 프리셋별 독립 히트맵 + 스트릭

원래 월별 통계에 전체 히트맵 1개 + 전체 스트릭 1개가 있었다. v1.1에서 프리셋별로 분리했다:

```dart
// family provider: presetId별로 독립적인 일별 합계
final monthDailyTotalsForPresetProvider =
    FutureProvider.family<Map<DateTime, int>, (String presetId, DateTime month)>(
  (ref, args) async {
    final repo = ref.watch(sessionRepositoryProvider);
    return repo.getDailyTotalsForPreset(args.$1, args.$2);
  },
);
```

Repository에 `getDailyTotalsForPreset` 메서드를 추가하고, family provider로 프리셋별 데이터를 캐싱한다. 월별 통계 화면에서 세션이 있는 프리셋마다 자기 색상의 히트맵이 생긴다.

## 코드 워크스루: 휴식 타이머

v1.1에서 추가한 휴식 타이머(5분/15분)는 의도적으로 DB에 저장하지 않는다:

```dart
// 별도의 가벼운 Notifier — DB 없이 메모리에서만 동작
class BreakTimerNotifier extends Notifier<BreakTimerState> {
  Timer? _ticker;
  // ... ActiveTimer 없음, Session 저장 없음
}
```

이유: 휴식은 "기록"이 아니라 "알림"이다. 통계에 포함할 필요 없고, 크래시 복구도 불필요하다. 가장 간단한 decrement 방식을 사용했다 — 정확도가 덜 중요한 5분 타이머에는 충분하다.

## 배운 점

- **데이터 시각화는 레이아웃 선택이 전부다.** 같은 데이터도 달력 vs GitHub 그리드에서 전혀 다른 인사이트를 준다. 세로 공간이 제한된 모바일에서는 compact 레이아웃이 필수다.
- **상대 강도가 절대 임계값보다 유연하다.** 사용자마다 활동량이 다르므로 "그 사람의 최대치 대비 비율"이 더 의미 있다.
- **모든 것을 DB에 넣을 필요는 없다.** 기록이 아닌 단순 알림 기능은 메모리 상태만으로 충분하다.
