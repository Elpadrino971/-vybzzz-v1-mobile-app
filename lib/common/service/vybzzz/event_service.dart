import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';

/// Service pour gérer les événements VyBzzZ
///
/// Fournit des méthodes CRUD pour :
/// - Créer des événements
/// - Lire les événements (par artiste, statut, etc.)
/// - Mettre à jour les événements
/// - Supprimer les événements
/// - Gérer le replay automatique

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'events';

  // ============================================
  // CREATE
  // ============================================

  /// Crée un nouvel événement
  Future<VyBzzZEvent> createEvent(VyBzzZEvent event) async {
    try {
      event.createdAt = DateTime.now();
      event.updatedAt = DateTime.now();
      event.status = EventStatus.draft;
      event.ticketsSold = 0;
      event.ticketsVirtualSold = 0;
      event.ticketsPhysicalSold = 0;
      event.ticketsFanbaseSold = 0;
      event.viewerCount = 0;
      event.peakViewerCount = 0;
      event.totalRevenue = 0;
      event.totalTips = 0;

      final docRef = await _firestore.collection(_collectionName).add(event.toJson());
      event.id = docRef.id;

      return event;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'événement: $e');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Récupère un événement par ID
  Future<VyBzzZEvent?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (!doc.exists) return null;
      return VyBzzZEvent.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'événement: $e');
    }
  }

  /// Récupère tous les événements d'un artiste
  Future<List<VyBzzZEvent>> getEventsByArtist(int artistId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('artist_id', isEqualTo: artistId)
          .orderBy('start_time', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => VyBzzZEvent.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  /// Récupère les événements programmés (à venir)
  Future<List<VyBzzZEvent>> getScheduledEvents() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: EventStatus.scheduled.value)
          .where('start_time', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('start_time', descending: false)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) => VyBzzZEvent.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements programmés: $e');
    }
  }

  /// Récupère les événements en cours (live)
  Future<List<VyBzzZEvent>> getLiveEvents() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: EventStatus.live.value)
          .orderBy('viewer_count', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) => VyBzzZEvent.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements live: $e');
    }
  }

  /// Récupère les événements avec replay disponible
  Future<List<VyBzzZEvent>> getEventsWithReplay() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: EventStatus.ended.value)
          .where('replay_available', isEqualTo: true)
          .where('replay_expires_at', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('replay_expires_at', descending: false)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) => VyBzzZEvent.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des replays: $e');
    }
  }

  /// Stream en temps réel d'un événement
  Stream<VyBzzZEvent?> streamEvent(String eventId) {
    return _firestore
        .collection(_collectionName)
        .doc(eventId)
        .snapshots()
        .map((doc) => doc.exists ? VyBzzZEvent.fromFirestore(doc) : null);
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Met à jour un événement
  Future<void> updateEvent(VyBzzZEvent event) async {
    try {
      if (event.id == null) {
        throw Exception('L\'ID de l\'événement est requis pour la mise à jour');
      }

      event.updatedAt = DateTime.now();
      await _firestore.collection(_collectionName).doc(event.id).update(event.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'événement: $e');
    }
  }

  /// Publie un événement (passe de draft à scheduled)
  Future<void> publishEvent(String eventId) async {
    try {
      await _firestore.collection(_collectionName).doc(eventId).update({
        'status': EventStatus.scheduled.value,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la publication de l\'événement: $e');
    }
  }

  /// Démarre un événement (passe à live)
  Future<void> startEvent(String eventId, String streamUrl, String hmsRoomId) async {
    try {
      await _firestore.collection(_collectionName).doc(eventId).update({
        'status': EventStatus.live.value,
        'stream_url': streamUrl,
        'hms_room_id': hmsRoomId,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors du démarrage de l\'événement: $e');
    }
  }

  /// Termine un événement et active le replay
  Future<void> endEventAndActivateReplay(String eventId, String recordingUrl) async {
    try {
      final replayExpiresAt = DateTime.now().add(const Duration(days: 7));

      await _firestore.collection(_collectionName).doc(eventId).update({
        'status': EventStatus.ended.value,
        'replay_url': recordingUrl,
        'replay_available': true,
        'replay_expires_at': Timestamp.fromDate(replayExpiresAt),
        'end_time': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la fin de l\'événement: $e');
    }
  }

  /// Met à jour les stats de visionnage en temps réel
  Future<void> updateViewerStats(String eventId, int currentViewers) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (!doc.exists) return;

      final event = VyBzzZEvent.fromFirestore(doc);
      final peakViewers = event.peakViewerCount ?? 0;

      await _firestore.collection(_collectionName).doc(eventId).update({
        'viewer_count': currentViewers,
        'peak_viewer_count': currentViewers > peakViewers ? currentViewers : peakViewers,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des stats: $e');
    }
  }

  /// Incrémente le nombre de billets vendus
  Future<void> incrementTicketSold(
    String eventId,
    TicketType ticketType,
    double amount,
  ) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (!doc.exists) return;

      final event = VyBzzZEvent.fromFirestore(doc);

      final updates = {
        'tickets_sold': (event.ticketsSold ?? 0) + 1,
        'total_revenue': (event.totalRevenue ?? 0) + amount,
        'updated_at': Timestamp.now(),
      };

      switch (ticketType) {
        case TicketType.virtual:
          updates['tickets_virtual_sold'] = (event.ticketsVirtualSold ?? 0) + 1;
          break;
        case TicketType.physical:
          updates['tickets_physical_sold'] = (event.ticketsPhysicalSold ?? 0) + 1;
          break;
        case TicketType.fanbase:
          updates['tickets_fanbase_sold'] = (event.ticketsFanbaseSold ?? 0) + 1;
          break;
      }

      await _firestore.collection(_collectionName).doc(eventId).update(updates);
    } catch (e) {
      throw Exception('Erreur lors de l\'incrémentation des billets vendus: $e');
    }
  }

  /// Ajoute un pourboire à l'événement
  Future<void> addTip(String eventId, double amount) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (!doc.exists) return;

      final event = VyBzzZEvent.fromFirestore(doc);

      await _firestore.collection(_collectionName).doc(eventId).update({
        'total_tips': (event.totalTips ?? 0) + amount,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du pourboire: $e');
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// Supprime un événement (soft delete - marque comme cancelled)
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collectionName).doc(eventId).update({
        'status': EventStatus.cancelled.value,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  /// Suppression permanente (à utiliser avec précaution)
  Future<void> permanentDeleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collectionName).doc(eventId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression permanente: $e');
    }
  }

  // ============================================
  // HAPPY HOUR
  // ============================================

  /// Active le Happy Hour pour un événement
  Future<void> activateHappyHour(String eventId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(eventId).get();
      if (!doc.exists) return;

      final event = VyBzzZEvent.fromFirestore(doc);
      const discount = 0.25; // 25% de réduction

      await _firestore.collection(_collectionName).doc(eventId).update({
        'is_happy_hour': true,
        'happy_hour_price_virtual':
            (event.ticketPriceVirtual ?? 0) * (1 - discount),
        'happy_hour_price_physical':
            (event.ticketPricePhysical ?? 0) * (1 - discount),
        'happy_hour_price_fanbase':
            (event.ticketPriceFanbase ?? 0) * (1 - discount),
        'happy_hour_start_time': Timestamp.now(),
        'happy_hour_end_time':
            Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 15))),
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'activation du Happy Hour: $e');
    }
  }

  /// Désactive le Happy Hour
  Future<void> deactivateHappyHour(String eventId) async {
    try {
      await _firestore.collection(_collectionName).doc(eventId).update({
        'is_happy_hour': false,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la désactivation du Happy Hour: $e');
    }
  }
}
