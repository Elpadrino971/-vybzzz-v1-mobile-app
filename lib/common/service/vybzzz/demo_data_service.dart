import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybzzz/model/event_model/vybzzz_event_model.dart';
import 'package:vybzzz/model/ticket_model/ticket_model.dart';
import 'package:vybzzz/model/user_model/user_model.dart';
import 'package:vybzzz/common/manager/logger.dart';

/// Service pour créer des données de démo pour VyBzzZ
/// Génère des événements, utilisateurs et billets fictifs pour tester l'app
class DemoDataService {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crée toutes les données de démo
  Future<void> createAllDemoData() async {
    try {
      Loggers.info('🎯 Création des données de démo VyBzzZ...');

      // Crée des utilisateurs de démo
      await _createDemoUsers();

      // Crée des événements de démo
      await _createDemoEvents();

      // Crée des billets de démo
      await _createDemoTickets();

      Loggers.success('✅ Données de démo créées avec succès!');
    } catch (e) {
      Loggers.error('❌ Erreur création données de démo: $e');
    }
  }

  /// Crée des utilisateurs de démo
  Future<void> _createDemoUsers() async {
    final demoUsers = [
      {
        'id': 1,
        'email': 'fan@vybzzz.com',
        'fullname': 'Alexandre Martin',
        'username': 'alex_fan',
        'user_type': 'fan',
        'profile_photo': 'https://i.pravatar.cc/150?img=1',
        'created_at': Timestamp.now(),
      },
      {
        'id': 2,
        'email': 'artist@vybzzz.com',
        'fullname': 'DJ Phoenix',
        'username': 'dj_phoenix',
        'user_type': 'artist',
        'profile_photo': 'https://i.pravatar.cc/150?img=2',
        'verified': true,
        'subscription_tier': 'pro',
        'created_at': Timestamp.now(),
      },
      {
        'id': 3,
        'email': 'manager@vybzzz.com',
        'fullname': 'Sophie Dubois',
        'username': 'sophie_manager',
        'user_type': 'regional_manager',
        'profile_photo': 'https://i.pravatar.cc/150?img=3',
        'created_at': Timestamp.now(),
      },
    ];

    for (final user in demoUsers) {
      try {
        await _firestore.collection('users').doc(user['id'].toString()).set(user);
        Loggers.info('✅ Utilisateur créé: ${user['fullname']}');
      } catch (e) {
        Loggers.error('❌ Erreur création user: $e');
      }
    }
  }

