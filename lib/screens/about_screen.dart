import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // دالة لفتح الروابط
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // Widget للقسم الواحد (Title + Text)
  Widget sectionBlock(String title, Widget content, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.deepPurple)),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  // Widget للقائمة مع الروابط
  Widget linkList(List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () => _launchURL(item['url']!),
            child: Text.rich(
              TextSpan(
                text: item['name'],
                style: const TextStyle(
                    color: Colors.deepPurple, decoration: TextDecoration.underline),
                children: [
                  TextSpan(
                    text: " - ${item['desc']}",
                    style: const TextStyle(
                        color: Colors.black87, decoration: TextDecoration.none),
                  )
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // بيانات المنظمات
    final internationalOrgs = [
      {
        'name': 'British Dyslexia Association (BDA)',
        'url': 'https://www.bdadyslexia.org.uk/',
        'desc': 'Leading UK organization providing resources, training, and support.'
      },
      {
        'name': 'Made By Dyslexia',
        'url': 'https://www.madebydyslexia.org/',
        'desc': 'Global organization educating the world about dyslexic thinking.'
      },
      {
        'name': 'Helen Arkell Dyslexia Charity',
        'url': 'https://helenarkell.org.uk/',
        'desc': 'Specialized support, advice, and information for dyslexics and families.'
      },
    ];

    final egyptOrgs = [
      {
        'name': 'Moon Hall Cairo Learning Centre',
        'url': 'https://moonhallcairo.com/',
        'desc': 'أول مركز مخصص لصعوبات التعلم في مصر، يقدم تقييمات ودعم متخصص للأطفال.'
      },
      {
        'name': 'The Lighthouse Centre',
        'url': 'https://gecegypt.com/lighthouse-centre',
        'desc': 'برامج تدخلية متخصصة في القراءة، الكتابة، والإملاء باللغتين الإنجليزية والعربية.'
      },
      {
        'name': 'The Learning Resource Center (LRC)',
        'url': 'https://lrcegypt.org/',
        'desc': 'خدمات تقييم، استشارات، وعلاجات متخصصة للأطفال والأسر.'
      },
      {
        'name': 'Genius Minds – Davis Method Provider',
        'url': 'https://www.davismethod.org/loc/egypt/',
        'desc': 'خدمات Davis® لتصحيح الديسلكسيا باللغة العربية والإنجليزية.'
      },
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5F2C82), Color(0xFF49A09D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Header =====
                Text(
                  "About LexiAid",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF9370DB), Color(0xFFFF69B4)],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "LexiAid is dedicated to helping individuals with dyslexia unlock their potential. "
                      "Our tools make learning easier, effective, and enjoyable.",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),

                // ===== Sections =====
                sectionBlock(
                  "Our Mission",
                  const Text(
                    "Provide smart technology that adapts to each learner's needs, promoting confidence and success.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                sectionBlock(
                  "Our Vision",
                  const Text(
                    "A world where every mind can learn in its own way, without judgment, with understanding, support, and innovation.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                sectionBlock(
                  "Our Team",
                  const Text(
                    "Passionate educators, developers, and designers committed to creating accessible learning tools.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                sectionBlock(
                  "International Dyslexia Organizations",
                  linkList(internationalOrgs),
                ),

                sectionBlock(
                  "منظمات متخصصة في الديسلكسيا في مصر",
                  linkList(egyptOrgs),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}