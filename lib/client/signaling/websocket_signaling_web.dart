// lib/signaling/websocket_signaling_web.dart
import 'dart:html';

import 'package:flutter_webrtc_web_receiver/client/signaling/signaling_interface.dart';

class PlatformSignalingImpl  implements PlatformSignaling {
  late WebSocket _socket;

  @override
  Future<void> connect(String url, Function onMessage, Function onDone, Function onError) async {
    _socket = WebSocket(url);
    _socket.onMessage.listen((e) => onMessage(e.data));
    _socket.onClose.listen((_) => onDone());
    _socket.onError.listen((e) => onError("Web error"));
  }

  @override
  void send(String message) => _socket.send(message);

  @override
  void close() => _socket.close();
}
