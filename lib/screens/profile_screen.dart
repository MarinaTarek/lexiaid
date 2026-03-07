import 'package:flutter/material.dart';
import 'streak_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String email;

  const ProfileScreen({
    super.key,
    this.userName = "Friend",
    this.email = "friend@example.com",
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  int streak = 0;
  int points = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = Tween<double>(begin: 0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _loadStats();
  }

  Future<void> _loadStats() async {
    int s = await StreakService.getStreak();
    int p = await StreakService.getPoints();
    setState(() {
      streak = s;
      points = p;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    int level = (points ~/ 100) + 1;
    int xpProgress = points % 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      extendBodyBehindAppBar: true,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(

          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),

          child: Column(
            children: [

              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {

                  return Stack(
                    alignment: Alignment.center,
                    children: [

                      SizedBox(
                        width: 115,
                        height: 115,
                        child: CircularProgressIndicator(
                          value: _animation.value,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blueAccent,
                        ),
                      ),

                      child!,
                    ],
                  );
                },

                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.userName.substring(0,1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 18),
              _progressCard(),

              const SizedBox(height: 18),

              Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      _infoCard("🔥 Streak", "$streak Days"),
                      _infoCard("⭐ XP", "$points"),
                      _infoCard("🏆 Level", "Lv $level"),

                    ],
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: xpProgress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "${100 - xpProgress} XP to next level",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildStats(),

              const SizedBox(height: 18),

              const Text(
                "Achievements",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _buildAchievementsGrid(),

              const SizedBox(height: 18),

              _buildSocialLinks(),

              const SizedBox(height: 18),
              Row(
                children: [

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {

                        await Navigator.pushNamed(context, '/quizPro');
                        await _loadStats();

                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Play Quiz"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _progressCard(){

    return FutureBuilder(
      future: Future.wait([
        StreakService.getPoints(),
        StreakService.getTasksCompleted(),
        StreakService.getActiveDays()
      ]),

      builder: (context, snapshot){

        if(!snapshot.hasData) return const SizedBox();

        int points = snapshot.data![0] as int;
        int tasksDone = snapshot.data![1] as int;
        int activeDays = snapshot.data![2] as int;

        double progressPercent = (points / 500).clamp(0.0, 1.0);
        int percent = (progressPercent * 100).toInt();

        return Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(18),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Overall Progress",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: progressPercent,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 6),

              Text("$percent% Completed"),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text("Tasks: $tasksDone"),
                  Text("Active Days: $activeDays"),

                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(String title,String value){

    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical:12),

      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [

          Text(title,style: const TextStyle(fontSize:13)),

          const SizedBox(height:4),

          Text(
            value,
            style: const TextStyle(
              fontSize:16,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStats(){

    return Container(

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [

          _StatItem("Tasks","25"),
          _StatItem("Weekly XP","120"),
          _StatItem("Active Days","7"),

        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(){

    List<Map<String,String>> achievements = [

      {"title":"First Task","icon":"🎯"},
      {"title":"7 Day Hero","icon":"🔥"},
      {"title":"XP Collector","icon":"⭐"},
      {"title":"Bronze","icon":"🥉"},
      {"title":"Silver","icon":"🥈"},
      {"title":"Gold","icon":"🥇"},

    ];

    return GridView.builder(

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.2,

      ),

      itemCount: achievements.length,

      itemBuilder: (context,index){

        return Container(

          decoration: BoxDecoration(

            gradient: const LinearGradient(
              colors: [
                Color(0xFFB3E5FC),
                Color(0xFFE1F5FE),
              ],
            ),

            borderRadius: BorderRadius.circular(14),

          ),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Text(
                achievements[index]["icon"]!,
                style: const TextStyle(fontSize:28),
              ),

              const SizedBox(height:4),

              Text(
                achievements[index]["title"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize:12),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialLinks(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [

        _SocialIcon(Icons.link),
        SizedBox(width:18),
        _SocialIcon(Icons.flutter_dash),
        SizedBox(width:18),
        _SocialIcon(Icons.public),

      ],
    );
  }
}

class _StatItem extends StatelessWidget{

  final String title;
  final String value;

  const _StatItem(this.title,this.value);

  @override
  Widget build(BuildContext context){

    return Column(
      children: [

        Text(title,style: const TextStyle(fontSize:13)),

        const SizedBox(height:4),

        Text(
          value,
          style: const TextStyle(
            fontSize:15,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget{

  final IconData icon;

  const _SocialIcon(this.icon);

  @override
  Widget build(BuildContext context){

    return Container(
      padding: const EdgeInsets.all(10),

      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),

      child: Icon(
        icon,
        size: 20,
        color: Colors.blueAccent,
      ),
    );
  }
}