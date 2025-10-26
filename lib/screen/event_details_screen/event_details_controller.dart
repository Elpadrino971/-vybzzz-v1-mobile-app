import 'package:get/get.dart';
import 'package:vybzzz/common/service/vybzzz/event_service.dart';
import 'package:vybzzz/common/service/vybzzz/ticket_service.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/model/ticket_model/ticket_model.dart';
import 'package:vybzzz/common/controller/auth_controller.dart';

/// Controller pour les détails d'événement et achat de billets
class EventDetailsController extends GetxController {
  final EventService _eventService = EventService();
  final TicketService _ticketService = TicketService();
  final AuthController _authController = Get.find<AuthController>();

  // Event
  late final Rx<VyBzzZEvent?> event;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Ticket selection
  final Rx<TicketType?> selectedTicketType = Rx<TicketType?>(null);
  final RxInt ticketQuantity = 1.obs;

  // Purchase state
  final RxBool isPurchasing = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Récupérer l'événement passé en argument
    final eventArg = Get.arguments?['event'] as VyBzzZEvent?;
    event = Rx<VyBzzZEvent?>(eventArg);

    if (event.value != null) {
      _streamEvent(event.value!.id!);
    }
  }

  // ============================================
  // STREAM EVENT (Real-time updates)
  // ============================================

  void _streamEvent(String eventId) {
    _eventService.streamEvent(eventId).listen((updatedEvent) {
      if (updatedEvent != null) {
        event.value = updatedEvent;
      }
    });
  }

  // ============================================
  // TICKET SELECTION
  // ============================================

  void selectTicketType(TicketType type) {
    selectedTicketType.value = type;
  }

  void incrementQuantity() {
    if (ticketQuantity.value < 10) {
      // Max 10 billets par achat
      ticketQuantity.value++;
    }
  }

  void decrementQuantity() {
    if (ticketQuantity.value > 1) {
      ticketQuantity.value--;
    }
  }

  // ============================================
  // PRICE CALCULATION
  // ============================================

  double? get selectedTicketPrice {
    if (event.value == null || selectedTicketType.value == null) return null;
    return event.value!.getCurrentPrice(selectedTicketType.value!);
  }

  double get totalPrice {
    return (selectedTicketPrice ?? 0) * ticketQuantity.value;
  }

  bool get isHappyHourActive {
    if (event.value?.isHappyHour != true) return false;
    final now = DateTime.now();
    final start = event.value?.happyHourStartTime;
    final end = event.value?.happyHourEndTime;

    if (start == null || end == null) return false;
    return now.isAfter(start) && now.isBefore(end);
  }

  // ============================================
  // PURCHASE TICKET
  // ============================================

  Future<void> purchaseTicket() async {
    if (selectedTicketType.value == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner un type de billet');
      return;
    }

    final currentUser = _authController.currentUser.value;
    if (currentUser == null) {
      Get.snackbar('Erreur', 'Vous devez être connecté pour acheter des billets');
      Get.toNamed('/login');
      return;
    }

    if (event.value == null || event.value!.id == null) {
      Get.snackbar('Erreur', 'Événement introuvable');
      return;
    }

    try {
      isPurchasing.value = true;

      // TODO: Intégration Stripe Payment Intent
      // Pour l'instant, on simule le paiement
      await Future.delayed(const Duration(seconds: 2));

      // Créer le(s) billet(s)
      final tickets = <TicketModel>[];
      for (int i = 0; i < ticketQuantity.value; i++) {
        final ticket = await _ticketService.createTicket(
          eventId: event.value!.id!,
          userId: currentUser.id!,
          ticketType: selectedTicketType.value!,
          pricePaid: selectedTicketPrice!,
          stripePaymentIntentId: 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
          userName: currentUser.fullname,
          userEmail: currentUser.userEmail,
          eventTitle: event.value!.title,
          eventStartTime: event.value!.startTime,
        );
        tickets.add(ticket);
      }

      // Mettre à jour les stats de l'événement
      await _eventService.incrementTicketSold(
        event.value!.id!,
        selectedTicketType.value!,
        totalPrice,
      );

      isPurchasing.value = false;

      Get.snackbar(
        'Succès',
        '${ticketQuantity.value} billet(s) acheté(s) !',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Rediriger vers Mes Billets
      Get.offNamed('/my-tickets');
    } catch (e) {
      isPurchasing.value = false;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Erreur',
        'Impossible d\'acheter le billet: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ============================================
  // GETTERS
  // ============================================

  bool get canPurchase {
    if (event.value == null) return false;
    if (selectedTicketType.value == null) return false;
    if (!event.value!.hasTicketsAvailable) return false;
    if (event.value!.status != EventStatus.scheduled) return false;
    return true;
  }

  String? get ticketsRemainingText {
    if (event.value == null) return null;
    final remaining = (event.value!.ticketQuantity ?? 0) - (event.value!.ticketsSold ?? 0);

    if (remaining <= 0) return 'Complet';
    if (remaining <= 10) return 'Plus que $remaining billets !';
    return null;
  }

  Duration? get timeUntilEvent {
    return event.value?.timeUntilStart;
  }

  bool get isEventLive {
    return event.value?.status == EventStatus.live;
  }

  bool get hasReplayAvailable {
    return event.value?.isReplayAvailable ?? false;
  }
}