  /// Crée des événements de démo
  Future<void> _createDemoEvents() async {
    final now = DateTime.now();

    final demoEvents = [
      {
        'id': 'event_001',
        'title': 'David Guetta - New Year Eve 2025',
        'description': 'Célébrez le Nouvel An avec David Guetta!\n\nLe plus grand DJ du monde pour une nuit exceptionnelle à Paris.',
        'artist_name': 'David Guetta',
        'artist_id': 2,
        'artist_photo': 'https://i.pravatar.cc/150?img=2',
        'venue_name': 'Paris La Défense Arena',
        'venue_address': '1 Bd de l\'Arche, 92000 Nanterre',
        'latitude': 48.8964,
        'longitude': 2.2270,
        'start_time': Timestamp.fromDate(DateTime(2025, 12, 31, 22, 0)),
        'end_time': Timestamp.fromDate(DateTime(2026, 1, 1, 4, 0)),
        'category': 'Électro',
        'genres': ['House', 'EDM', 'Dance'],
        'ticket_price': 150.0,
        'total_capacity': 20000,
        'tickets_sold': 15432,
        'tickets_available': 4568,
        'status': 'upcoming',
        'is_featured': true,
        'cover_image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
        'banner_image': 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae',
        'created_at': Timestamp.now(),
      },
      {
        'id': 'event_002',
        'title': 'DJ Phoenix Live @ Warehouse',
        'description': 'Soirée Techno underground avec DJ Phoenix!\n\nAmbiance électrique garantie.',
        'artist_name': 'DJ Phoenix',
        'artist_id': 2,
        'artist_photo': 'https://i.pravatar.cc/150?img=2',
        'venue_name': 'Warehouse Paris',
        'venue_address': '18 Rue du Faubourg du Temple, 75011 Paris',
        'latitude': 48.8696,
        'longitude': 2.3706,
        'start_time': Timestamp.fromDate(now.add(Duration(days: 7, hours: 22))),
        'end_time': Timestamp.fromDate(now.add(Duration(days: 8, hours: 4))),
        'category': 'Techno',
        'genres': ['Techno', 'House', 'Electro'],
        'ticket_price': 35.0,
        'total_capacity': 500,
        'tickets_sold': 234,
        'tickets_available': 266,
        'status': 'upcoming',
        'is_featured': false,
        'cover_image': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
        'created_at': Timestamp.now(),
      },
      {
        'id': 'event_003',
        'title': 'Hip-Hop Festival Paris',
        'description': 'Le plus grand festival hip-hop de France!\n\n3 jours de concerts non-stop.',
        'artist_name': 'Multiple Artists',
        'artist_id': 2,
        'artist_photo': 'https://i.pravatar.cc/150?img=4',
        'venue_name': 'Parc des Expositions',
        'venue_address': 'Place de la Porte de Versailles, 75015 Paris',
        'latitude': 48.8330,
        'longitude': 2.2866,
        'start_time': Timestamp.fromDate(now.add(Duration(days: 30))),
        'end_time': Timestamp.fromDate(now.add(Duration(days: 33))),
        'category': 'Hip-Hop',
        'genres': ['Hip-Hop', 'Rap', 'R&B'],
        'ticket_price': 85.0,
        'total_capacity': 10000,
        'tickets_sold': 4521,
        'tickets_available': 5479,
        'status': 'upcoming',
        'is_featured': true,
        'cover_image': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f',
        'created_at': Timestamp.now(),
      },
      {
        'id': 'event_004',
        'title': 'Jazz Night @ Le Duc',
        'description': 'Soirée jazz intimiste avec les meilleurs musiciens de Paris.',
        'artist_name': 'Paris Jazz Quartet',
        'artist_id': 2,
        'artist_photo': 'https://i.pravatar.cc/150?img=5',
        'venue_name': 'Le Duc des Lombards',
        'venue_address': '42 Rue des Lombards, 75001 Paris',
        'latitude': 48.8609,
        'longitude': 2.3469,
        'start_time': Timestamp.fromDate(now.add(Duration(days: 3, hours: 20))),
        'end_time': Timestamp.fromDate(now.add(Duration(days: 4))),
        'category': 'Jazz',
        'genres': ['Jazz', 'Blues', 'Soul'],
        'ticket_price': 45.0,
        'total_capacity': 150,
        'tickets_sold': 98,
        'tickets_available': 52,
        'status': 'upcoming',
        'is_featured': false,
        'cover_image': 'https://images.unsplash.com/photo-1511192336575-5a79af67a629',
        'created_at': Timestamp.now(),
      },
      {
        'id': 'event_005',
        'title': 'Rock Legends Live',
        'description': 'Les plus grands hits du rock dans une soirée mémorable!',
        'artist_name': 'The Rockstars',
        'artist_id': 2,
        'artist_photo': 'https://i.pravatar.cc/150?img=6',
        'venue_name': 'Olympia',
        'venue_address': '28 Boulevard des Capucines, 75009 Paris',
        'latitude': 48.8702,
        'longitude': 2.3279,
        'start_time': Timestamp.fromDate(now.add(Duration(days: 14, hours: 21))),
        'end_time': Timestamp.fromDate(now.add(Duration(days: 15, hours: 1))),
        'category': 'Rock',
        'genres': ['Rock', 'Alternative', 'Indie'],
        'ticket_price': 65.0,
        'total_capacity': 2000,
        'tickets_sold': 1234,
        'tickets_available': 766,
        'status': 'upcoming',
        'is_featured': true,
        'cover_image': 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee',
        'created_at': Timestamp.now(),
      },
    ];

    for (final event in demoEvents) {
      try {
        await _firestore.collection('events').doc(event['id'] as String).set(event);
        Loggers.info('✅ Événement créé: ${event['title']}');
      } catch (e) {
        Loggers.error('❌ Erreur création event: $e');
      }
    }
  }

