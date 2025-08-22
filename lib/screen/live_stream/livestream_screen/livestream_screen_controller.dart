import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vybzzz/common/controller/ads_controller.dart';
import 'package:vybzzz/common/controller/base_controller.dart';
import 'package:vybzzz/common/controller/firebase_firestore_controller.dart';
import 'package:vybzzz/common/extensions/user_extension.dart';
import 'package:vybzzz/common/manager/firebase_notification_manager.dart';
import 'package:vybzzz/common/manager/haptic_manager.dart';
import 'package:vybzzz/common/manager/logger.dart';
import 'package:vybzzz/common/manager/session_manager.dart';
import 'package:vybzzz/common/service/api/notification_service.dart';
import 'package:vybzzz/common/widget/confirmation_dialog.dart';
import 'package:vybzzz/languages/languages_keys.dart';
import 'package:vybzzz/model/general/settings_model.dart';
import 'package:vybzzz/model/livestream/app_user.dart';
import 'package:vybzzz/model/livestream/livestream.dart';
import 'package:vybzzz/model/livestream/livestream_comment.dart';
import 'package:vybzzz/model/livestream/livestream_user_state.dart';
import 'package:vybzzz/model/user_model/user_model.dart';
import 'package:vybzzz/screen/gift_sheet/send_gift_sheet.dart';
import 'package:vybzzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:vybzzz/screen/live_stream/live_stream_end_screen/live_stream_end_screen.dart';
import 'package:vybzzz/screen/live_stream/live_stream_end_screen/widget/livestream_summary.dart';
import 'package:vybzzz/screen/live_stream/livestream_screen/audience/widget/live_stream_join_sheet.dart';
import 'package:vybzzz/screen/live_stream/livestream_screen/host/widget/live_stream_host_top_view.dart';
import 'package:vybzzz/screen/report_sheet/report_sheet.dart';
import 'package:vybzzz/utilities/app_res.dart';
import 'package:vybzzz/utilities/asset_res.dart';
import 'package:vybzzz/utilities/firebase_const.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:zego_express_engine/zego_express_engine.dart'; // Commenté pour migration
import 'package:vybzzz/common/service/live_stream_service.dart';

class LivestreamScreenController extends BaseController {
  FirebaseFirestore db = FirebaseFirestore.instance;
  // ZegoExpressEngine zegoEngine = ZegoExpressEngine.instance; // Commenté pour migration
  final liveStreamService = LiveStreamService.instance;

  final firestoreController = Get.find<FirebaseFirestoreController>();
  final adsController = Get.find<AdsController>();

  Timer? timer;
  Timer? minViewerTimeoutTimer;
  Function? onLikeTap;

  Setting? get setting => SessionManager.instance.getSettings();

  int get minViewersThreshold => setting?.liveMinViewers ?? 0;

  int get timeoutMinutes => setting?.liveTimeout ?? 0;

  int get myUserId => SessionManager.instance.getUserID();

  RxBool isPlayerMute = false.obs;
  RxBool isMinViewerTimeout = false.obs;
  RxBool isTextEmpty = true.obs;
  bool isJoinSheetOpen = false;
  bool isFrontCamera = true;
  bool isHost;

  StreamSubscription<DocumentSnapshot<Livestream>>? liveStreamDocListener;
  StreamSubscription<QuerySnapshot<LivestreamUserState?>>?
      liveStreamUserStatesListener;
  StreamSubscription<QuerySnapshot<LivestreamComment?>>?
      liveStreamCommentsListener;

  TextEditingController textCommentController = TextEditingController();

  DocumentReference get liveStreamDocRef =>
      db.collection(FirebaseConst.liveStreams).doc(liveData.value.roomID);

  CollectionReference get liveStreamUsersRef =>
      db.collection(FirebaseConst.appUsers);

  CollectionReference get liveStreamUserStatesRef => db
      .collection(FirebaseConst.liveStreams)
      .doc(liveData.value.roomID)
      .collection(FirebaseConst.userState);

  CollectionReference get liveStreamCommentsRef => db
      .collection(FirebaseConst.liveStreams)
      .doc(liveData.value.roomID)
      .collection(FirebaseConst.comments);

  Widget? hostPreview;

  LivestreamScreenController(this.liveData, this.isHost, {this.hostPreview});

  int totalBattleSecond = 0;

  RxInt remainingBattleSeconds = 0.obs;
  RxBool isViewVisible = true.obs;

  List<LivestreamUserState> memberList = <LivestreamUserState>[];

  List<Gift> get gifts => setting?.gifts ?? [];
  RxList<LivestreamUserState> requestList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> audienceList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> invitedList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> coHostList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> audienceMemberList = <LivestreamUserState>[].obs;
  RxList<StreamView> streamViews = <StreamView>[].obs;
  RxList<LivestreamComment> comments = <LivestreamComment>[].obs;
  RxList<LivestreamUserState> liveUsersStates = <LivestreamUserState>[].obs;

  Rx<AppUser?> selectedGiftUser = Rx(null);
  Rx<VideoPlayerController?> videoPlayerController = Rx(null);

  Rx<User?> get myUser => SessionManager.instance.getUser().obs;
  Rx<Livestream> liveData;

  AudioPlayer countdownPlayer = AudioPlayer();
  AudioPlayer battleStartPlayer = AudioPlayer();
  AudioPlayer winAudioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    if (liveData.value.isDummyLive == 1) {
      initVideoPlayer();
    } else {
      totalBattleSecond =
          Duration(minutes: liveData.value.battleDuration).inSeconds;
      remainingBattleSeconds.value = totalBattleSecond;
      // zegoEngine.setAudioDeviceMode(ZegoAudioDeviceMode.General); // Commenté pour migration
      loginRoom();
      startListenEvent();
    }

