import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false; // Track if a response is loading

  dynamic apiKey =
      Platform.environment['AIzaSyDnSWRK5tm6LEWTb0Qj77Lv-9zI5OBuuuY'];

  Future<void> sendMessage(String prompt) async {
    setState(() {
      _isLoading = true; // Set loading to true when request starts
    });

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: "AIzaSyDnSWRK5tm6LEWTb0Qj77Lv-9zI5OBuuuY",
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        setState(() {
          _messages.add({
            'user': response.text as String,
          });
        });
      } else {
        print(response.text);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when request is complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chatbot')),
      body: 
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]['user'] ?? ''),
                  subtitle: Text(_messages[index]['bot'] ?? ''),
                );
              },
            ),
          ),
          if (_isLoading) // Show a loading indicator if waiting for response
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: const CircularProgressIndicator(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,

                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
        ],
      ),
   
    );
  }
}
