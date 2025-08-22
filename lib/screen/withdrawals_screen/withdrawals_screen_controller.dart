import 'package:get/get.dart';
import 'package:vybzzz/common/controller/base_controller.dart';
import 'package:vybzzz/common/service/api/gift_wallet_service.dart';
import 'package:vybzzz/model/gift_wallet/withdraw_model.dart';

class WithdrawalsScreenController extends BaseController {
  RxList<Withdraw> withdraws = <Withdraw>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchWithdrawals();
  }

  Future<void> _fetchWithdrawals() async {
    if (isLoading.value) return;
    isLoading.value = true;

    List<Withdraw> items =
        await GiftWalletService.instance.fetchMyWithdrawalRequest(
      lastItemId: withdraws.isEmpty ? null : withdraws.last.id?.toInt(),
    );

    if (items.isNotEmpty) {
      withdraws.addAll(items);
    }
    isLoading.value = false;
  }
}
