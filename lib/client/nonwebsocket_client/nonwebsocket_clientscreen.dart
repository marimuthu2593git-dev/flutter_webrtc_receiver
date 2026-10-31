import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../signaling/signaling_factory.dart';
// import '../signaling/websocket_stub.dart';

class NonwebsocketClientscreen extends StatefulWidget {
  @override
  _NonwebsocketClientscreenState createState() =>
      _NonwebsocketClientscreenState();
}

class _NonwebsocketClientscreenState extends State<NonwebsocketClientscreen> {
  // late final dynamic _webSocket;
  // late final PlatformWebSocket _webSocket;

  // late final PlatformSignalingImpl signaling;
  late final _webSocket;

  RTCPeerConnection? _peerConnection;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool isConnected = false;
  List<String> messages = [];
  String connectionType = "TCP"; // or "WebSocket"

  // String? serverUrl;

  late String serverUrl;

  @override
  void initState() {
    super.initState();
    // _webSocket = PlatformWebSocket();
    // _webSocket = PlatformSignalingImpl();
    _remoteRenderer.initialize();
    _webSocket = PlatformSignalingImpl();
    // _initPlatformMedia();
    // _ipController.text = "192.168.0.244";
    _ipController.text = "192.168.0.175";
    _portController.text = "5000";

    setupServerUrl();
  }

