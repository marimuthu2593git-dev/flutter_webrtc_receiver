import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_web_receiver/client/multiple_server_connection/webrtc_server_connection.dart';


class MultiServerWebRTCClient extends StatefulWidget {
  @override
  State<MultiServerWebRTCClient> createState() => _MultiServerWebRTCClientState();
}

class _MultiServerWebRTCClientState extends State<MultiServerWebRTCClient> {
  final List<WebRTCServerConnection> _connections = [];
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  void _connectToServer() async {
    final ip = _ipController.text;
    final port = _portController.text;
    if (ip.isEmpty || port.isEmpty) return;

    final conn = WebRTCServerConnection(ip: ip, port: port);
    await conn.initialize(_onMessage, _onDisconnect, _onError);

    setState(() => _connections.add(conn));
  }

  void _onMessage(WebRTCServerConnection conn, dynamic message) async {
    if (!_isJson(message)) return;
    final data = jsonDecode(message);
    if (data['type'] == 'offer') {
      await conn.handleOffer(data['sdp']);
    } else if (data['type'] == 'candidate') {
      await conn.addCandidate(data);
    }
  }

  void _onDisconnect(WebRTCServerConnection conn) {
    setState(() => _connections.remove(conn));
  }

  void _onError(WebRTCServerConnection conn, dynamic error) {
    print("Connection error with ${conn.ip}:${conn.port}: $error");
    setState(() => _connections.remove(conn));
  }

  bool _isJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    for (var conn in _connections) {
      conn.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multi-Server WebRTC Viewer")),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: InputDecoration(labelText: 'Server IP'),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _portController,
                  decoration: InputDecoration(labelText: 'Port'),
                ),
              ),
              ElevatedButton(
                onPressed: _connectToServer,
                child: Text("Connect"),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _connections.length,
              itemBuilder: (context, index) {
                final conn = _connections[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: RTCVideoView(conn.renderer),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${conn.ip}:${conn.port}'),
                          ),
                          IconButton(
                            icon: Icon(
                              conn.isAudioEnabled ? Icons.volume_up : Icons.volume_off,
                            ),
                            onPressed: () {
                              setState(() => conn.toggleAudio());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
