import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class AIVoiceScreen extends StatefulWidget {
  const AIVoiceScreen({super.key});

  @override
  State<AIVoiceScreen> createState() => _AIVoiceScreenState();
}

class _AIVoiceScreenState extends State<AIVoiceScreen> {

  final AudioRecorder _recorder = AudioRecorder();

  bool isRecording = false;

  String userSpeech = "";
  String correction = "";
  String explanation = "";
  Future<void> startRecording() async {

    final hasPermission = await _recorder.hasPermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission denied")),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();

    final path =
        "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    setState(() {
      isRecording = true;
      userSpeech = "";
      correction = "";
      explanation = "";
    });
  }


  Future<void> stopRecording() async {

    final path = await _recorder.stop();

    setState(() {
      isRecording = false;
    });

    if (path != null) {
      await sendToBackend(File(path));
    }
  }

  Future<void> sendToBackend(File audioFile) async {

    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.1.16:3000/chat"),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
        ),
      );

      var response = await request.send();

      var body = await response.stream.bytesToString();

      var data = jsonDecode(body);

      setState(() {
        userSpeech = data["speech"] ?? "";
        correction = data["correction"] ?? "";
        explanation = data["explanation"] ?? "";
      });

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffEEF2FF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text("AI Speaking Practice"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 10),

            const Text(
              "Speak with AI",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Practice your English speaking",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 35),
            GestureDetector(

              onTap: () {
                isRecording
                    ? stopRecording()
                    : startRecording();
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),

                height: 140,
                width: 140,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: isRecording
                      ? const Color(0xffEF4444)
                      : const Color(0xff2563EB),

                  boxShadow: [
                    BoxShadow(
                      color: (isRecording
                          ? Colors.red
                          : Colors.blue)
                          .withOpacity(.4),
                      blurRadius: 30,
                      spreadRadius: 8,
                    )
                  ],
                ),

                child: Icon(
                  isRecording
                      ? Icons.stop
                      : Icons.mic,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              isRecording
                  ? "Listening..."
                  : "Tap to start speaking",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(

                child: Column(
                  children: [

                    _buildCard(
                      title: "You said",
                      icon: Icons.record_voice_over,
                      color: Colors.orange,
                      text: userSpeech,
                    ),

                    const SizedBox(height: 15),

                    _buildCard(
                      title: "Correct sentence",
                      icon: Icons.check_circle,
                      color: Colors.green,
                      text: correction,
                    ),

                    const SizedBox(height: 15),

                    _buildCard(
                      title: "Explanation",
                      icon: Icons.lightbulb,
                      color: Colors.purple,
                      text: explanation,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required String text,
  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Icon(icon, color: color),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            text.isEmpty
                ? "Waiting for speech..."
                : text,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}