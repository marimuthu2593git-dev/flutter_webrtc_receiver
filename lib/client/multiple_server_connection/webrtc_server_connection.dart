import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../allplatform/websocket_stub.dart';

class WebRTCServerConnection {
  final String ip;
  final String port;
  final RTCVideoRenderer renderer;
  RTCPeerConnection? peerConnection;
  dynamic webSocket;
  bool isAudioEnabled = true;

  WebRTCServerConnection({required this.ip, required this.port})
      : renderer = RTCVideoRenderer();

  Future<void> initialize(
      Function onMessage, Function onDisconnect, Function onError) async {
    await renderer.initialize();
    webSocket = PlatformWebSocket();
    webSocket.connect(
      'ws://$ip:$port',
      (message) => onMessage(this, message),
      () => onDisconnect(this),
      (err) => onError(this, err),
    );
  }

  Future<void> handleOffer(String sdp) async {
    peerConnection = await createPeerConnection({
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"}
      ]
    });

    peerConnection!.onTrack = (event) {
      if (event.track.kind == "video") {
        renderer.srcObject = event.streams.first;
      }
      if (event.track.kind == "audio" && !isAudioEnabled) {
        event.track.enabled = false;
      }
    };

    peerConnection!.onIceCandidate = (candidate) {
      webSocket.send(jsonEncode({
        "type": "candidate",
        "candidate": candidate.candidate,
        "sdpMid": candidate.sdpMid,
        "sdpMLineIndex": candidate.sdpMLineIndex,
      }));
    };

    await peerConnection!
        .setRemoteDescription(RTCSessionDescription(sdp, "offer"));
    RTCSessionDescription answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    webSocket.send(jsonEncode({
      "type": "answer",
      "sdp": answer.sdp,
    }));
  }

  Future<void> addCandidate(Map<String, dynamic> data) async {
    await peerConnection?.addCandidate(
      RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
    );
  }

  void toggleAudio() {
    isAudioEnabled = !isAudioEnabled;
    var audioTracks = renderer.srcObject?.getAudioTracks();
    if (audioTracks != null) {
      for (var track in audioTracks) {
        track.enabled = isAudioEnabled;
      }
    }
  }

  void dispose() {
    renderer.dispose();
    peerConnection?.close();
    webSocket?.close();
  }
}
