import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController controller = TextEditingController();

  List<Map<String,String>> messages = [];

  bool aiTyping = false;


  final String apiKey = "API_KEY";


  Future<String> askAI(String text) async {

    try{

      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: jsonEncode({

          "model": "openai/gpt-3.5-turbo",

          "messages": [
            {
              "role": "system",
              "content": "You are a friendly AI tutor helping children with dyslexia learn English simply."
            },
            {
              "role": "user",
              "content": text
            }
          ]

        }),
      );

      final data = jsonDecode(response.body);

      return data["choices"][0]["message"]["content"];

    }catch(e){

      return "AI Error: $e";

    }

  }
  String randomEncouragement(){

    List<String> msgs = [

      "🌟 Great job!",
      "👍 Keep going!",
      "✨ You're improving!",
      "💡 Nice try!",
      "🤗 Keep practicing!"

    ];

    msgs.shuffle();

    return msgs.first;

  }
  Future<String> respondToText(String text) async {

    String aiReply = await askAI(text);

    return "$aiReply\n\n${randomEncouragement()}";

  }
  void sendMessage() async {

    if(controller.text.isEmpty) return;

    String userText = controller.text;

    setState(() {

      messages.add({"role":"user","text":userText});

      aiTyping = true;

    });

    controller.clear();

    String botReply = await respondToText(userText);

    await Future.delayed(const Duration(milliseconds:700));

    setState(() {

      messages.add({"role":"bot","text":botReply});

      aiTyping = false;

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Lexi AI Chat"),

        backgroundColor: const Color(0xFFB3E5FC),

      ),

      body: Column(

        children: [

          Expanded(

            child: ListView.builder(

              padding: const EdgeInsets.all(10),

              itemCount: messages.length + (aiTyping ? 1 : 0),

              itemBuilder: (context,index){

                if(aiTyping && index == messages.length){

                  return const Align(

                    alignment: Alignment.centerLeft,

                    child: Padding(

                      padding: EdgeInsets.all(8),

                      child: Text("🤖 Typing..."),

                    ),

                  );

                }

                bool isUser = messages[index]["role"] == "user";

                return Align(

                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(

                    margin: const EdgeInsets.symmetric(vertical:5),

                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(

                      color: isUser
                          ? const Color(0xFFA8E6CF)
                          : const Color(0xFFD0E1F9),

                      borderRadius: BorderRadius.circular(16),

                    ),

                    child: Text(

                      messages[index]["text"]!,

                      style: const TextStyle(fontSize:16),

                    ),

                  ),

                );

              },

            ),

          ),

          Container(

            padding: const EdgeInsets.symmetric(horizontal:10),

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    controller: controller,

                    decoration: const InputDecoration(

                      hintText: "Type message...",

                      border: InputBorder.none,

                    ),

                    onSubmitted: (value)=>sendMessage(),

                  ),

                ),

                IconButton(

                  icon: const Icon(Icons.send),

                  onPressed: sendMessage,

                )

              ],

            ),

          )

        ],

      ),

    );

  }

}