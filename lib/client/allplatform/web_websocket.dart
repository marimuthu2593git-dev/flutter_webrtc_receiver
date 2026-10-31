import 'dart:html';

class PlatformWebSocket /*WebWebSocket*/ {
  WebSocket? _socket;

  void connect(String url, Function(String) onMessage, Function() onClose, Function(dynamic) onError) {
    _socket = WebSocket(url);
    _socket!.onOpen.listen((_) {});
    _socket!.onMessage.listen((event) => onMessage(event.data));
    _socket!.onClose.listen((_) => onClose());
    _socket!.onError.listen((error) => onError(error));
  }

  void send(String message) {
    _socket?.send(message);
  }

  void close() {
    _socket?.close();
  }
}
