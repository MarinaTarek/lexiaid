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

    // Generate random positions for sparkles
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

  final skills = const [
    {'name': 'Spelling', 'level': 85, 'color': Color(0xFFFF7F7F)},
    {'name': 'Grammar', 'level': 72, 'color': Color(0xFF87CEEB)},
    {'name': 'Reading Speed', 'level': 90, 'color': Color(0xFF98FB98)},
    {'name': 'Comprehension', 'level': 78, 'color': Color(0xFFDDA0DD)},
  ];

  final achievements = const [
    {'title': 'First Steps', 'emoji': '🎯', 'earned': true},
    {'title': 'Word Wizard', 'emoji': '📝', 'earned': true},
    {'title': 'Reading Star', 'emoji': '⭐', 'earned': true},
    {'title': 'Perfect Week', 'emoji': '🏆', 'earned': false},
    {'title': 'Speed Reader', 'emoji': '⚡', 'earned': false},
    {'title': 'Master Writer', 'emoji': '👑', 'earned': false},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Floating sparkles
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
                          color: i % 2 == 0 ? Colors.amber : Colors.pink),
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
                colors: [Color(0xFF98FB98), Color(0xFF90EE90), Color(0xFFB0E0E6)],
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'My Progress',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Hero Stats / Level
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
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
                                  colors: [Colors.amber, Colors.orange]),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
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
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: 245 / 300,
                              minHeight: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.amber),
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

                    // Quick Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _StatItem(
                            icon: '🔥',
                            label: 'Day Streak',
                            value: '7',
                            color: Color(0xFFFF7F7F)),
                        _StatItem(
                            icon: '📚',
                            label: 'Lessons Done',
                            value: '42',
                            color: Color(0xFF87CEEB)),
                        _StatItem(
                            icon: '⏱️',
                            label: 'Time Spent',
                            value: '18h',
                            color: Color(0xFF98FB98)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly Performance Chart
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
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
                              Icon(Icons.trending_up, color: Color(0xFF98FB98)),
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
                                        return Text(weeklyData[index]['day'] as String);
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
                                        colors: [Colors.greenAccent, Colors.green]),
                                    barWidth: 3,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.withOpacity(0.3),
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
                    // Skills and Achievements are same as before...
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
            style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
