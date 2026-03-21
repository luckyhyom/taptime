import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taptime/features/stats/ui/widgets/month_stats_view.dart';
import 'package:taptime/features/stats/ui/widgets/today_stats_view.dart';
import 'package:taptime/features/stats/ui/widgets/week_stats_view.dart';

/// 통계 화면 — 오늘/주간/월간 탭으로 구성된다.
///
/// TabBar로 Today/Week/Month 뷰를 전환하며,
/// 각 뷰는 독립적인 날짜 선택과 데이터 표시를 가진다.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '주간'),
            Tab(text: '월간'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const TodayStatsView(),
          const WeekStatsView(),
          MonthStatsView(tabController: _tabController),
        ],
      ),
    );
  }
}
