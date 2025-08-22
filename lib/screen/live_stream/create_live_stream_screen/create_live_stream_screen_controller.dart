import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vybzzz/common/controller/base_controller.dart';
import 'package:vybzzz/common/extensions/user_extension.dart';
import 'package:vybzzz/common/manager/logger.dart';
import 'package:vybzzz/common/manager/session_manager.dart';
import 'package:vybzzz/common/widget/confirmation_dialog.dart';
import 'package:vybzzz/languages/languages_keys.dart';
import 'package:vybzzz/model/general/settings_model.dart';
import 'package:vybzzz/model/livestream/app_user.dart';
import 'package:vybzzz/model/livestream/livestream.dart';
import 'package:vybzzz/model/livestream/livestream_user_state.dart';
import 'package:vybzzz/model/user_model/user_model.dart';
import 'package:vybzzz/screen/live_stream/livestream_screen/host/livestream_host_screen.dart';
import 'package:vybzzz/utilities/firebase_const.dart';
// import 'package:zego_express_engine/zego_express_engine.dart'; // Commenté pour migration
import 'package:vybzzz/common/service/live_stream_service.dart';

class CreateLiveStreamScreenController extends BaseController {
  RxBool isRestricted = false.obs;
  bool isFrontCamera = true;
  FirebaseFirestore db = FirebaseFirestore.instance;
  // ZegoExpressEngine zegoEngine = ZegoExpressEngine.instance; // Commenté pour migration
  final liveStreamService = LiveStreamService.instance;

  Rx<User?> get myUser => SessionManager.instance.getUser().obs;

  Setting? get _setting => SessionManager.instance.getSettings();
  Rx<Widget?> localView = Rx(null);
  RxInt localViewID = RxInt(-1);
  TextEditingController titleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initZegoEngine();
  }

  @override
  void onClose() {
    super.onClose();
    stopPreview();
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
      return false;
    }

    try {
      PermissionStatus cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        Loggers.error('[Error]: Camera permission not granted!!!');
        return false;
      }
    } on Exception catch (error) {
      Loggers.error("[ERROR], request camera permission exception, $error");
      return false;
    }

    return true;
  }

  void initZegoEngine() async {
    bool isPermissionGranted = await requestPermission();
    if (isPermissionGranted) {
      await initializeCameraPreview();
    } else {
      Get.bottomSheet(ConfirmationSheet(
          title: LKey.cameraMicrophonePermissionTitle.tr,
          description: LKey.cameraMicrophonePermissionDescription.tr,
          onTap: openAppSettings));
    }
  }

  Future<void> initializeCameraPreview() async {
    try {
      showLoader();
      
      // Créer une vue locale simplifiée pour la preview
      localViewID.value = DateTime.now().millisecondsSinceEpoch;
      Loggers.info('LOCAL VIEW ID : $localViewID');
      
      // Utiliser la vue simplifiée pour la preview
      localView.value = HMSVideoView(
        userId: myUser.value?.id.toString(),
        fit: BoxFit.cover,
      );
      
      Loggers.info('Preview initialized successfully');
    } catch (e, stackTrace) {
      // Log any errors during the preview setup
      Loggers.error('Failed to initialize preview: $e\n$stackTrace');
    } finally {
      stopLoader();
    }
  }

  void toggleCamera() {
    isFrontCamera = !isFrontCamera;
    // zegoEngine.useFrontCamera(isFrontCamera, channel: ZegoPublishChannel.Main); // Commenté pour migration
  }

  void onCloseTap() {
    Get.back();
    stopPreview();
  }

  Future<void> stopPreview() async {
    // zegoEngine.stopPreview(); // Commenté pour migration
    if (localViewID.value != -1) {
      // await zegoEngine.destroyCanvasView(localViewID.value); // Commenté pour migration
      localViewID.value = -1;
      localView.value = null;
    }
  }

  Future<void> onStartLive() async {
    if ((myUser.value?.followerCount ?? 0) <
        (_setting?.minFollowersForLive ?? 0)) {
      showSnackBar(LKey.minFollowersNeededToGoLive
          .trParams({'count': '${_setting?.minFollowersForLive}'}));
      return;
    }

    if (titleController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterLiveStreamTitle.tr);
    }

    User? user = myUser.value;
    if (user == null) {
      Loggers.error('User Not found. Cannot start live stream.');
      return;
    }
    int userId = user.id ?? -1;

    if (userId == -1) {
      Loggers.error('Wrong User ID is $userId');
      return;
    }

    if (localView.value == null) {
      showSnackBar('Local View not found');
      return;
    }

    // Create Livestream model
    int time = DateTime.now().millisecondsSinceEpoch;

    Livestream livestream = user.livestream(
        type: LivestreamType.livestream,
        time: time,
        description: titleController.text.trim(),
        restrictToJoin: isRestricted.value ? 1 : 0,
        hostViewId: localViewID.value);

    // Create LivestreamUser model
    AppUser livestreamUser = user.appUser;

    // Create LivestreamUser model
    LivestreamUserState livestreamUserState =
        user.streamState(time: time, stateType: LivestreamUserType.host);

    Loggers.info('Starting live stream...');
    Loggers.info('Livestream Model: ${livestream.toJson()}');
    Loggers.info('Livestream User Model: ${livestreamUser.toJson()}');

    // Show loader before Firestore operations
    showLoader();

    try {
      DocumentReference livestreamRef =
          db.collection(FirebaseConst.liveStreams).doc('$userId');
      DocumentReference usersRef =
          db.collection(FirebaseConst.appUsers).doc('$userId');
      DocumentReference userStateRef =
          livestreamRef.collection(FirebaseConst.userState).doc('$userId');

      WriteBatch batch = db.batch();

      batch.set(livestreamRef, livestream.toJson());
      batch.set(usersRef, livestreamUser.toJson());
      batch.set(userStateRef, livestreamUserState.toJson());

      // Commit batch operation
      await batch.commit();

      Loggers.success('Livestream started successfully!');

      // Navigate to live stream host screen
      Widget? hostPreview = localView.value;
      // print(livestream.toJson());
      Get.off(() => LivestreamHostScreen(
          hostPreview: hostPreview, livestream: livestream, isHost: true));
    } catch (e, stackTrace) {
      Loggers.error('Failed to start live stream: $e');
      Loggers.error('StackTrace: $stackTrace');
    } finally {
      stopLoader(); // Ensure loader stops in all cases
    }
  }
}
