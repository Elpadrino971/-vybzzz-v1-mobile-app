import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle d'événement VyBzzZ
///
/// Représente un concert/événement live avec :
/// - 3 types de billets (Virtual, Physical, Fanbase)
/// - Replay 7 jours après le live
/// - Streaming 100MS
/// - Paiements Stripe

enum EventType {
  live('live', 'Concert Live'),
  physical('physical', 'Concert Physique'),
  hybrid('hybrid', 'Concert Hybride');

  final String value;
  final String displayName;

  const EventType(this.value, this.displayName);

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => EventType.live,
    );
  }
}

enum EventStatus {
  draft('draft', 'Brouillon'),
  scheduled('scheduled', 'Programmé'),
  live('live', 'En Direct'),
  ended('ended', 'Terminé'),
  cancelled('cancelled', 'Annulé');

  final String value;
  final String displayName;

  const EventStatus(this.value, this.displayName);

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => EventStatus.draft,
    );
  }

  bool get isActive => this == EventStatus.scheduled || this == EventStatus.live;
  bool get canPurchaseTickets => this == EventStatus.scheduled;
  bool get isLive => this == EventStatus.live;
}

enum TicketType {
  virtual('virtual', 'Billet Virtuel'),
  physical('physical', 'Billet Physique'),
  fanbase('fanbase', 'Fanbase (Visionnage Collectif)');

  final String value;
  final String displayName;

  const TicketType(this.value, this.displayName);

  static TicketType fromString(String value) {
    return TicketType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TicketType.virtual,
    );
  }

  String get description {
    switch (this) {
      case TicketType.virtual:
        return 'Regardez le concert depuis chez vous';
      case TicketType.physical:
        return 'Assistez au concert sur place';
      case TicketType.fanbase:
        return 'Organisez un visionnage collectif dans votre salle';
    }
  }
}

class VyBzzZEvent {
  String? id;
  int? artistId;
  String? artistName;
  String? artistPhoto;
  String? title;
  String? description;
  String? coverImageUrl;
  EventType? eventType;
  EventStatus? status;
  DateTime? startTime;
  DateTime? endTime;

  // Localisation (pour concerts physiques/hybrides)
  String? venueName;
  String? venueAddress;
  double? venueLat;
  double? venueLon;

  // Streaming
  String? streamUrl;
  String? hmsRoomId;
  String? hmsRecordingUrl;

  // Replay (disponible 7 jours après le concert)
  String? replayUrl;
  DateTime? replayExpiresAt;
  bool? replayAvailable;

  // Prix des billets (3 types)
  double? ticketPriceVirtual;    // Ex: 10€
  double? ticketPricePhysical;   // Ex: 30€ (plus cher)
  double? ticketPriceFanbase;    // Ex: 5€ par personne

  // Billets
  int? ticketQuantity;           // Nombre total de billets
  int? ticketsSold;              // Nombre de billets vendus
  int? ticketsVirtualSold;
  int? ticketsPhysicalSold;
  int? ticketsFanbaseSold;

  // Happy Hour
  bool? isHappyHour;
  double? happyHourPriceVirtual;
  double? happyHourPricePhysical;
  double? happyHourPriceFanbase;
  DateTime? happyHourStartTime;
  DateTime? happyHourEndTime;

  // Stats
  int? viewerCount;
  int? peakViewerCount;
  double? totalRevenue;
  double? totalTips;

  // Metadata
  DateTime? createdAt;
  DateTime? updatedAt;

  VyBzzZEvent({
    this.id,
    this.artistId,
    this.artistName,
    this.artistPhoto,
    this.title,
    this.description,
    this.coverImageUrl,
    this.eventType,
    this.status,
    this.startTime,
    this.endTime,
    this.venueName,
    this.venueAddress,
    this.venueLat,
    this.venueLon,
    this.streamUrl,
    this.hmsRoomId,
    this.hmsRecordingUrl,
    this.replayUrl,
    this.replayExpiresAt,
    this.replayAvailable,
    this.ticketPriceVirtual,
    this.ticketPricePhysical,
    this.ticketPriceFanbase,
    this.ticketQuantity,
    this.ticketsSold,
    this.ticketsVirtualSold,
    this.ticketsPhysicalSold,
    this.ticketsFanbaseSold,
    this.isHappyHour,
    this.happyHourPriceVirtual,
    this.happyHourPricePhysical,
    this.happyHourPriceFanbase,
    this.happyHourStartTime,
    this.happyHourEndTime,
    this.viewerCount,
    this.peakViewerCount,
    this.totalRevenue,
    this.totalTips,
    this.createdAt,
    this.updatedAt,
  });

