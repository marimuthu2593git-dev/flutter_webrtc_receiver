import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'websocket_stub.dart';

class ClientScreen extends StatefulWidget {
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  late final dynamic _webSocket;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<String> messages = [];
  bool isConnected = false;
  String? serverUrl;
  // final String url = 'ws://localhost:8080'; // Change to your WebSocket server

  @override
  void initState() {
    super.initState();
    _webSocket = PlatformWebSocket(); // ✅ Automatically resolves correct WebSocket class
    _ipController.text = "192.168.0.245";
    _portController.text = "8080";
  }

  void _connectWebSocket() {
    if (isConnected) return;

    // Validate IP and Port Input
    if (_ipController.text.isEmpty || _portController.text.isEmpty) {
      setState(() => messages.add("⚠️ Please enter IP and port."));
      return;
    }

    serverUrl = 'ws://${_ipController.text}:${_portController.text}';

    _webSocket.connect(
      serverUrl!,
          (message) {
        setState(() => messages.add("📩 Server: $message"));
      },
          () {
        setState(() {
          isConnected = false;
          messages.add("❌ Disconnected from server");
        });
      },
          (error) {
        setState(() => messages.add("⚠️ Connection failed: $error"));
      },
    );

    setState(() {
      isConnected = true;
      messages.add("✅ Connected to WebSocket at $serverUrl");
    });
  }

  void _disconnectWebSocket() {
    if (isConnected) {
      _webSocket.close();
      setState(() {
        isConnected = false;
        messages.add("❌ Disconnected from server");
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && isConnected) {
      _webSocket.send(_messageController.text);
      setState(() {
        messages.add("📤 You: ${_messageController.text}");
        _messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    _ipController.dispose();
    _portController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('WebSocket Client')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // IP and Port Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      decoration: InputDecoration(labelText: 'IP Address'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _portController,
                      decoration: InputDecoration(labelText: 'Port'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isConnected ? null : _connectWebSocket,
                    child: Text("Connect"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isConnected ? _disconnectWebSocket : null,
                    child: Text("Disconnect"),
                  ),
                ],
              ),

              // Messages List
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(messages[index]),
                  ),
                ),
              ),

              // Message Input
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(labelText: 'Enter message'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
