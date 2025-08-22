import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vybzzz/common/manager/logger.dart';

class LiveStreamService extends GetxService {
  static LiveStreamService get instance => Get.find<LiveStreamService>();
  
  final RxBool isLive = false.obs;
  final RxBool isVideoOn = true.obs;
  final RxBool isAudioOn = true.obs;
  final RxInt viewerCount = 0.obs;
  final RxString streamId = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    Loggers.info('LiveStreamService initialized');
  }
  
  Future<void> startLiveStream() async {
    try {
      isLive.value = true;
      streamId.value = DateTime.now().millisecondsSinceEpoch.toString();
      Loggers.info('Live stream started with ID: ${streamId.value}');
    } catch (e) {
      Loggers.error('Failed to start live stream: $e');
      rethrow;
    }
  }
  
  Future<void> stopLiveStream() async {
    try {
      isLive.value = false;
      streamId.value = '';
      Loggers.info('Live stream stopped');
    } catch (e) {
      Loggers.error('Failed to stop live stream: $e');
      rethrow;
    }
  }
  
  void toggleVideo() {
    isVideoOn.value = !isVideoOn.value;
    Loggers.info('Video ${isVideoOn.value ? 'enabled' : 'disabled'}');
  }
  
  void toggleAudio() {
    isAudioOn.value = !isAudioOn.value;
    Loggers.info('Audio ${isAudioOn.value ? 'enabled' : 'disabled'}');
  }
  
  void updateViewerCount(int count) {
    viewerCount.value = count;
  }
}

class LiveStreamUserState {
  final String userId;
  final String username;
  final String? avatar;
  final bool isHost;
  final DateTime joinTime;
  
  LiveStreamUserState({
    required this.userId,
    required this.username,
    this.avatar,
    this.isHost = false,
    required this.joinTime,
  });
}

// Widgets de remplacement pour HMS/Zego
class HMSVideoView extends StatelessWidget {
  final String? userId;
  final BoxFit fit;
  
  const HMSVideoView({
    Key? key,
    this.userId,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Video View\nUser: ${userId ?? 'Unknown'}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ZegoCanvas extends StatelessWidget {
  final String? userId;
  final BoxFit fit;
  
  const ZegoCanvas({
    Key? key,
    this.userId,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          'Zego Canvas\nUser: ${userId ?? 'Unknown'}',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Enums de remplacement
enum ZegoViewMode { aspectFit, aspectFill, scaleToFill }
enum ZegoStreamResourceMode { local, remote }
class ZegoPlayerConfig {
  final ZegoStreamResourceMode resourceMode;
  
  const ZegoPlayerConfig({this.resourceMode = ZegoStreamResourceMode.remote});
}