  factory VyBzzZEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VyBzzZEvent.fromJson(data)..id = doc.id;
  }

  factory VyBzzZEvent.fromJson(Map<String, dynamic> json) {
    return VyBzzZEvent(
      id: json['id'],
      artistId: json['artist_id'],
      artistName: json['artist_name'],
      artistPhoto: json['artist_photo'],
      title: json['title'],
      description: json['description'],
      coverImageUrl: json['cover_image_url'],
      eventType: json['event_type'] != null
          ? EventType.fromString(json['event_type'])
          : null,
      status: json['status'] != null
          ? EventStatus.fromString(json['status'])
          : null,
      startTime: json['start_time'] != null
          ? (json['start_time'] as Timestamp).toDate()
          : null,
      endTime: json['end_time'] != null
          ? (json['end_time'] as Timestamp).toDate()
          : null,
      venueName: json['venue_name'],
      venueAddress: json['venue_address'],
      venueLat: json['venue_lat']?.toDouble(),
      venueLon: json['venue_lon']?.toDouble(),
      streamUrl: json['stream_url'],
      hmsRoomId: json['hms_room_id'],
      hmsRecordingUrl: json['hms_recording_url'],
      replayUrl: json['replay_url'],
      replayExpiresAt: json['replay_expires_at'] != null
          ? (json['replay_expires_at'] as Timestamp).toDate()
          : null,
      replayAvailable: json['replay_available'],
      ticketPriceVirtual: json['ticket_price_virtual']?.toDouble(),
      ticketPricePhysical: json['ticket_price_physical']?.toDouble(),
      ticketPriceFanbase: json['ticket_price_fanbase']?.toDouble(),
      ticketQuantity: json['ticket_quantity'],
      ticketsSold: json['tickets_sold'],
      ticketsVirtualSold: json['tickets_virtual_sold'],
      ticketsPhysicalSold: json['tickets_physical_sold'],
      ticketsFanbaseSold: json['tickets_fanbase_sold'],
      isHappyHour: json['is_happy_hour'],
      happyHourPriceVirtual: json['happy_hour_price_virtual']?.toDouble(),
      happyHourPricePhysical: json['happy_hour_price_physical']?.toDouble(),
      happyHourPriceFanbase: json['happy_hour_price_fanbase']?.toDouble(),
      happyHourStartTime: json['happy_hour_start_time'] != null
          ? (json['happy_hour_start_time'] as Timestamp).toDate()
          : null,
      happyHourEndTime: json['happy_hour_end_time'] != null
          ? (json['happy_hour_end_time'] as Timestamp).toDate()
          : null,
      viewerCount: json['viewer_count'],
      peakViewerCount: json['peak_viewer_count'],
      totalRevenue: json['total_revenue']?.toDouble(),
      totalTips: json['total_tips']?.toDouble(),
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : null,
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artist_id': artistId,
      'artist_name': artistName,
      'artist_photo': artistPhoto,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'event_type': eventType?.value,
      'status': status?.value,
      'start_time': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'end_time': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'venue_name': venueName,
      'venue_address': venueAddress,
      'venue_lat': venueLat,
      'venue_lon': venueLon,
      'stream_url': streamUrl,
      'hms_room_id': hmsRoomId,
      'hms_recording_url': hmsRecordingUrl,
      'replay_url': replayUrl,
      'replay_expires_at':
          replayExpiresAt != null ? Timestamp.fromDate(replayExpiresAt!) : null,
      'replay_available': replayAvailable,
      'ticket_price_virtual': ticketPriceVirtual,
      'ticket_price_physical': ticketPricePhysical,
      'ticket_price_fanbase': ticketPriceFanbase,
      'ticket_quantity': ticketQuantity,
      'tickets_sold': ticketsSold,
      'tickets_virtual_sold': ticketsVirtualSold,
      'tickets_physical_sold': ticketsPhysicalSold,
      'tickets_fanbase_sold': ticketsFanbaseSold,
      'is_happy_hour': isHappyHour,
      'happy_hour_price_virtual': happyHourPriceVirtual,
      'happy_hour_price_physical': happyHourPricePhysical,
      'happy_hour_price_fanbase': happyHourPriceFanbase,
      'happy_hour_start_time': happyHourStartTime != null
          ? Timestamp.fromDate(happyHourStartTime!)
          : null,
      'happy_hour_end_time': happyHourEndTime != null
          ? Timestamp.fromDate(happyHourEndTime!)
          : null,
      'viewer_count': viewerCount,
      'peak_viewer_count': peakViewerCount,
      'total_revenue': totalRevenue,
      'total_tips': totalTips,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Obtient le prix actuel pour un type de billet donné
  double? getCurrentPrice(TicketType type) {
    final now = DateTime.now();
    final isCurrentlyHappyHour = isHappyHour == true &&
        happyHourStartTime != null &&
        happyHourEndTime != null &&
        now.isAfter(happyHourStartTime!) &&
        now.isBefore(happyHourEndTime!);

    if (isCurrentlyHappyHour) {
      switch (type) {
        case TicketType.virtual:
          return happyHourPriceVirtual ?? ticketPriceVirtual;
        case TicketType.physical:
          return happyHourPricePhysical ?? ticketPricePhysical;
        case TicketType.fanbase:
          return happyHourPriceFanbase ?? ticketPriceFanbase;
      }
    }

    switch (type) {
      case TicketType.virtual:
        return ticketPriceVirtual;
      case TicketType.physical:
        return ticketPricePhysical;
      case TicketType.fanbase:
        return ticketPriceFanbase;
    }
  }

  /// Vérifie si le replay est disponible
  bool get isReplayAvailable {
    if (replayUrl == null || replayExpiresAt == null) return false;
    return DateTime.now().isBefore(replayExpiresAt!) && replayAvailable == true;
  }

  /// Vérifie s'il reste des billets
  bool get hasTicketsAvailable {
    if (ticketQuantity == null) return true;
    return (ticketsSold ?? 0) < ticketQuantity!;
  }

  /// Active le replay après la fin du concert
  void activateReplay(String recordingUrl) {
    replayUrl = recordingUrl;
    replayAvailable = true;
    replayExpiresAt = DateTime.now().add(const Duration(days: 7));
  }

  /// Met à jour les statistiques de visionnage
  void updateViewerStats(int currentViewers) {
    viewerCount = currentViewers;
    if (peakViewerCount == null || currentViewers > peakViewerCount!) {
      peakViewerCount = currentViewers;
    }
  }

  /// Incrémente le nombre de billets vendus
  void incrementTicketSold(TicketType type, double amount) {
    ticketsSold = (ticketsSold ?? 0) + 1;
    totalRevenue = (totalRevenue ?? 0) + amount;

    switch (type) {
      case TicketType.virtual:
        ticketsVirtualSold = (ticketsVirtualSold ?? 0) + 1;
        break;
      case TicketType.physical:
        ticketsPhysicalSold = (ticketsPhysicalSold ?? 0) + 1;
        break;
      case TicketType.fanbase:
        ticketsFanbaseSold = (ticketsFanbaseSold ?? 0) + 1;
        break;
    }
  }

  /// Ajoute un pourboire
  void addTip(double amount) {
    totalTips = (totalTips ?? 0) + amount;
  }

  /// Obtient le temps restant avant le début
  Duration? get timeUntilStart {
    if (startTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(startTime!)) return null;
    return startTime!.difference(now);
  }

  /// Obtient le temps restant pour le replay
  Duration? get replayTimeRemaining {
    if (replayExpiresAt == null || !isReplayAvailable) return null;
    return replayExpiresAt!.difference(DateTime.now());
  }
}
