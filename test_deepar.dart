import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybzzz/common/service/live_stream_service.dart';

void main() {
  group('DeepAR Integration Tests', () {
    test('LiveStreamService should initialize correctly', () {
      final service = LiveStreamService();
      expect(service.isLive.value, false);
      expect(service.isVideoOn.value, true);
      expect(service.isAudioOn.value, true);
      expect(service.viewerCount.value, 0);
      expect(service.streamId.value, '');
    });

    test('LiveStreamService should toggle video correctly', () {
      final service = LiveStreamService();
      final initialValue = service.isVideoOn.value;
      
      service.toggleVideo();
      expect(service.isVideoOn.value, !initialValue);
      
      service.toggleVideo();
      expect(service.isVideoOn.value, initialValue);
    });

    test('LiveStreamService should toggle audio correctly', () {
      final service = LiveStreamService();
      final initialValue = service.isAudioOn.value;
      
      service.toggleAudio();
      expect(service.isAudioOn.value, !initialValue);
      
      service.toggleAudio();
      expect(service.isAudioOn.value, initialValue);
    });

    test('LiveStreamService should start and stop live stream', () async {
      final service = LiveStreamService();
      
      expect(service.isLive.value, false);
      expect(service.streamId.value, '');
      
      await service.startLiveStream();
      expect(service.isLive.value, true);
      expect(service.streamId.value.isNotEmpty, true);
      
      await service.stopLiveStream();
      expect(service.isLive.value, false);
      expect(service.streamId.value, '');
    });

    test('LiveStreamService should update viewer count', () {
      final service = LiveStreamService();
      
      service.updateViewerCount(10);
      expect(service.viewerCount.value, 10);
      
      service.updateViewerCount(25);
      expect(service.viewerCount.value, 25);
    });
  });

  group('DeepAR Widget Tests', () {
    testWidgets('HMSVideoView should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HMSVideoView(
              userId: 'test_user_123',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

      // Attendre que le widget soit rendu
      await tester.pump();
      
      expect(find.textContaining('Video View'), findsOneWidget);
      expect(find.textContaining('test_user_123'), findsOneWidget);
    });

    testWidgets('ZegoCanvas should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZegoCanvas(
              userId: 'test_user_456',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

      // Attendre que le widget soit rendu
      await tester.pump();
      
      expect(find.textContaining('Zego Canvas'), findsOneWidget);
      expect(find.textContaining('test_user_456'), findsOneWidget);
    });
  });

  group('DeepAR Model Tests', () {
    test('LiveStreamUserState should create correctly', () {
      final now = DateTime.now();
      final userState = LiveStreamUserState(
        userId: 'test_user',
        username: 'Test User',
        avatar: 'avatar.jpg',
        isHost: true,
        joinTime: now,
      );

      expect(userState.userId, 'test_user');
      expect(userState.username, 'Test User');
      expect(userState.avatar, 'avatar.jpg');
      expect(userState.isHost, true);
      expect(userState.joinTime, now);
    });

    test('ZegoPlayerConfig should create correctly', () {
      final config = ZegoPlayerConfig(
        resourceMode: ZegoStreamResourceMode.remote,
      );

      expect(config.resourceMode, ZegoStreamResourceMode.remote);
    });
  });
}

// Test de compilation pour vérifier que tous les imports fonctionnent
class DeepARCompilationTest {
  void testImports() {
    // Test des enums
    final viewMode = ZegoViewMode.aspectFit;
    final resourceMode = ZegoStreamResourceMode.local;
    
    // Test des classes
    final playerConfig = ZegoPlayerConfig(resourceMode: resourceMode);
    
    // Test des services
    final liveStreamService = LiveStreamService();
    
    // Test des widgets
    final videoView = HMSVideoView(userId: 'test');
    final canvas = ZegoCanvas(userId: 'test');
    
    // Test des modèles
    final userState = LiveStreamUserState(
      userId: 'test',
      username: 'test',
      joinTime: DateTime.now(),
    );
    
    // Si on arrive ici, la compilation est réussie
    print('✅ Tous les imports DeepAR fonctionnent correctement');
  }
}
