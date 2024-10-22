import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:ai_app/booleanNotifier.dart';
import 'package:ai_app/homePage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:ai_app/prompt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';

class MessangerChatHead extends StatefulWidget {
  MessangerChatHead({Key? key}) : super(key: key);
  BoxShape currentShape = BoxShape.circle;

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  Color color = const Color(0xFFFFFFFF);
  static const String _kPortNameOverlay = 'OVERLAY';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? messageFromOverlay;

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false; // Track if a response is loading

  dynamic apiKey =
      Platform.environment['AIzaSyDnSWRK5tm6LEWTb0Qj77Lv-9zI5OBuuuY'];

  StreamSubscription? bpmSubscription;

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
  void initState() {
    super.initState();
    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameOverlay,
    );
    log("$res : HOME");
    _receivePort.listen((message) {
      log("message from UI: $message");
      setState(() {
        messageFromOverlay = 'message from UI: $message';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Material(
        color: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0.0,
        child: GestureDetector(
          onTap: () async {
            setState(() {});
            if (widget.currentShape == BoxShape.rectangle) {
              await FlutterOverlayWindow.resizeOverlay(50, 50, true);
              await FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag);
              await FlutterOverlayWindow.moveOverlay(
                  OverlayPosition(screenHeight * 0, screenWidth * 0));

              setState(() {
                widget.currentShape = BoxShape.circle;
              });
            } else {
              await FlutterOverlayWindow.moveOverlay(
                  OverlayPosition(screenHeight * 0, screenWidth * 0));
              await FlutterOverlayWindow.resizeOverlay(
                350,
                600,
                false,
              );
              await FlutterOverlayWindow.updateFlag(OverlayFlag.focusPointer);

              setState(() {
                widget.currentShape = BoxShape.rectangle;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              // borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Color.fromARGB(255, 80, 80, 80),
              shape: widget.currentShape,
            ),
            child: _isLoading == true
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end, //reverse: true,
                    // semanticChildCount: 1,
                    children: [
                      widget.currentShape == BoxShape.rectangle
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 550,
                                  child: ListView(
                                    //reverse: true,
                                    children: [
                                      Column(
                                        children: [
                                          ..._messages.reversed.map((message) {
                                            return ListTile(
                                              title: Text(message['user'] ?? '',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              subtitle:
                                                  Text(message['bot'] ?? ''),
                                            );
                                          }).toList(),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          strutStyle: const StrutStyle(),
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
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
