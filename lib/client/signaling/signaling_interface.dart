// lib/signaling/platform_signaling.dart
abstract class PlatformSignaling {
  Future<void> connect(String url, Function onMessage, Function onDone, Function onError);
  void send(String message);
  void close();
}
