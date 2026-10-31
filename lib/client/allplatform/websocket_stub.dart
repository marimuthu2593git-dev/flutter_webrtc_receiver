// export 'io_websocket.dart' show IOWebSocket; // 🖥️ For Windows, macOS, Linux, Android, iOS
// export 'web_websocket.dart' /*if (dart.library.html)*/ show WebWebSocket; // 🌐 For Web
// if i use above code i got error like

// 1. Dart library 'dart:html' is not available on this platform. while compile to windows .
// So use below code but you  must use same ClassName in both io_websocket.dart and web_websocket.dart file

export 'io_websocket.dart' if (dart.library.html) 'web_websocket.dart' show PlatformWebSocket;