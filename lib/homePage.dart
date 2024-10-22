import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:ai_app/booleanNotifier.dart';
import 'package:ai_app/examples.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_apps/flutter_overlay_apps.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.typing}) : super(key: key);

  bool? typing = false;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? latestMessageFromOverlay;
  var flag = OverlayFlag.defaultFlag;

  @override
  void initState() {
    super.initState();

    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameHome,
    );
    log("$res: OVERLAY");
    _receivePort.listen((message) {
      log("message from OVERLAY: $message");
      setState(() {
        latestMessageFromOverlay = 'Latest Message From Overlay: $message';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MessangerChatHead().currentShape);
    print(flag);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
              children: [
                TextButton(
                  onPressed: () async {
                    final status =
                        await FlutterOverlayWindow.isPermissionGranted();
                    log("Is Permission Granted: $status");
                  },
                  child: const Text("Check Permission"),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () async {
                    await Permission.systemAlertWindow.request();
        
                    final bool? res =
                        await FlutterOverlayWindow.requestPermission();
                    log("status: $res");
                  },
                  child: const Text("Request Permission"),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () async {
                    if (await FlutterOverlayWindow.isActive()) return;
                    await FlutterOverlayWindow.showOverlay(
                      enableDrag: true,
                      overlayTitle: "X-SLAYER",
                      overlayContent: 'Overlay Enabled',
                      flag: OverlayFlag.focusPointer,
                      visibility: NotificationVisibility.visibilityPublic,
                      positionGravity: PositionGravity.auto,
                      height: 140,
                      width: 140,
                      startPosition: const OverlayPosition(0, 0),
                    );
                  },
                  child: const Text("Show Overlay"),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () async {
                    final status = await FlutterOverlayWindow.isActive();
                    log("Is Active?: $status");
                  },
                  child: const Text("Is Active?"),
                ),
                const SizedBox(height: 10.0),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    log('Try to close');
                    FlutterOverlayWindow.closeOverlay()
                        .then((value) => log('STOPPED: alue: $value'));
                  },
                  child: const Text("Close Overlay"),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    homePort ??=
                        IsolateNameServer.lookupPortByName(_kPortNameOverlay);
                    homePort?.send('Send to overlay: ${DateTime.now()}');
                  },
                  child: const Text("Send message to overlay"),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    FlutterOverlayWindow.getOverlayPosition().then((value) {
                      log('Overlay Position: $value');
                      setState(() {
                        latestMessageFromOverlay = 'Overlay Position: $value';
                      });
                    });
                  },
                  child: const Text("Get overlay position"),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    FlutterOverlayWindow.moveOverlay(
                      const OverlayPosition(0, 0),
                    );
                  },
                  child: const Text("Move overlay position to (0, 0)"),
                ),
                const SizedBox(height: 20),
                Text(latestMessageFromOverlay ?? ''),
              ],
            )
          
        ),
      ),
    );
  }
}
