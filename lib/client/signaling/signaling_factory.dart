export 'signaling_stub.dart'
if (dart.library.html) 'websocket_signaling_web.dart'
if (dart.library.io) 'tcp_signaling_io.dart';

// import 'package:flutter_webrtc_web_receiver/client/signaling/signaling_stub.dart';
//
// import 'platform_signaling.dart';
//
// import 'signaling_interface.dart';
// import 'signaling_stub.dart';
// PlatformSignaling createSignaling() => PlatformSignalingImpl();