  Future<void> _initPlatformMedia() async {
    if (WebRTC.platformIsWeb) {
      // Request media for web — workaround for some browser requirements
      await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': true,
      });
    }
  }

  void setupServerUrl() {
    final ip = _ipController.text;
    final port = _portController.text;

    if (kIsWeb) {
      // Web client uses WebSocket
      serverUrl = 'ws://$ip:$port';
    } else if (Platform.isWindows ||
        Platform.isLinux ||
        Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS) {
      // Mobile/Desktop client uses TCP or custom protocol
      serverUrl = '$ip:$port'; // Just IP:port for raw TCP, no "ws://" prefix
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> _connectWebSocket() async {
    if (isConnected) return;
    if (_ipController.text.isEmpty || _portController.text.isEmpty) {
      setState(() => messages.add("⚠️ Please enter IP and port."));
      return;
    }

    // serverUrl = 'ws://${_ipController.text}:${_portController.text}';

    _webSocket?.connect(
      serverUrl!,
      (message) async {
        // print("Message From Server : $message");

        await validateResponse(message);

        /*if (isJson(message)) {
          var data = jsonDecode(message);
          if (data is Map<String, dynamic>) {
            print("🎥 Data From  Client  Type  . ${data["type"]}");
            if (data["type"] == "offer") {
              print("🎥 WebRTC Received SDP Offer . ${data["sdp"]}");
              await _handleOffer(data);
            } else if (data["type"] == "answer") {
              await _peerConnection!.setRemoteDescription(
                  RTCSessionDescription(data["sdp"], "answer"));
            } else if (data["type"] == "candidate") {
              await _peerConnection!.addCandidate(
                RTCIceCandidate(
                    data["candidate"], data["sdpMid"], data["sdpMLineIndex"]),
              );
            }
          }
        } else {
          await _startWebRTC();
          setState(() => messages.add("📩 Server: $message"));
        }*/
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

  validateResponse(dynamic message) async {
    print("🎥Received SDP Offer From Server  . ${message}");
    // if (isJson(message)) {
    //   var data = jsonDecode(message);
    final data = json.decode(message);
      if (data is Map<String, dynamic>) {
        print("🎥 Data From  Server - Message Type  . ${data["type"]}");
        if (data["type"] == "offer") {
          await _handleOffer(data["sdp"]);
          // await _handleOffer(data);
        }
        // else if (data["type"] == "answer") {
        //   await _peerConnection!.setRemoteDescription(
        //       RTCSessionDescription(data["sdp"], "answer"));
        // }
        else if (data["type"] == "candidate") {
          await _peerConnection!.addCandidate(
            RTCIceCandidate(
                data["candidate"], data["sdpMid"], data["sdpMLineIndex"]),
          );
        }
      }
    // }

    else {
      setState(() => messages.add("📩 Server: $message"));
    }
  }

  Future<void> _startWebRTC(String sdp) async {
    try {
      _peerConnection = await createPeerConnection({
        "iceServers": [
          {"urls": "stun:stun.l.google.com:19302"},
          {"urls": "stun:stun1.l.google.com:19302"},
          {"urls": "stun:stun2.l.google.com:19302"}
        ]
      });

      _peerConnection!.onTrack = (event) {
        print(
            "🎥 Got remote track: ${event.track.kind} ---- ${event.streams.length}");
        if (event.track.kind == "video") {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
        }
      };

      await _peerConnection!
          .setRemoteDescription(RTCSessionDescription(sdp, "offer"));

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _webSocket!.send(jsonEncode({
        "type": "answer",
        "sdp": answer.sdp,
      }));
      await _sendICECandidate();
    } catch (e) {
      print("Exception in client === ${e}");
    }
    print("Webrtc is started === ");

    //
    // _peerConnection!.onIceCandidate = (candidate) {
    //   _webSocket!. /*add*/ send(jsonEncode({
    //     "type": "candidate",
    //     "candidate": candidate.candidate,
    //     "sdpMid": candidate.sdpMid,
    //     "sdpMLineIndex": candidate.sdpMLineIndex,
    //   }));
    // };
  }

  Future<void> _handleOffer(String sdp) async {
    await _startWebRTC(sdp);

    // await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdp, "offer"));
    //
    // RTCSessionDescription answer = await _peerConnection!.createAnswer();
    // await _peerConnection!.setLocalDescription(answer);
    // _webSocket!.send(jsonEncode({
    //   "type": "answer",
    //   "sdp": answer.sdp,
    // }));
    // await _sendICECandidate();
  }

  sendAnswer() async {
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _webSocket!.send(jsonEncode({
      "type": "answer",
      "sdp": answer.sdp,
    }));
  }

  Future<void> _sendICECandidate() async {
    _peerConnection!.onIceCandidate = (candidate) {
      _webSocket!.send(jsonEncode({
        "type": "candidate",
        "candidate": candidate.candidate,
        "sdpMid": candidate.sdpMid,
        "sdpMLineIndex": candidate.sdpMLineIndex,
      }));
    };
  }

  void _disconnectWebSocket() {
    messages.clear();
    _webSocket?.close();

    _peerConnection?.close();
    _peerConnection = null;
    _remoteRenderer.srcObject = null;
    setState(() => isConnected = false);
  }

  bool isJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  void handleMessage(String message)  async {
    try {
      final decoded = json.decode(message);
      if (decoded is Map<String, dynamic>) {
        print("Received JSON object: $decoded");
        await validateResponse(message);
      } else if (decoded is List) {
        print("Received JSON array: $decoded");
      } else {
        print("Received JSON, but it's not an object or array.");
      }
    } catch (e) {
      print("Received plain string: $message");
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


  Future<void> _connectToServer() async {
    if (isConnected) return;
    if (_ipController.text.isEmpty || _portController.text.isEmpty) {
      setState(() => messages.add("⚠️ Please enter IP and port."));
      return;
    }

    setupServerUrl();

    _webSocket.connect(
      serverUrl,
          (message) async {
        await validateResponse(message);
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
      messages.add("✅ Connected to $connectionType at $serverUrl");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('P2P WebRTC Client')),
      body: Column(
        children: [
          /*Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: InputDecoration(labelText: 'Server IP'),
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
              ElevatedButton(
                  onPressed: _connectWebSocket, child: Text("Connect")),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: isConnected ? _disconnectWebSocket : null,
                child: Text("Disconnect"),
              ),
            ],
          ),*/

          Row(
            children: [
              DropdownButton<String>(
                value: connectionType,
                items: ["TCP", "WebSocket"].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    connectionType = value!;
                  });
                },
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: InputDecoration(labelText: '${connectionType} IP'),
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
              ElevatedButton(
                onPressed: _connectToServer,
                child: Text("Connect"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: isConnected ? _disconnectWebSocket : null,
                child: Text("Disconnect"),
              ),
            ],
          ),

          SizedBox(height: 10),
          // ElevatedButton(onPressed: _startWebRTC, child: Text("Start WebRTC")),
          // ✅ Prevent Overflow using Expanded
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: RTCVideoView(_remoteRenderer),
                    // child:  RTCVideoView(
                    //   _remoteRenderer,
                    //   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    //   mirror: false,
                    // ),
                  ),
                  SizedBox(height: 10),
                  // ElevatedButton(
                  //     onPressed: _callPeer, child: Text("Start Call")),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ✅ ListView in Expanded to prevent overflow
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(messages[index]),
              ),
            ),
          ),

          // ✅ Input field inside a Flexible Row
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
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
