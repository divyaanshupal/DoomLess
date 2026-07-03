import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final int totalCount;
  final int yesterdayCount;
  final Map<String, int> weeklyHistory;

  const StatsScreen({
    super.key,
    required this.themeNotifier,
    required this.totalCount,
    required this.yesterdayCount,
    required this.weeklyHistory,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with WidgetsBindingObserver {
  static const _usageChannel = MethodChannel('com.example.distract/usage');

  bool _hasPermission = false;
  List<Map<dynamic, dynamic>> _appUsageList = [];
  bool _isLoading = true;
  int? _selectedChartIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUsageData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUsageData();
    }
  }

  Future<void> _loadUsageData() async {
    setState(() => _isLoading = true);
    try {
      final bool hasPerm = await _usageChannel.invokeMethod(
        'hasUsagePermission',
      );
      if (hasPerm) {
        final List<dynamic> data = await _usageChannel.invokeMethod(
          'getDailyUsage',
        );
        setState(() {
          _appUsageList = data.cast<Map<dynamic, dynamic>>();
        });
      }
      setState(() {
        _hasPermission = hasPerm;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Usage stats error: $e');
      setState(() => _isLoading = false);
    }
  }

  // --- Theme Colors ---
  Color get _bg => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFF111111)
      : const Color(0xFFFFFFFF);
  Color get _surface => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFF1A1A1A)
      : const Color(0xFFF7F7F5);
  Color get _card => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);
  Color get _textPrimary => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFFF2F2F2)
      : const Color(0xFF1A1A1A);
  Color get _textSecondary => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFF9A9A9A)
      : const Color(0xFF6B6B6B);
  Color get _textMuted => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFF5A5A5A)
      : const Color(0xFFA0A0A0);
  Color get _border => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFF2A2A2A)
      : const Color(0xFFEEEEEE);
  Color get _accent => widget.themeNotifier.value == ThemeMode.dark
      ? const Color(0xFFF2F2F2)
      : const Color(0xFF1A1A1A);

  // --- Logic Helpers ---
  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    return '${h}h ${m}m';
  }

  String _getEstimatedScrollTime() {
    int totalSeconds = widget.totalCount * 15;
    int minutes = totalSeconds ~/ 60;

    if (minutes == 0 && widget.totalCount > 0) return '<1m';
    return _formatTime(minutes);
  }

  String _getTimeSaved() {
    const int dailyGoalMinutes = 60;
    int estimatedMinutesSpent = (widget.totalCount * 15) ~/ 60;

    int minutesSaved = dailyGoalMinutes - estimatedMinutesSpent;

    if (minutesSaved <= 0) return '0m';
    return _formatTime(minutesSaved);
  }

  String _getTrendText() {
    if (widget.yesterdayCount == 0)
      return widget.totalCount > 0 ? '↑100%' : '--';

    final int diff = widget.totalCount - widget.yesterdayCount;
    final int percent = ((diff.abs() / widget.yesterdayCount) * 100).toInt();
    final String sign = diff >= 0 ? '↑' : '↓';
    return '$sign$percent%';
  }

  // --- Popup Dialog Logic ---
  void _showInfoDialog(String title, String description) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: _textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  height: 1.45,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _textPrimary,
                    foregroundColor: _bg,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Got it',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SCAFFOLD AND SAFEAREA REMOVED! It is now a perfectly integrated Column inside the dashboard's AnimatedSwitcher.
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMiniStats(),
                const SizedBox(height: 28),
                _buildSectionLabel('Past 7 Days'),
                const SizedBox(height: 12),
                _buildWeeklyChart(),
                const SizedBox(height: 28),
                _buildSectionLabel('True App Usage (Today)'),
                const SizedBox(height: 12),
                _isLoading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: _accent),
                        ),
                      )
                    : !_hasPermission
                    ? _buildPermissionRequest()
                    : _buildStatsList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        0,
      ), // Match Home padding perfectly
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
              border: Border.all(color: _border),
            ),
            child: Icon(Icons.bar_chart_rounded, color: _textPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            'Insights',
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.1,
        color: _textMuted,
      ),
    );
  }

  Widget _buildMiniStats() {
    return Row(
      children: [
        _buildMiniStatCard(
          value: _getEstimatedScrollTime(),
          label: 'Est. time spent',
          dialogTitle: 'Estimated Time',
          dialogBody:
              'This is an estimate calculated by assuming an average of 15 seconds spent per swipe/video on short-form platforms.',
        ),
        const SizedBox(width: 10),
        _buildMiniStatCard(
          value: _getTimeSaved(),
          label: 'Goal time saved',
          dialogTitle: 'Time Saved',
          dialogBody:
              'This is calculated based on a healthy daily limit of 60 minutes of screen time. Every minute you stay under this limit is counted as time saved.',
        ),
        const SizedBox(width: 10),
        _buildMiniStatCard(value: _getTrendText(), label: 'vs yesterday'),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String value,
    required String label,
    String? dialogTitle,
    String? dialogBody,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: dialogBody != null
            ? () => _showInfoDialog(dialogTitle ?? label, dialogBody)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (dialogBody != null) ...[
                    const SizedBox(width: 3),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 10,
                      color: _textMuted,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    List<int> counts = [];
    List<String> labels = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      counts.add(
        i == 0 ? widget.totalCount : (widget.weeklyHistory[dateStr] ?? 0),
      );
      labels.add(_getDayInitial(date.weekday));
    }

    int maxCount = counts.reduce((curr, next) => curr > next ? curr : next);
    if (maxCount == 0) maxCount = 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 240,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double chartWidth = constraints.maxWidth;
          final double chartHeight = constraints.maxHeight - 24;
          final double stepX = chartWidth / counts.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(chartWidth, chartHeight),
                painter: _LineChartPainter(
                  counts: counts,
                  maxCount: maxCount,
                  lineColor: _textPrimary,
                  cardColor: _card,
                ),
              ),
              for (int i = 0; i < counts.length; i++) ...[
                Positioned(
                  bottom: -20,
                  left: (i * stepX) + (stepX / 2) - 10,
                  width: 20,
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: (i == counts.length - 1)
                          ? _textPrimary
                          : _textMuted,
                      fontWeight: (i == counts.length - 1)
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  left: i * stepX,
                  top: 0,
                  width: stepX,
                  height: constraints.maxHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _selectedChartIndex = _selectedChartIndex == i
                            ? null
                            : i;
                      });
                    },
                  ),
                ),
                if (_selectedChartIndex == i)
                  Positioned(
                    left: (i * stepX) + (stepX / 2) - 25,
                    top:
                        chartHeight -
                        10 -
                        ((counts[i] / maxCount) * (chartHeight - 20)) -
                        42,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _textPrimary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            '${counts[i]}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: _bg,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _getDayInitial(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }

  Widget _buildPermissionRequest() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _surface, shape: BoxShape.circle),
            child: Icon(
              Icons.pie_chart_outline_rounded,
              size: 32,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock App Usage',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Grant Usage Access to see exactly how much time you spend on each app.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _textPrimary,
                foregroundColor: _bg,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _usageChannel.invokeMethod('openUsageSettings'),
              child: Text(
                'Grant Permission',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList() {
    if (_appUsageList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Center(
          child: Text(
            'No app usage recorded today yet.',
            style: GoogleFonts.dmSans(color: _textSecondary),
          ),
        ),
      );
    }

    final int maxMinutes = _appUsageList.isNotEmpty
        ? _appUsageList.first['minutes'] as int
        : 1;

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _appUsageList.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: _border, indent: 20, endIndent: 20),
        itemBuilder: (context, index) {
          final app = _appUsageList[index];
          final String name = app['appName'] as String;
          final int mins = app['minutes'] as int;
          final double percentage = (mins / maxMinutes).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      _formatTime(mins),
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> counts;
  final int maxCount;
  final Color lineColor;
  final Color cardColor;

  _LineChartPainter({
    required this.counts,
    required this.maxCount,
    required this.lineColor,
    required this.cardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (counts.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / counts.length;
    final List<Offset> points = [];

    for (int i = 0; i < counts.length; i++) {
      final double x = (i * stepX) + (stepX / 2);
      final double usableHeight = size.height - 20;
      final double y =
          size.height - 10 - ((counts[i] / maxCount) * usableHeight);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    final dotOuterPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotInnerPaint = Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 5.5, dotOuterPaint);
      canvas.drawCircle(point, 3.0, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.counts != counts || oldDelegate.maxCount != maxCount;
}
