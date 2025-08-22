import 'package:get/get.dart';
import 'package:vybzzz/common/service/api/user_service.dart';
import 'package:vybzzz/model/user_model/block_user_model.dart';
import 'package:vybzzz/screen/blocked_user_screen/block_user_controller.dart';

class BlockedUserScreenController extends BlockUserController {
  RxList<BlockUsers> blockedUsers = RxList<BlockUsers>();

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  void fetchBlockedUsers() async {
    isLoading.value = true;
    List<BlockUsers> users = await UserService.instance.fetchMyBlockedUsers();
    blockedUsers.value = users;
    isLoading.value = false;
  }

}