    // Common listeners for all users
    listenLiveStreamData();
    listenUserState();
    fetchLiveStreamComments();
    initAudioPlayer();
    WakelockPlus.enable();
    FirebaseNotificationManager.instance
        .unsubscribeToTopic(topic: myUserId.toString());
  }

  @override
  void onClose() {
    super.onClose();
    WakelockPlus.disable();
    timer?.cancel();
    minViewerTimeoutTimer?.cancel();
    videoPlayerController.value?.dispose();
    liveStreamUserStatesListener?.cancel();
    liveStreamCommentsListener?.cancel();
    liveStreamDocListener?.cancel();
    countdownPlayer.dispose();
    winAudioPlayer.dispose();
    stopListenEvent();
    logoutRoom(4);
    if (!isHost) {
      updateLiveStreamData(
          watchingCount: -1, coHostId: FieldValue.arrayRemove([myUserId]));
    }
  }

  Future<void> initVideoPlayer() async {
    final url = liveData.value.dummyUserLink ?? '';
    if (url.isEmpty) return;

    // Dispose old controller if exists to avoid memory leak
    await videoPlayerController.value?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    isPlayerMute.value = false;

    try {
      await controller.initialize();
      controller
        ..setLooping(true)
        ..play();

      videoPlayerController.value = controller;
      videoPlayerController.value?.setLooping(true);
      updateLiveStreamData(watchingCount: 1);
    } on PlatformException catch (e) {
      showSnackBar(e.message);
      Loggers.error(e);
    }
  }

  void initAudioPlayer() {
    countdownPlayer.setAsset(AssetRes.endCountdown);
    battleStartPlayer.setAsset(AssetRes.battleStart);
    winAudioPlayer.setAsset(AssetRes.winSound);
  }

  Future<void> logoutRoom(int index) async {
    if (isHost) {
      deleteStreamOnFirebase();
    }
    stopPreview();
    stopPublish();
    // zegoEngine.logoutRoom(liveData.value.roomID ?? ''); // Commenté pour migration
  }

  Future<dynamic> loginRoom() async {
    final roomID = liveData.value.roomID ?? '';
    final userId = myUserId.toString();
    final username = myUser.value?.username ?? '';

    try {
      // Utiliser HMS au lieu de ZegoCloud
      final room = await hmsService.createAndJoinRoom(
        roomId: roomID,
        username: username,
        userId: userId,
      );

      if (room != null) {
        if (isHost) {
          startHostPublish();
          return {'success': true};
        }

        final userRef = liveStreamUsersRef.doc(userId);
        final stateRef = liveStreamUserStatesRef.doc(userId);

        // Set user document if not exists
        if (!(await userRef.get()).exists) {
          final userModel = myUser.value?.appUser;
          if (userModel != null) await userRef.set(userModel.toJson());
        }

        // Fetch user state
        final stateSnap = await stateRef
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  LivestreamUserState.fromJson(snapshot.data()!),
              toFirestore: (value, _) => value.toJson(),
            )
            .get();

        if (!stateSnap.exists) {
          User? myUser = this.myUser.value;
          if (myUser != null) {
            final initialState = myUser.streamState(time: 0);
            await stateRef.set(initialState.toJson());
            _sendCommentToFirestore(type: LivestreamCommentType.joined);
          } else {
            Loggers.error('User not found');
          }
        } else {
          final state = stateSnap.data();
          if (state != null) {
            if (state.joinTime == 0) {
              await stateRef.update({
                'joinTime': DateTime.now().millisecondsSinceEpoch,
              });
              _sendCommentToFirestore(type: LivestreamCommentType.joined);
            }
          }
        }

        return {'success': true};
      } else {
        return {'success': false, 'error': 'Failed to join HMS room'};
      }
    } catch (e) {
      Loggers.error('Failed to join HMS room: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  void startListenEvent() async {
    // Callback for updates on the status of other users in the room.
    // Users can only receive callbacks when the isUserStatusNotify property of ZegoRoomConfig is set to `true` when logging in to the room (loginRoom).
    // ZegoExpressEngine.onRoomUserUpdate = // Commenté pour migration
    //     (roomID, updateType, List<ZegoUser> userList) {
    //   // Check if multiple users are in the room
    //   if (userList.length > 1) {
    //     // Force audio to speaker
    //     ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
    //   }
    //   Loggers.info(
    //       'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    // };
    // Callback for updates on the status of the streams in the room.
    // ZegoExpressEngine.onRoomStreamUpdate = // Commenté pour migration
    //     (roomID, updateType, List<ZegoStream> streamList, extendedData) async {
    //   String priorityId = liveData.value.hostId.toString();

    //   streamList.sort((a, b) {
    //     if (a.streamID == priorityId) return -1; // a goes first
    //     if (b.streamID == priorityId) return 1; // b goes first
    //     return a.streamID.compareTo(b.streamID); // regular sorting
    //   });
    //   Loggers.info(
    //       'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
    //   switch (updateType) {
    //     case ZegoUpdateType.Add:
    //       for (final stream in streamList) {
    //         startPlayStream(stream.streamID);
    //       }
    //       break;
    //     case ZegoUpdateType.Delete:
    //       for (final stream in streamList) {
    //         if (liveData.value.roomID == stream.streamID) {
    //           if (Get.isBottomSheetOpen == false) {
    //             Get.back();
    //           }
    //           for (var element in liveUsersStates) {
    //             if (element.type == LivestreamUserType.coHost) {
    //               streamEnded();
    //             }
    //           }
    //           // Empty LiveData
    //           logoutRoom(1);
    //           stopListenEvent();
    //           liveData.value = Livestream();
    //         }
    //         streamViews
    //             .removeWhere((element) => element.streamId == stream.streamID);
    //         stopPlayStream(stream.streamID);
    //       }
    //       break;
    //   }
    // };
    // Callback for updates on the current user's room connection status.
    // ZegoExpressEngine.onRoomStateUpdate = // Commenté pour migration
    //     (roomID, state, errorCode, extendedData) {
    //   Loggers.info(
    //       'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    // };

    // Callback for updates on the current user's stream publishing changes.
    // ZegoExpressEngine.onPublisherStateUpdate = // Commenté pour migration
    //     (streamID, state, errorCode, extendedData) {
    //   switch (state) {
    //     case ZegoPublisherState.NoPublish:
    //       streamViews.removeWhere((element) => element.streamId == streamID);
    //     case ZegoPublisherState.PublishRequesting:
    //     case ZegoPublisherState.Publishing:
    //   }
    //   debugPrint(
    //       'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    // };
  }

  void stopListenEvent() {
    // ZegoExpressEngine.onRoomUserUpdate = null; // Commenté pour migration
    // ZegoExpressEngine.onRoomStreamUpdate = null; // Commenté pour migration
    // ZegoExpressEngine.onRoomStateUpdate = null; // Commenté pour migration
    // ZegoExpressEngine.onPublisherStateUpdate = null; // Commenté pour migration
  }

  Future<void> startHostPublish() async {
    if ((liveData.value.roomID ?? '').isEmpty) {
      return Loggers.error('No ID FOUND');
    }
    String streamID = liveData.value.roomID ?? '';
    streamViews.add(StreamView(
        streamID, liveData.value.hostViewID ?? -1, hostPreview!, false));
    // await zegoEngine.mutePublishStreamAudio(false); // Ensure audio is not muted // Commenté pour migration
    startMinViewerTimeoutCheck(); //  Check time to Min. Viewers Required to continue live
    pushNotificationToFollowers(liveData.value);
    return hmsService.startPublishingStream(streamID); // Modifié pour hmsService
  }

  Future<void> stopPublish() async {
    return hmsService.stopPublishingStream(); // Modifié pour hmsService
  }

  Future<void> startPlayStream(String streamID) async {
    Loggers.info('Starting to play stream: $streamID');
    int streamViewId = -1;
    try {
      await hmsService.createCanvasView((viewID) { // Modifié pour hmsService
        Loggers.info('Created remote view with ID: $viewID');
        streamViewId = viewID;
        ZegoCanvas canvas =
            ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        ZegoPlayerConfig config = ZegoPlayerConfig.defaultConfig();
        config.resourceMode =
            ZegoStreamResourceMode.Default; // live streaming (CDN)

        Loggers.info(
            'StartPlayStream playback: StreamID: $streamID, ViewMode: ${canvas.viewMode}, ResourceMode: ${config.resourceMode}');

        hmsService.startPlayingStream(streamID, canvas: canvas, config: config); // Modifié pour hmsService
      }).then((canvasViewWidget) {
        if (canvasViewWidget != null) {
          streamViews
              .add(StreamView(streamID, streamViewId, canvasViewWidget, false));
        }
        Loggers.success('Stream playback started successfully for: $streamID');
      });
    } catch (e, stackTrace) {
      Loggers.error('Failed to start playing stream: $e');
      Loggers.error('StackTrace: $stackTrace');
    }
  }

  Future<void> stopPlayStream(String streamID) async {
    Loggers.info('Stopping playback for stream: $streamID');

    try {
      hmsService.stopPlayingStream(streamID); // Modifié pour hmsService
      Loggers.success('Stopped playing stream: $streamID');

      StreamView? stream = streamViews
          .firstWhereOrNull((element) => element.streamId == streamID);

      if (stream?.streamViewId != null) {
        Loggers.info('Destroying remote view with ID: ${stream?.streamViewId}');
        await hmsService.destroyCanvasView(stream!.streamViewId); // Modifié pour hmsService
        Loggers.success('Remote view destroyed successfully.');
      }
    } catch (e, stackTrace) {
      Loggers.error('Failed to stop playing stream: $e');
      Loggers.error('StackTrace: $stackTrace');
    }
  }

  Future<void> stopPreview({int? viewId}) async {
    int id = viewId ?? -1;
    hmsService.stopPreview(); // Modifié pour hmsService
    if (id != -1) {
      await hmsService.destroyCanvasView(id); // Modifié pour hmsService
    }
  }

  Future<void> updateLiveStreamData({
    BattleType? battleType,
    LivestreamType? type,
    int? battleCreatedAt,
    int? battleDuration,
    int watchingCount = 0,
    FieldValue? coHostId,
  }) async {
    bool isExist = (await liveStreamDocRef.get()).exists;
    if (!isExist) return;

    liveStreamDocRef.update({
      if (battleType != null) FirebaseConst.battleType: battleType.value,
      if (type != null) FirebaseConst.type: type.value,
      if (battleCreatedAt != null)
        FirebaseConst.battleCreatedAt: battleCreatedAt,
      if (battleDuration != null) FirebaseConst.battleDuration: battleDuration,
      if (watchingCount != 0)
        FirebaseConst.watchingCount: FieldValue.increment(watchingCount),
      if (coHostId != null) FirebaseConst.coHostIds: coHostId
    });
  }

  void handleRequestResponse({
    required AppUser? user,
    required bool isRefused,
    LivestreamComment? comment,
  }) {
    final userId = user?.userId;
    if (userId == null) return;

    // Update user state based on refusal
    updateUserStateToFirestore(userId,
        type: isRefused
            ? LivestreamUserType.audience
            : LivestreamUserType.coHost);

    // Determine the comment to delete
    final commentToDelete = comment ??
        comments.firstWhereOrNull((element) =>
            element.senderId == userId &&
            element.commentType == LivestreamCommentType.request);

    if (commentToDelete != null) {
      liveStreamCommentsRef.doc(commentToDelete.id.toString()).delete();
    }
  }

  Future<void> deleteStreamOnFirebase() async {
    final String? roomId = liveData.value.roomID;

    if (roomId == null) {
      Loggers.error('Room ID is null. Cannot stop live stream.');
      return;
    }

    Loggers.info('Stopping live stream Room : $roomId');

    try {
      // Get all users in the livestream and delete them
      QuerySnapshot usersSnapshot = await liveStreamUserStatesRef.get();

      WriteBatch batch = db.batch();

      for (var doc in usersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      Loggers.info(
          'Deleted ${usersSnapshot.docs.length} livestream users_state.');

      // Get all Comments in the livestream and delete them
      QuerySnapshot commentsSnapshot = await liveStreamCommentsRef.get();

      for (var doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      Loggers.info(
          'Deleted ${commentsSnapshot.docs.length} livestream comments.');

      // Delete the main live stream document
      batch.delete(liveStreamDocRef);

      // Commit batch delete
      await batch.commit();
      Loggers.success(
          'livestream , users_states , comments  deleted from Firestore.');
    } catch (e, stackTrace) {
      Loggers.error('Failed to stop live stream: $e');
      Loggers.error('StackTrace: $stackTrace');
    }
  }

  void listenLiveStreamData() {
    int likeCount = liveData.value.likeCount ?? 0;
    // liveStreamDocListener?.cancel();
    liveStreamDocListener = liveStreamDocRef
        .withConverter<Livestream>(
          fromFirestore: (snapshot, _) {
            if (!snapshot.exists) {
              Loggers.error(
                  'Livestream document not found for Room ID: ${liveData.value.roomID}');
              return Livestream(); // default instance
            }
            return Livestream.fromJson(snapshot.data()!);
          },
          toFirestore: (value, _) => value.toJson(),
        )
        .snapshots()
        .listen(
      (event) async {
        final stream = event.data();
        if (stream == null) {
          Loggers.warning('Livestream data is null');
          return;
        }

        if (stream.battleType == BattleType.initiate) {
          timer?.cancel();
          remainingBattleSeconds.value =
              Duration(minutes: stream.battleDuration).inSeconds;
          countdownPlayer.pause();
        }

        if (stream.battleType == BattleType.waiting) {
          totalBattleSecond =
              Duration(minutes: stream.battleDuration).inSeconds;
        }

        // Update LiveData
        liveData.value = stream;

        // Trigger like animation if changed
        final newLikeCount = stream.likeCount ?? 0;
        if (likeCount != newLikeCount) {
          onLikeTap?.call();
          likeCount = newLikeCount;
        }
      },
      onError: (error) =>
          Loggers.error('Error listening to livestream: $error'),
    );
  }

  void listenUserState() {
    // Cancel any existing listener
    liveStreamUserStatesListener?.cancel();
    // Loggers.info('👂 Listening to live stream users state...');

    liveStreamUserStatesListener = liveStreamUserStatesRef
        .withConverter(
          fromFirestore: (snapshot, options) {
            if (!snapshot.exists) return null;
            return LivestreamUserState.fromJson(snapshot.data()!);
          },
          toFirestore: (value, options) {
            if (value == null) return {};
            return value.toJson();
          },
        )
        .snapshots()
        .listen((event) {
          // Loggers.info(
          //     '📦 Firestore snapshot received with ${event.docChanges.length} changes');

          for (var change in event.docChanges) {
            final state = change.doc.data();
            if (state == null) {
              // Loggers.warning('⚠️ Null state found in change, skipping...');
              continue;
            }

            switch (change.type) {
              case DocumentChangeType.added:
                _showJoinStreamSheet(state);
                liveUsersStates.add(state);
                // Loggers.info('➕ User added: ${state.userId}');
                break;

              case DocumentChangeType.modified:
                LivestreamUserState? oldState =
                    liveUsersStates.firstWhereOrNull(
                        (element) => element.userId == state.userId);
                updateStateAction(oldState, state);
                liveUsersStates.removeWhere((u) => u.userId == state.userId);
                liveUsersStates.add(state);
                // Loggers.info('🔁 User modified: ${state.userId}');
                break;

              case DocumentChangeType.removed:
                liveUsersStates.removeWhere((u) => u.userId == state.userId);
                // Loggers.info('➖ User removed: ${state.userId}');
                break;
            }
          }
          requestList.value = liveUsersStates
              .where((element) => element.type == LivestreamUserType.requested)
              .toList();
          audienceList.value = liveUsersStates
              .where((element) =>
                  element.type != LivestreamUserType.host &&
                  element.type != LivestreamUserType.left)
              .toList();
          invitedList.value = liveUsersStates
              .where((element) => element.type == LivestreamUserType.invited)
              .toList();
          coHostList.value = liveUsersStates
              .where((element) => element.type == LivestreamUserType.coHost)
              .toList();
          audienceMemberList.value = liveUsersStates
              .where((element) =>
                  element.type != LivestreamUserType.left &&
                  element.userId != myUserId)
              .toList();
        });
  }

  void fetchLiveStreamComments() {
    Loggers.info('Fetching live stream comments...');
    liveStreamCommentsListener?.cancel();
    liveStreamCommentsListener = liveStreamCommentsRef
        .withConverter(
          fromFirestore: (snapshot, options) {
            if (!snapshot.exists) {
              Loggers.error('No comments found in Firestore.');
              return null;
            }
            return LivestreamComment.fromJson(snapshot.data()!);
          },
          toFirestore: (value, options) => value?.toJson() ?? {},
        )
        .snapshots()
        .listen((querySnapshot) {
      // Loggers.info(
      //     'Received comment changes: ${querySnapshot.docChanges.length}');

      for (var change in querySnapshot.docChanges) {
        LivestreamComment? comment = change.doc.data();
        if (comment == null) {
          Loggers.error('Null comment received.');
          continue;
        }

        switch (change.type) {
          case DocumentChangeType.added:
            if (comment.commentType == LivestreamCommentType.request &&
                !isHost) {
              continue;
            }
            comments.add(comment);
            // Loggers.info('New comment added: ${comment.toJson()}');
            break;

          case DocumentChangeType.modified:
            if (comment.commentType == LivestreamCommentType.request &&
                !isHost) {
              return;
            }
            int index = comments.indexWhere((c) => c.id == comment.id);
            if (index != -1) {
              comments[index] = comment;
              // Loggers.info('Comment modified: ${comment.toJson()}');
            }
            break;

          case DocumentChangeType.removed:
            comments.removeWhere((c) => c.id == comment.id);
            // Loggers.info('Comment removed: ${comment.id}');
            break;
        }
      }

      // Assign sender and receiver users to comments
      for (var comment in comments) {
        comment.gift =
            gifts.firstWhereOrNull((gift) => gift.id == comment.giftId);
      }

      comments.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    });
  }

  void toggleCamera() {
    isFrontCamera = !isFrontCamera;
    // zegoEngine.useFrontCamera(isFrontCamera, channel: ZegoPublishChannel.Main); // Commenté pour migration
  }

  void toggleFlipCamera() {
    isFrontCamera = !isFrontCamera;
    // zegoEngine.useFrontCamera(isFrontCamera, channel: ZegoPublishChannel.Main); // Commenté pour migration
  }

  void toggleMic(LivestreamUserState? state) async {
    if (state?.audioStatus == VideoAudioStatus.offByHost) {
      return showSnackBar(LKey.theHostHasTurnedOffYourAudio);
    }

    bool isAudioOn = state?.audioStatus == VideoAudioStatus.on;

    if (isAudioOn) {
      updateUserStateToFirestore(myUserId,
          audioStatus: VideoAudioStatus.offByMe);
      // zegoEngine.muteMicrophone(false); // Commenté pour migration
    } else {
      updateUserStateToFirestore(myUserId, audioStatus: VideoAudioStatus.on);
      // zegoEngine.muteMicrophone(true); // Commenté pour migration
    }
  }

  void toggleVideo(LivestreamUserState? state) {
    if (state?.videoStatus == VideoAudioStatus.offByHost) {
      return showSnackBar(LKey.theHostHasTurnedOffYourVideo.tr);
    }
    bool isVideoOn = state?.videoStatus == VideoAudioStatus.on;

    if (isVideoOn) {
      updateUserStateToFirestore(myUserId,
          videoStatus: VideoAudioStatus.offByMe);
      // zegoEngine.enableCamera(false); // Commenté pour migration
    } else {
      updateUserStateToFirestore(myUserId, videoStatus: VideoAudioStatus.on);
      // zegoEngine.enableCamera(true); // Commenté pour migration
    }
  }

  void toggleStreamAudio(int? streamId) {
    StreamView? view = streamViews
        .firstWhereOrNull((element) => int.parse(element.streamId) == streamId);

    // zegoEngine.mutePlayStreamAudio( // Commenté pour migration
    //     '$streamId', (view?.isMuted ?? false) ? false : true);
    view?.isMuted = view.isMuted ? false : true;
    if (view != null) {
      streamViews[streamViews.indexWhere(
          (element) => int.parse(element.streamId) == streamId)] = view;
      streamViews.refresh();
    }
  }

  void onLikeButtonTap() async {
    bool isExist = (await liveStreamDocRef.get()).exists;
    if (isExist) {
      HapticManager.shared.light();
      liveStreamDocRef
          .update({FirebaseConst.likeCount: FieldValue.increment(1)});
    }
  }

  void onTextCommentSend() {
    String comment = textCommentController.text.trim();
    textCommentController.clear();
    isTextEmpty.value = true;
    if (comment.isEmpty) return;
    _sendCommentToFirestore(type: LivestreamCommentType.text, comment: comment);
  }

  void onGiftTap(GiftType type,
      {BattleView battleViewType = BattleView.red,
      List<AppUser> users = const []}) {
    users.removeWhere((element) => element.userId == myUserId);
    if (liveData.value.type == LivestreamType.battle &&
        liveData.value.battleType == BattleType.end) {
      return showSnackBar(LKey.battleEndedGiftNotSent.tr);
    }
    GiftManager.openGiftSheet(
        onCompletion: (giftManager) {
          Gift gift = giftManager.gift;
          AppUser? user = giftManager.streamUser;

          int coinPrice = gift.coinPrice?.toInt() ?? 0;

          _sendCommentToFirestore(
              type: LivestreamCommentType.gift,
              giftId: gift.id,
              receiverId: user?.userId);
          updateUserStateToFirestore(
            user?.userId,
            battleCoin: type == GiftType.battle ? coinPrice : null,
            currentBattleCoin: type == GiftType.battle ? coinPrice : null,
            liveCoin: type == GiftType.livestream ? coinPrice : null,
          );
        },
        giftType: type,
        battleViewType: battleViewType,
        streamUsers: users);
  }

  _sendCommentToFirestore(
      {required LivestreamCommentType type,
      String? comment,
      int? giftId,
      int? receiverId}) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    try {
      await _addUsersFirebaseFireStore();
      liveStreamCommentsRef.doc('$time').set(LivestreamComment(
              comment: comment,
              commentType: type,
              id: time,
              senderId: myUserId,
              receiverId: receiverId,
              giftId: giftId)
          .toJson());
    } catch (e) {
      Loggers.error('Message Error : $e');
    }
  }

  Future<void> _addUsersFirebaseFireStore() async {
    DocumentReference myUserRef = liveStreamUsersRef.doc(myUserId.toString());

    DocumentSnapshot isMyUserExist = await myUserRef.get();
    if (myUser.value != null) {
      if (isMyUserExist.exists) {
        myUserRef.update(myUser.value!.appUser.toJson());
      } else {
        myUserRef.set(myUser.value?.appUser.toJson());
      }
    }
  }

  void onVideoRequestSend(Livestream liveData) {
    LivestreamUserState? state = liveUsersStates
        .firstWhereOrNull((element) => element.userId == myUserId);
    switch (state?.type) {
      case null:
        break;
      case LivestreamUserType.audience:
        updateUserStateToFirestore(myUserId,
            type: LivestreamUserType.requested);
        _sendCommentToFirestore(
            type: LivestreamCommentType.request, receiverId: liveData.hostId);
        showSnackBar(LKey.requestJoinToHost.tr);
        break;
      case LivestreamUserType.requested:
        showSnackBar(LKey.joinRequestSentDescription.tr);
        break;
      case LivestreamUserType.host:
      case LivestreamUserType.coHost:
      case LivestreamUserType.invited:
      case LivestreamUserType.left:
        break;
    }
  }

  Future<void> updateUserStateToFirestore(
    int? userId, {
    LivestreamUserType? type,
    VideoAudioStatus? audioStatus,
    VideoAudioStatus? videoStatus,
    int? battleCoin,
    int? liveCoin,
    bool? isFollow,
    int? joinTime,
    int? currentBattleCoin,
  }) async {
    if (userId == null) {
      Loggers.error('updateUserStateToFirestore: userId is null');
      return;
    }

    DocumentReference reference =
        liveStreamUserStatesRef.doc(userId.toString());
    bool isExist = (await reference.get()).exists;
    if (!isExist) {
      Loggers.error('updateUserStateToFirestore Not Found $userId');
      return;
    }

    try {
      final updateData = <String, dynamic>{
        if (type != null) FirebaseConst.type: type.value,
        if (audioStatus != null) FirebaseConst.audioStatus: audioStatus.value,
        if (videoStatus != null) FirebaseConst.videoStatus: videoStatus.value,
        if (battleCoin != null)
          FirebaseConst.totalBattleCoin:
              battleCoin == 0 ? 0 : FieldValue.increment(battleCoin),
        if (currentBattleCoin != null)
          FirebaseConst.currentBattleCoin: currentBattleCoin == 0
              ? 0
              : FieldValue.increment(currentBattleCoin),
        if (liveCoin != null)
          FirebaseConst.liveCoin:
              liveCoin == 0 ? 0 : FieldValue.increment(liveCoin),
        if (isFollow != null)
          FirebaseConst.followersGained: isFollow
              ? FieldValue.arrayUnion([myUserId])
              : FieldValue.arrayRemove([myUserId]),
        if (joinTime != null) FirebaseConst.joinStreamTime: joinTime,
      };
      if (battleCoin != null || liveCoin != null) {
        myUser.value?.coinEstimatedValue(
            battleCoin?.toDouble() ?? liveCoin?.toDouble());
        SessionManager.instance.setUser(myUser.value);
      }
      await liveStreamUserStatesRef.doc(userId.toString()).update(updateData);
      Loggers.success('User state updated for userId: $userId');
    } catch (e, stack) {
      Loggers.error('Failed to update user state: $e\n$stack');
    }
  }

  void onInvite(AppUser? user, {bool isInvited = false}) {
    updateUserStateToFirestore(user?.userId,
        type: isInvited
            ? LivestreamUserType.audience
            : LivestreamUserType.invited);
  }

  void _showJoinStreamSheet(LivestreamUserState state) {
    if (state.userId == myUserId && state.type == LivestreamUserType.invited) {
      AppUser? hostUser = liveData.value.getHostUser(firestoreController.users);
      isJoinSheetOpen = true;
      Get.bottomSheet(
              LiveStreamJoinSheet(
                  hostUser: hostUser,
                  myUser: myUser.value,
                  onJoined: () async {
                    LivestreamUserState? userState =
                        liveUsersStates.firstWhereOrNull(
                            (element) => element.userId == myUserId);
                    if (userState?.type == LivestreamUserType.invited) {
                      updateUserStateToFirestore(myUserId,
                          type: LivestreamUserType.coHost);
                    } else {
                      showSnackBar(LKey.joinCancelledDescription.tr);
                    }
                  },
                  onCancel: () {
                    updateUserStateToFirestore(myUserId,
                        type: LivestreamUserType.audience);
                  }),
              isScrollControlled: true,
              enableDrag: false,
              isDismissible: false)
          .then(
        (value) {
          isJoinSheetOpen = false;
        },
      );
    }
  }

  void publishCoHostStream(int streamId) async {
    bool isPermissionGranted = await requestPermission();
    if (isPermissionGranted) {
      int canvasViewID = -1;

      // ✅ Enable camera and microphone
      // await zegoEngine.enableCamera(true); // Commenté pour migration
      // await zegoEngine.mutePublishStreamAudio(false); // Commenté pour migration
      // zegoEngine.muteMicrophone(false); // Commenté pour migration

      // ✅ Create preview canvas and start preview
      await hmsService.createCanvasView((viewID) async { // Modifié pour hmsService
        canvasViewID = viewID;
        ZegoCanvas previewCanvas =
            ZegoCanvas(canvasViewID, viewMode: ZegoViewMode.AspectFill);
        // zegoEngine.startPreview(canvas: previewCanvas); // Commenté pour migration
      }).then((canvasViewWidget) {
        if (canvasViewWidget != null) {
          streamViews.add(
            StreamView('$streamId', canvasViewID, canvasViewWidget, false),
          );
        }
      });

      // ✅ Publish the stream
      await hmsService.startPublishingStream('$streamId'); // Modifié pour hmsService

      // ✅ Force audio output to speaker (after stream starts)
      Future.delayed(const Duration(milliseconds: 300), () {
        // zegoEngine.setAudioRouteToSpeaker(true); // Commenté pour migration
      });

      updateLiveStreamData(coHostId: FieldValue.arrayUnion([streamId]));
      _sendCommentToFirestore(type: LivestreamCommentType.joinedCoHost);
      updateUserStateToFirestore(myUserId,
          joinTime: DateTime.now().millisecondsSinceEpoch);
    } else {
      Get.bottomSheet(ConfirmationSheet(
        title: LKey.cameraMicrophonePermissionTitle.tr,
        description: LKey.cameraMicrophonePermissionDescription.tr,
        onTap: openAppSettings,
      ));
    }
  }

  Future<bool> requestPermission() async {
    Loggers.info("requestPermission...");
    try {
      PermissionStatus microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted) {
        Loggers.error('Error: Microphone permission not granted!!!');
        return false;
      }
    } on Exception catch (error) {
      Loggers.error("[ERROR], request microphone permission exception, $error");
    }

    try {
      PermissionStatus cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        Loggers.error('Error: Camera permission not granted!!!');
        return false;
      }
    } on Exception catch (error) {
      Loggers.error("[ERROR], request camera permission exception, $error");
    }

    return true;
  }

  void closeCoHostStream(int? streamId) {
    StreamView? view = streamViews
        .firstWhereOrNull((element) => element.streamId == '$streamId');
    if (view != null) {
      stopPreview(viewId: view.streamViewId);
      stopPublish();
      updateLiveStreamData(coHostId: FieldValue.arrayRemove([streamId]));
      LivestreamComment? comment = comments.firstWhereOrNull((element) =>
          element.senderId == myUserId &&
          element.commentType == LivestreamCommentType.joinedCoHost);
      if (comment != null) {
        liveStreamCommentsRef.doc(comment.id.toString()).delete();
      }
      updateUserStateToFirestore(streamId,
          type: LivestreamUserType.audience,
          audioStatus: VideoAudioStatus.offByMe,
          videoStatus: VideoAudioStatus.offByMe,
          battleCoin: 0,
          currentBattleCoin: 0);
      streamViews.removeWhere((element) => element.streamId == '$streamId');
      stopPlayStream(streamId.toString());
      streamEnded();
    }
  }

  void coHostVideoToggle(LivestreamUserState state) {
    if (state.videoStatus == VideoAudioStatus.offByMe) {
      return showSnackBar(LKey.theCoHostHasTurnedOffTheirVideo);
    }

    updateUserStateToFirestore(state.userId,
        videoStatus: state.videoStatus == VideoAudioStatus.on
            ? VideoAudioStatus.offByHost
            : VideoAudioStatus.on);
  }

  void coHostAudioToggle(LivestreamUserState state) {
    if (state.audioStatus == VideoAudioStatus.offByMe) {
      return showSnackBar(LKey.theCoHostHasTurnedOffTheirAudio);
    }

    updateUserStateToFirestore(state.userId,
        audioStatus: state.audioStatus == VideoAudioStatus.on
            ? VideoAudioStatus.offByHost
            : VideoAudioStatus.on);
  }

  void updateStateAction(
      LivestreamUserState? oldState, LivestreamUserState newState) {
    if (newState.userId == myUserId) {
      Loggers.info('Updating state for userId: ${newState.toJson()}');
      if (newState.type == LivestreamUserType.coHost &&
          oldState?.type != LivestreamUserType.coHost) {
        publishCoHostStream(myUserId);
      }

      if (newState.type == LivestreamUserType.audience &&
          oldState?.type == LivestreamUserType.invited &&
          isJoinSheetOpen) {
        Get.back();
      }

      if (newState.type == LivestreamUserType.invited &&
          oldState?.type == LivestreamUserType.audience) {
        _showJoinStreamSheet(newState);
      }
      if (oldState?.videoStatus != newState.videoStatus) {
        bool isVideoOn =
            newState.videoStatus == VideoAudioStatus.on ? false : true;
        // zegoEngine.enableCamera(isVideoOn); // Commenté pour migration
      }
      if (oldState?.audioStatus != newState.audioStatus) {
        bool isAudioOn =
            newState.audioStatus == VideoAudioStatus.on ? false : true;
        // zegoEngine.muteMicrophone(isAudioOn); // Commenté pour migration
      }
      if (oldState?.type == LivestreamUserType.coHost &&
          newState.type == LivestreamUserType.audience) {
        closeCoHostStream(newState.userId);
      }
    }
  }

  void coHostDelete(LivestreamUserState state) {
    if (state.type == LivestreamUserType.coHost) {
      updateLiveStreamData(coHostId: FieldValue.arrayRemove([state.userId]));
      updateUserStateToFirestore(state.userId,
          type: LivestreamUserType.audience);
    }
  }

  void reportUser(int? userId) {
    Get.bottomSheet(ReportSheet(reportType: ReportType.user, id: userId),
        isScrollControlled: true);
  }

  void _timerStart(VoidCallback callBack) {
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (t) {
        callBack.call();
        // if (t.tick >= totalBattleSecond) {
        //   timer?.cancel();
        // }
      },
    );
  }

  void onStopButtonTap() {
    bool isBattleOn = liveData.value.type == LivestreamType.battle;
    String title =
        !isBattleOn ? LKey.endStreamTitle.tr : LKey.stopBattleTitle.tr;
    String description =
        !isBattleOn ? LKey.endStreamMessage.tr : LKey.stopBattleDescription.tr;

    Get.bottomSheet(
        StopLiveStreamSheet(
            onTap: () {
              if (isBattleOn) {
                updateLiveStreamData(
                    battleType: BattleType.initiate,
                    type: LivestreamType.livestream);
                startMinViewerTimeoutCheck();
              } else {
                hostEndStream();
              }
            },
            title: title,
            description: description,
            positiveText: LKey.stop.tr),
        isScrollControlled: true);
  }

  void hostEndStream() {
    streamEnded();
    logoutRoom(2);
  }

  void streamEnded() {
    LivestreamUserState? userState = liveUsersStates
        .firstWhereOrNull((element) => element.userId == myUserId);
    AppUser? user = firestoreController.users
        .firstWhereOrNull((element) => element.userId == myUserId);
    userState?.user = user;
    int viewers = liveUsersStates.length;
    if (isHost) {
      Get.back();
      Get.off(() => LiveStreamEndScreen(
          userState: userState, isHost: isHost, viewers: viewers));
    } else {
      if (userState?.type == LivestreamUserType.coHost) {
        Get.bottomSheet(
                LiveStreamSummary(
                    userState: userState, isHost: isHost, viewers: viewers),
                isScrollControlled: true)
            .then((value) {
          updateUserStateToFirestore(myUserId,
              battleCoin: 0, liveCoin: 0, currentBattleCoin: 0);
          if ((liveData.value.roomID ?? '').isEmpty) {
            Get.back();
          }
        });
      }
    }
  }

  togglePlayerAudioToggle() {
    videoPlayerController.value?.setVolume(isPlayerMute.value ? 1 : 0);
    isPlayerMute.value = !isPlayerMute.value;
  }

  void toggleView() {
    isViewVisible.value = !isViewVisible.value;
  }

  void startBattle() {
    updateLiveStreamData(
      battleType: BattleType.waiting,
      battleDuration: AppRes.battleDurationInMinutes,
      battleCreatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void battleRunning() {
    Livestream stream = liveData.value;
    // Battle Start Timer Logic

    final startTime =
        DateTime.fromMillisecondsSinceEpoch(stream.battleCreatedAt ?? 0);
    final endTime = startTime
        .add(Duration(seconds: totalBattleSecond + AppRes.battleStartInSecond));

    Loggers.success('Battle Timer Started');

    _timerStart(() {
      final remaining = endTime.difference(DateTime.now()).inSeconds;
      remainingBattleSeconds.value = remaining.clamp(0, totalBattleSecond);

      if (remainingBattleSeconds.value <= 10) {
        if (!countdownPlayer.playing) {
          countdownPlayer
              .seek(Duration(seconds: 10 - remainingBattleSeconds.value));
          countdownPlayer.play();
        }
      }

      Loggers.info(
          '[BATTLE RUNNING] Battle end in ${remainingBattleSeconds.value} sec.');

      if (remainingBattleSeconds.value <= 0) {
        winAudioPlayer.seek(const Duration(seconds: 0));
        winAudioPlayer.play();
        timer?.cancel();
        updateLiveStreamData(battleType: BattleType.end);
      }
    });
  }

  void startMinViewerTimeoutCheck() {
    if (minViewerTimeoutTimer?.isActive ?? false) return;
    Loggers.info(
        'Check Min. Viewers Required to continue live $timeoutMinutes Minutes');
    minViewerTimeoutTimer =
        Timer.periodic(Duration(minutes: timeoutMinutes), (_) {
      minViewerTimeoutTimer?.cancel();
      if ((liveData.value.watchingCount ?? 0) <= minViewersThreshold) {
        isMinViewerTimeout.value = true;
        Loggers.info('Close Stream Because of Min. Viewers');
      }
    });
  }

  void onCloseAudienceBtn() {
    HapticManager.shared.light();
    Get.bottomSheet(ConfirmationSheet(
        title: LKey.exitLiveStreamTitle.tr,
        description: LKey.exitLiveStreamDescription.tr,
        onTap: () async {
          adsController.showInterstitialAdIfAvailable();
          if (liveData.value.coHostIds?.contains(myUserId) ?? false) {
            closeCoHostStream(myUserId);
          }
          logoutRoom(3);
        }));
  }

  void pushNotificationToFollowers(Livestream liveData) {
    AppUser? hostUser = liveData.getHostUser([]);
    NotificationService.instance.pushNotification(
        type: NotificationType.liveStream,
        title: LKey.liveStreamNotificationTitle
            .trParams({'name': hostUser?.username ?? ''}),
        body: LKey.liveStreamNotificationBody.tr,
        deviceType: 1,
        topic: '${liveData.hostId}_ios',
        data: liveData.toJson());
    NotificationService.instance.pushNotification(
        type: NotificationType.liveStream,
        title: LKey.liveStreamNotificationTitle
            .trParams({'name': hostUser?.username ?? ''}),
        body: LKey.liveStreamNotificationBody.tr,
        deviceType: 0,
        topic: '${liveData.hostId}_android',
        data: liveData.toJson());
  }
}

class StreamView {
  String streamId;
  int streamViewId;
  Widget streamView;
  bool isMuted;

  StreamView(this.streamId, this.streamViewId, this.streamView, this.isMuted);
}
