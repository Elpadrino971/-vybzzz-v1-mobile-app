import 'package:get/get.dart';
import 'package:vybzzz/common/service/vybzzz/event_service.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';

/// Controller pour le feed de découverte d'événements
class EventFeedController extends GetxController {
  final EventService _eventService = EventService();

  // États
  final RxList<VyBzzZEvent> upcomingEvents = <VyBzzZEvent>[].obs;
  final RxList<VyBzzZEvent> liveEvents = <VyBzzZEvent>[].obs;
  final RxList<VyBzzZEvent> replayEvents = <VyBzzZEvent>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // Filtres
  final RxString selectedFilter = 'upcoming'.obs; // upcoming, live, replay
  final Rx<EventType?> filterEventType = Rx<EventType?>(null);
  final RxDouble maxPrice = 200.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  // ============================================
  // LOAD EVENTS
  // ============================================

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Charger en parallèle
      await Future.wait([
        _loadUpcomingEvents(),
        _loadLiveEvents(),
        _loadReplayEvents(),
      ]);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar('Erreur', 'Impossible de charger les événements');
    }
  }

  Future<void> _loadUpcomingEvents() async {
    try {
      final events = await _eventService.getScheduledEvents();
      upcomingEvents.value = events;
    } catch (e) {
      print('Erreur chargement événements à venir: $e');
    }
  }

  Future<void> _loadLiveEvents() async {
    try {
      final events = await _eventService.getLiveEvents();
      liveEvents.value = events;
    } catch (e) {
      print('Erreur chargement événements live: $e');
    }
  }

  Future<void> _loadReplayEvents() async {
    try {
      final events = await _eventService.getEventsWithReplay();
      replayEvents.value = events;
    } catch (e) {
      print('Erreur chargement replays: $e');
    }
  }

  // ============================================
  // REFRESH
  // ============================================

  Future<void> refreshEvents() async {
    isRefreshing.value = true;
    await loadEvents();
    isRefreshing.value = false;
  }

  // ============================================
  // FILTERS
  // ============================================

  List<VyBzzZEvent> get filteredEvents {
    List<VyBzzZEvent> events;

    // Sélectionner la liste selon le filtre
    switch (selectedFilter.value) {
      case 'live':
        events = liveEvents;
        break;
      case 'replay':
        events = replayEvents;
        break;
      case 'upcoming':
      default:
        events = upcomingEvents;
    }

    // Filtrer par type si nécessaire
    if (filterEventType.value != null) {
      events = events
          .where((event) => event.eventType == filterEventType.value)
          .toList();
    }

    // Filtrer par prix
    events = events.where((event) {
      final minPrice = _getMinTicketPrice(event);
      return minPrice <= maxPrice.value;
    }).toList();

    return events;
  }

  double _getMinTicketPrice(VyBzzZEvent event) {
    final prices = [
      event.ticketPriceVirtual ?? double.infinity,
      event.ticketPricePhysical ?? double.infinity,
      event.ticketPriceFanbase ?? double.infinity,
    ];
    return prices.reduce((a, b) => a < b ? a : b);
  }

  // ============================================
  // ACTIONS
  // ============================================

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  void toggleEventTypeFilter(EventType? type) {
    if (filterEventType.value == type) {
      filterEventType.value = null; // Désactiver le filtre
    } else {
      filterEventType.value = type;
    }
  }

  void updateMaxPrice(double price) {
    maxPrice.value = price;
  }

  // ============================================
  // STATS
  // ============================================

  int get totalUpcoming => upcomingEvents.length;
  int get totalLive => liveEvents.length;
  int get totalReplay => replayEvents.length;

  bool get hasLiveEvents => liveEvents.isNotEmpty;
  bool get hasUpcomingEvents => upcomingEvents.isNotEmpty;
  bool get hasReplayEvents => replayEvents.isNotEmpty;
}
