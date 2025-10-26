import 'package:get/get.dart';
import 'package:vybzzz/common/service/vybzzz/ticket_service.dart';
import 'package:vybzzz/model/ticket_model/ticket_model.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';

/// Controller pour l'écran Mes Billets
class MyTicketsController extends GetxController {
  final TicketService _ticketService = TicketService();
  final AuthController _authController = Get.find<AuthController>();

  // États
  final RxList<TicketModel> myTickets = <TicketModel>[].obs;
  final RxList<TicketModel> upcomingTickets = <TicketModel>[].obs;
  final RxList<TicketModel> pastTickets = <TicketModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filtres
  final RxString selectedFilter = 'upcoming'.obs; // upcoming, past, all

  @override
  void onInit() {
    super.onInit();
    loadMyTickets();
  }

  // ============================================
  // LOAD TICKETS
  // ============================================

  Future<void> loadMyTickets() async {
    final currentUser = _authController.currentUser.value;
    if (currentUser?.id == null) {
      Get.snackbar('Erreur', 'Vous devez être connecté');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final tickets = await _ticketService.getTicketsByUser(currentUser!.id!);
      myTickets.value = tickets;

      _categorizeTickets();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar('Erreur', 'Impossible de charger vos billets');
    }
  }

  void _categorizeTickets() {
    final now = DateTime.now();

    upcomingTickets.value = myTickets.where((ticket) {
      return ticket.status == TicketStatus.valid &&
          ticket.eventStartTime != null &&
          ticket.eventStartTime!.isAfter(now);
    }).toList();

    pastTickets.value = myTickets.where((ticket) {
      return ticket.status == TicketStatus.used ||
          (ticket.eventStartTime != null && ticket.eventStartTime!.isBefore(now));
    }).toList();

    // Trier par date
    upcomingTickets.sort((a, b) =>
        a.eventStartTime?.compareTo(b.eventStartTime ?? DateTime.now()) ?? 0);
    pastTickets.sort((a, b) =>
        (b.eventStartTime?.compareTo(a.eventStartTime ?? DateTime.now()) ?? 0));
  }

  // ============================================
  // REFRESH
  // ============================================

  Future<void> refreshTickets() async {
    await loadMyTickets();
  }

  // ============================================
  // FILTERS
  // ============================================

  List<TicketModel> get filteredTickets {
    switch (selectedFilter.value) {
      case 'past':
        return pastTickets;
      case 'all':
        return myTickets;
      case 'upcoming':
      default:
        return upcomingTickets;
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // ============================================
  // TICKET ACTIONS
  // ============================================

  Future<void> requestRefund(String ticketId) async {
    try {
      final success = await _ticketService.refundTicket(ticketId);
      if (success) {
        Get.snackbar(
          'Remboursement demandé',
          'Votre demande de remboursement a été prise en compte',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadMyTickets();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  Duration? getTimeUntilEvent(TicketModel ticket) {
    if (ticket.eventStartTime == null) return null;
    final now = DateTime.now();
    if (ticket.eventStartTime!.isBefore(now)) return null;
    return ticket.eventStartTime!.difference(now);
  }

  bool canRefund(TicketModel ticket) {
    return ticket.canBeRefunded;
  }

  // ============================================
  // STATS
  // ============================================

  int get totalTickets => myTickets.length;
  int get upcomingCount => upcomingTickets.length;
  int get pastCount => pastTickets.length;

  double get totalSpent {
    return myTickets.fold(0.0, (sum, ticket) => sum + (ticket.pricePaid ?? 0));
  }
}
