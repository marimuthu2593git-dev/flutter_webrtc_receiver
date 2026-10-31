import 'dart:convert';
import 'dart:io';

class PlatformWebSocket/*IOWebSocket*/ {
  WebSocket? _socket;

  Future<void> connect(
      String url, Function(String) onMessage, Function() onClose, Function(dynamic) onError) async {
    try {

      printWebSocketRequestHeaders(url);

      _socket = await WebSocket.connect(url);
      _socket!.listen(
            (dynamic data) => onMessage(data.toString()), // ✅ Ensures correct type
        onDone: onClose,
        onError: onError,
      );
    } catch (e) {
      onError(e);
    }
  }

  void send(String message) {
    _socket?.add(message);
  }

  void close() {
    _socket?.close();
  }

  void printWebSocketRequestHeaders(String url) {
    final uri = Uri.parse(url);
    final host = uri.host;
    final port = uri.port;
    final path = uri.path.isEmpty ? '/' : uri.path;

    final secWebSocketKey = base64Encode(List<int>.generate(16, (i) => i + 65));
    final headers = {
      'GET': '$path HTTP/1.1',
      'Host': '$host:$port',
      'Upgrade': 'websocket',
      'Connection': 'Upgrade',
      'Sec-WebSocket-Key': secWebSocketKey,
      'Sec-WebSocket-Version': '13',
    };

    print("🔍 WebSocket Handshake Request (simulated):");
    headers.forEach((key, value) {
      print('$key: $value');
    });
  }
}
