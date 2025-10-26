import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/ticket_model/ticket_model.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';

/// Service pour gérer les billets VyBzzZ
///
/// Fournit des méthodes pour :
/// - Créer des billets après achat
/// - Récupérer les billets d'un utilisateur
/// - Scanner et valider les QR codes
/// - Gérer les remboursements

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tickets';

  // ============================================
  // CREATE
  // ============================================

  /// Crée un nouveau billet après achat
  Future<TicketModel> createTicket({
    required String eventId,
    required int userId,
    required TicketType ticketType,
    required double pricePaid,
    required String stripePaymentIntentId,
    String? userName,
    String? userEmail,
    String? eventTitle,
    DateTime? eventStartTime,
  }) async {
    try {
      final ticket = TicketModel(
        eventId: eventId,
        userId: userId,
        ticketType: ticketType,
        status: TicketStatus.valid,
        qrCode: '', // Sera généré après l'insertion
        pricePaid: pricePaid,
        stripePaymentIntentId: stripePaymentIntentId,
        userName: userName,
        userEmail: userEmail,
        eventTitle: eventTitle,
        eventStartTime: eventStartTime,
        purchasedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection(_collectionName).add(ticket.toJson());
      ticket.id = docRef.id;

      // Générer le QR code avec l'ID du document
      final qrCode = TicketModel.generateQRCode(docRef.id, eventId, userId);
      ticket.qrCode = qrCode;

      // Mettre à jour le QR code dans Firestore
      await _firestore.collection(_collectionName).doc(docRef.id).update({
        'qr_code': qrCode,
      });

      return ticket;
    } catch (e) {
      throw Exception('Erreur lors de la création du billet: $e');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Récupère un billet par ID
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(ticketId).get();
      if (!doc.exists) return null;
      return TicketModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du billet: $e');
    }
  }

  /// Récupère tous les billets d'un utilisateur
  Future<List<TicketModel>> getTicketsByUser(int userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('user_id', isEqualTo: userId)
          .orderBy('purchased_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => TicketModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des billets: $e');
    }
  }

  /// Récupère les billets d'un utilisateur pour un événement spécifique
  Future<List<TicketModel>> getTicketsByUserAndEvent(
    int userId,
    String eventId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('user_id', isEqualTo: userId)
          .where('event_id', isEqualTo: eventId)
          .get();

      return querySnapshot.docs.map((doc) => TicketModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des billets: $e');
    }
  }

  /// Récupère tous les billets d'un événement
  Future<List<TicketModel>> getTicketsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('event_id', isEqualTo: eventId)
          .orderBy('purchased_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => TicketModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des billets: $e');
    }
  }

  /// Récupère un billet par QR code
  Future<TicketModel?> getTicketByQRCode(String qrCode) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('qr_code', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return TicketModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du billet par QR code: $e');
    }
  }

  /// Stream des billets d'un utilisateur
  Stream<List<TicketModel>> streamUserTickets(int userId) {
    return _firestore
        .collection(_collectionName)
        .where('user_id', isEqualTo: userId)
        .orderBy('purchased_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TicketModel.fromFirestore(doc)).toList());
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Met à jour un billet
  Future<void> updateTicket(TicketModel ticket) async {
    try {
      if (ticket.id == null) {
        throw Exception('L\'ID du billet est requis pour la mise à jour');
      }

      await _firestore.collection(_collectionName).doc(ticket.id).update(ticket.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du billet: $e');
    }
  }

  /// Marque un billet comme utilisé
  Future<void> markTicketAsUsed(String ticketId) async {
    try {
      await _firestore.collection(_collectionName).doc(ticketId).update({
        'status': TicketStatus.used.value,
        'scanned_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage du billet: $e');
    }
  }

  /// Valide un billet (marque comme utilisé)
  Future<bool> validateTicket(String qrCode) async {
    try {
      final ticket = await getTicketByQRCode(qrCode);
      if (ticket == null) {
        throw Exception('Billet introuvable');
      }

      if (!ticket.canBeScanned) {
        throw Exception('Ce billet ne peut pas être scanné');
      }

      ticket.markAsUsed();
      await updateTicket(ticket);

      return true;
    } catch (e) {
      throw Exception('Erreur lors de la validation du billet: $e');
    }
  }

  /// Rembourse un billet
  Future<bool> refundTicket(String ticketId) async {
    try {
      final ticket = await getTicketById(ticketId);
      if (ticket == null) {
        throw Exception('Billet introuvable');
      }

      if (!ticket.canBeRefunded) {
        throw Exception('Ce billet ne peut plus être remboursé');
      }

      ticket.refund();
      await updateTicket(ticket);

      return true;
    } catch (e) {
      throw Exception('Erreur lors du remboursement du billet: $e');
    }
  }

  /// Annule un billet
  Future<void> cancelTicket(String ticketId) async {
    try {
      final ticket = await getTicketById(ticketId);
      if (ticket == null) {
        throw Exception('Billet introuvable');
      }

      ticket.cancel();
      await updateTicket(ticket);
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation du billet: $e');
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// Suppression permanente d'un billet (à utiliser avec précaution)
  Future<void> permanentDeleteTicket(String ticketId) async {
    try {
      await _firestore.collection(_collectionName).doc(ticketId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression permanente: $e');
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Compte le nombre de billets vendus par type pour un événement
  Future<Map<String, int>> getTicketStatsByEvent(String eventId) async {
    try {
      final tickets = await getTicketsByEvent(eventId);

      int virtualCount = 0;
      int physicalCount = 0;
      int fanbaseCount = 0;

      for (final ticket in tickets) {
        if (ticket.status == TicketStatus.valid || ticket.status == TicketStatus.used) {
          switch (ticket.ticketType) {
            case TicketType.virtual:
              virtualCount++;
              break;
            case TicketType.physical:
              physicalCount++;
              break;
            case TicketType.fanbase:
              fanbaseCount++;
              break;
            default:
              break;
          }
        }
      }

      return {
        'virtual': virtualCount,
        'physical': physicalCount,
        'fanbase': fanbaseCount,
        'total': virtualCount + physicalCount + fanbaseCount,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// Calcule le revenu total d'un événement
  Future<double> getTotalRevenueByEvent(String eventId) async {
    try {
      final tickets = await getTicketsByEvent(eventId);

      double totalRevenue = 0;

      for (final ticket in tickets) {
        if (ticket.status == TicketStatus.valid || ticket.status == TicketStatus.used) {
          totalRevenue += ticket.pricePaid ?? 0;
        }
      }

      return totalRevenue;
    } catch (e) {
      throw Exception('Erreur lors du calcul du revenu: $e');
    }
  }

  /// Vérifie si un utilisateur a déjà acheté un billet pour un événement
  Future<bool> hasUserPurchasedTicket(int userId, String eventId) async {
    try {
      final tickets = await getTicketsByUserAndEvent(userId, eventId);
      return tickets.any((ticket) =>
          ticket.status == TicketStatus.valid || ticket.status == TicketStatus.used);
    } catch (e) {
      throw Exception('Erreur lors de la vérification d\'achat: $e');
    }
  }
}
