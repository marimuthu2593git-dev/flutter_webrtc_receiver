// lib/src/signaling/signaling_stub.dart


import 'package:flutter_webrtc_web_receiver/client/signaling/signaling_interface.dart';

class PlatformSignalingImpl  implements PlatformSignaling {
  // @override
  // Future<void> connect(
  //     String url,
  //     void Function(String message) onMessage,
  //     void Function()? onDone,
  //     void Function(dynamic error) onError,
  //     ) {
  //   throw UnimplementedError("Stub class should not be used.");
  // }

  @override
  Future<void> connect(String url, Function onMessage, Function onDone, Function onError) {

    throw UnimplementedError();
  }

  @override
  void send(String message) {
    throw UnimplementedError("Stub class should not be used.");
  }

  @override
  void close() {
    throw UnimplementedError("Stub class should not be used.");
  }
}

