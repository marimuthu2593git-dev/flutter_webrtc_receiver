import 'package:flutter/material.dart';
import 'package:flutter_webrtc_web_receiver/client/multiple_server_connection/multiserver_webrtc_client.dart';

import 'client/nonwebsocket_client/nonwebsocket_clientscreen.dart';
import 'client/websocket_webrtc_client_allplatform.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: WebsocketWebrtcClientAllplatform(), // Working for view stream from single server

      home: NonwebsocketClientscreen(),
    );
  }
}
