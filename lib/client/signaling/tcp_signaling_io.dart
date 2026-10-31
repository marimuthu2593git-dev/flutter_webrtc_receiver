import 'dart:convert';
import 'dart:io';

import 'package:flutter_webrtc_web_receiver/client/signaling/signaling_interface.dart';

class PlatformSignalingImpl  implements PlatformSignaling {
  late Socket _socket;
  late void Function(String) _onMessage;
  late void Function() _onDone;
  late void Function(Object) _onError;

  @override
  Future<void> connect(String url, Function onMessage, Function onDone, Function onError) async {

    print("Tcp socket connect is called == ${url}");
    _onMessage = onMessage as void Function(String);
    _onDone = onDone as void Function();
    _onError = onError as void Function(Object);

    try {
      // final uri = Uri.parse(url.replaceFirst("tcp://", ""));
      // _socket = await Socket.connect(uri.host, uri.port);
      String host ="";
      int? port =0;
      if (url.contains(':')) {
        List<String> parts = url.split(':');
        if (parts.length == 2) {
           host = parts[0];
           port = int.tryParse(parts[1]);

          if (port != null) {
            print('Host: $host');
            print('Port: $port');
          } else {
            print('Invalid port');
          }
        } else {
          print('Invalid format');
        }
      } else {
        print('Missing ":" in server address');
      }
      _socket = await Socket.connect(host, port!);

      _socket.listen(
            (data) => _onMessage(utf8.decode(data)),
        onDone: _onDone,
        onError: _onError,
        cancelOnError: true,
      );
    } catch (e) {
      _onError("TCP Connect Error: $e");
    }
  }

  @override
  void send(String message) {
    _socket.add(utf8.encode(message));
  }

  @override
  void close() {
    _socket.destroy();
  }
}
