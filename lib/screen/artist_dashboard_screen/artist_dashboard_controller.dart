import 'package:get/get.dart';
import 'package:vybzzz/common/service/vybzzz/event_service.dart';
import 'package:vybzzz/common/service/vybzzz/payout_service.dart';
import 'package:vybzzz/common/service/vybzzz/tip_service.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/model/payout_model/payout_model.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';

/// Controller pour le Dashboard Artiste
class ArtistDashboardController extends GetxController {
  final EventService _eventService = EventService();
  final PayoutService _payoutService = PayoutService();
  final TipService _tipService = TipService();
  final AuthController _authController = Get.find<AuthController>();

  // États
  final RxList<VyBzzZEvent> myEvents = <VyBzzZEvent>[].obs;
  final RxList<PayoutModel> myPayouts = <PayoutModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Stats
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble monthEarnings = 0.0.obs;
  final RxDouble totalTips = 0.0.obs;
  final RxInt totalTicketsSold = 0.obs;
  final RxInt upcomingEvents = 0.obs;

  // Next payout
  final Rx<PayoutModel?> nextPayout = Rx<PayoutModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // ============================================
  // LOAD DASHBOARD
  // ============================================

  Future<void> loadDashboard() async {
    final currentUser = _authController.currentUser.value;
    if (currentUser?.id == null) {
      Get.snackbar('Erreur', 'Vous devez être connecté');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Future.wait([
        _loadEvents(currentUser.id!),
        _loadPayouts(currentUser.id!),
        _loadStats(currentUser.id!),
      ]);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar('Erreur', 'Impossible de charger le dashboard');
    }
  }

  Future<void> _loadEvents(int artistId) async {
    try {
      final events = await _eventService.getEventsByArtist(artistId);
      myEvents.value = events;

      // Calculer les stats d'événements
      upcomingEvents.value = events
          .where((e) => e.status == EventStatus.scheduled)
          .length;

      totalTicketsSold.value = events.fold(
        0,
        (sum, event) => sum + (event.ticketsSold ?? 0),
      );
    } catch (e) {
      print('Erreur chargement événements: $e');
    }
  }

  Future<void> _loadPayouts(int artistId) async {
    try {
      final payouts = await _payoutService.getPayoutsByArtist(artistId);
      myPayouts.value = payouts;

      // Récupérer le prochain payout
      final next = await _payoutService.getNextScheduledPayout(artistId);
      nextPayout.value = next;
    } catch (e) {
      print('Erreur chargement payouts: $e');
    }
  }

  Future<void> _loadStats(int artistId) async {
    try {
      // Total des gains
      final total = await _payoutService.getTotalEarnings(artistId);
      totalEarnings.value = total;

      // Gains du mois
      final month = await _payoutService.getCurrentMonthEarnings(artistId);
      monthEarnings.value = month;

      // Total des pourboires
      final tips = await _tipService.getTotalTipsReceived(artistId);
      totalTips.value = tips;
    } catch (e) {
      print('Erreur chargement stats: $e');
    }
  }

  // ============================================
  // REFRESH
  // ============================================

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  // ============================================
  // GETTERS
  // ============================================

  List<VyBzzZEvent> get liveEvents {
    return myEvents.where((e) => e.status == EventStatus.live).toList();
  }

  List<VyBzzZEvent> get scheduledEvents {
    return myEvents
        .where((e) => e.status == EventStatus.scheduled)
        .toList()
      ..sort((a, b) =>
          (a.startTime ?? DateTime.now())
              .compareTo(b.startTime ?? DateTime.now()));
  }

  List<VyBzzZEvent> get pastEvents {
    return myEvents
        .where((e) => e.status == EventStatus.ended)
        .toList()
      ..sort((a, b) =>
          (b.startTime ?? DateTime.now())
              .compareTo(a.startTime ?? DateTime.now()));
  }

  double get totalRevenue {
    return myEvents.fold(
      0.0,
      (sum, event) => sum + (event.totalRevenue ?? 0),
    );
  }

  int get totalEvents => myEvents.length;

  bool get hasNextPayout => nextPayout.value != null;

  String? get nextPayoutDate {
    if (nextPayout.value?.paymentDate == null) return null;
    final date = nextPayout.value!.paymentDate!;
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Demain';
    return 'Dans ${diff.inDays} jours';
  }

  double? get nextPayoutAmount => nextPayout.value?.finalAmount;

  // ============================================
  // NAVIGATION
  // ============================================

  void goToCreateEvent() {
    Get.toNamed('/create-event')?.then((_) => loadDashboard());
  }

  void goToEventDetails(VyBzzZEvent event) {
    Get.toNamed('/event-details', arguments: {'event': event});
  }

  void goToPayoutHistory() {
    Get.toNamed('/payout-history', arguments: {'payouts': myPayouts});
  }
}
