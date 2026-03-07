import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Random random = Random();
  final int sparklesCount = 8;
  late List<Offset> sparklesPositions;

  @override
  void initState() {
    super.initState();
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    sparklesPositions = List.generate(
      sparklesCount,
          (_) => Offset(random.nextDouble(), random.nextDouble()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final weeklyData = const [
    {'day': 'Mon', 'score': 65},
    {'day': 'Tue', 'score': 72},
    {'day': 'Wed', 'score': 68},
    {'day': 'Thu', 'score': 85},
    {'day': 'Fri', 'score': 90},
    {'day': 'Sat', 'score': 88},
    {'day': 'Sun', 'score': 95},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          ...List.generate(sparklesCount, (i) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (_, child) {
                return Positioned(
                  left: sparklesPositions[i].dx * screenSize.width,
                  top: sparklesPositions[i].dy * screenSize.height +
                      sin(_animationController.value * 2 * pi) * 20,
                  child: Opacity(
                    opacity: 0.4 + 0.3 * sin(_animationController.value * 2 * pi),
                    child: Text(
                      '✨',
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main Content
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF2196F3)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'My Progress',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF64B5F6), Color(0xFF2196F3)]),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🌟', style: TextStyle(fontSize: 36)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Level 12',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Keep going! Next level at 300 stars ⭐',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: 245 / 300,
                              minHeight: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2196F3)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '245 / 300 stars',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _StatItem(
                            icon: '🔥',
                            label: 'Day Streak',
                            value: '7',
                            color: Color(0xFF64B5F6)),
                        _StatItem(
                            icon: '📚',
                            label: 'Lessons Done',
                            value: '42',
                            color: Color(0xFF2196F3)),
                        _StatItem(
                            icon: '⏱️',
                            label: 'Time Spent',
                            value: '18h',
                            color: Color(0xFF42A5F5)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.trending_up, color: Color(0xFF2196F3)),
                              SizedBox(width: 8),
                              Text(
                                "This Week's Performance",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index < 0 || index >= weeklyData.length) {
                                          return const Text('');
                                        }
                                        return Text(
                                            weeklyData[index]['day'] as String);
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                      weeklyData.length,
                                          (i) => FlSpot(
                                          i.toDouble(),
                                          (weeklyData[i]['score'] as int)
                                              .toDouble()),
                                    ),
                                    isCurved: true,
                                    gradient: const LinearGradient(
                                        colors: [Color(0xFF64B5F6), Color(0xFF2196F3)]),
                                    barWidth: 3,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF2196F3).withOpacity(0.3),
                                          Colors.transparent
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              '📈 You improved by 46% this week! Amazing! 🎉',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stat item widget
class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}