  /// Crée des billets de démo
  Future<void> _createDemoTickets() async {
    final now = DateTime.now();

    final demoTickets = [
      {
        'id': 'ticket_001',
        'event_id': 'event_001',
        'event_title': 'David Guetta - New Year Eve 2025',
        'user_id': 1,
        'user_name': 'Alexandre Martin',
        'user_email': 'fan@vybzzz.com',
        'ticket_type': 'physical',
        'price': 150.0,
        'quantity': 2,
        'total_amount': 300.0,
        'status': 'active',
        'qr_code': 'VYBZZZ_NYE2025_001_${DateTime.now().millisecondsSinceEpoch}',
        'purchase_date': Timestamp.now(),
        'event_date': Timestamp.fromDate(DateTime(2025, 12, 31, 22, 0)),
      },
      {
        'id': 'ticket_002',
        'event_id': 'event_002',
        'event_title': 'DJ Phoenix Live @ Warehouse',
        'user_id': 1,
        'user_name': 'Alexandre Martin',
        'user_email': 'fan@vybzzz.com',
        'ticket_type': 'virtual',
        'price': 35.0,
        'quantity': 1,
        'total_amount': 35.0,
        'status': 'active',
        'qr_code': 'VYBZZZ_WAREHOUSE_002_${DateTime.now().millisecondsSinceEpoch}',
        'purchase_date': Timestamp.now(),
        'event_date': Timestamp.fromDate(now.add(Duration(days: 7, hours: 22))),
      },
      {
        'id': 'ticket_003',
        'event_id': 'event_004',
        'event_title': 'Jazz Night @ Le Duc',
        'user_id': 1,
        'user_name': 'Alexandre Martin',
        'user_email': 'fan@vybzzz.com',
        'ticket_type': 'physical',
        'price': 45.0,
        'quantity': 1,
        'total_amount': 45.0,
        'status': 'active',
        'qr_code': 'VYBZZZ_JAZZ_003_${DateTime.now().millisecondsSinceEpoch}',
        'purchase_date': Timestamp.now(),
        'event_date': Timestamp.fromDate(now.add(Duration(days: 3, hours: 20))),
      },
    ];

    for (final ticket in demoTickets) {
      try {
        await _firestore.collection('tickets').doc(ticket['id'] as String).set(ticket);
        Loggers.info('✅ Billet créé: ${ticket['event_title']}');
      } catch (e) {
        Loggers.error('❌ Erreur création ticket: $e');
      }
    }
  }

  /// Vérifie si des données de démo existent déjà
  Future<bool> demoDataExists() async {
    try {
      final eventsSnapshot = await _firestore
          .collection('events')
          .where('id', isEqualTo: 'event_001')
          .limit(1)
          .get();

      return eventsSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Supprime toutes les données de démo
  Future<void> clearDemoData() async {
    try {
      Loggers.info('🗑️ Suppression des données de démo...');

      // Supprime les événements de démo
      final eventsQuery = await _firestore
          .collection('events')
          .where('id', whereIn: ['event_001', 'event_002', 'event_003', 'event_004', 'event_005'])
          .get();

      for (final doc in eventsQuery.docs) {
        await doc.reference.delete();
      }

      // Supprime les billets de démo
      final ticketsQuery = await _firestore
          .collection('tickets')
          .where('id', whereIn: ['ticket_001', 'ticket_002', 'ticket_003'])
          .get();

      for (final doc in ticketsQuery.docs) {
        await doc.reference.delete();
      }

      Loggers.success('✅ Données de démo supprimées!');
    } catch (e) {
      Loggers.error('❌ Erreur suppression données de démo: $e');
    }
  }
}
