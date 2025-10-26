import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour les messages du chat live
class LiveChatMessage {
  String? id;
  String? eventId;
  int? userId;
  String? userName;
  String? userPhoto;
  String? message;
  MessageType? type;
  DateTime? sentAt;

  // Pour les tips
  double? tipAmount;

  // Pour les messages système
  bool isSystemMessage;

  LiveChatMessage({
    this.id,
    this.eventId,
    this.userId,
    this.userName,
    this.userPhoto,
    this.message,
    this.type,
    this.sentAt,
    this.tipAmount,
    this.isSystemMessage = false,
  });

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  factory LiveChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LiveChatMessage(
      id: doc.id,
      eventId: data['event_id'] as String?,
      userId: data['user_id'] as int?,
      userName: data['user_name'] as String?,
      userPhoto: data['user_photo'] as String?,
      message: data['message'] as String?,
      type: data['type'] != null
          ? MessageType.fromString(data['type'] as String)
          : null,
      sentAt: (data['sent_at'] as Timestamp?)?.toDate(),
      tipAmount: (data['tip_amount'] as num?)?.toDouble(),
      isSystemMessage: data['is_system_message'] as bool? ?? false,
    );
  }

  /// Message de chat normal
  factory LiveChatMessage.chat({
    required String eventId,
    required int userId,
    required String userName,
    String? userPhoto,
    required String message,
  }) {
    return LiveChatMessage(
      eventId: eventId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      message: message,
      type: MessageType.chat,
      sentAt: DateTime.now(),
      isSystemMessage: false,
    );
  }

  /// Message de tip
  factory LiveChatMessage.tip({
    required String eventId,
    required int userId,
    required String userName,
    String? userPhoto,
    required double tipAmount,
  }) {
    return LiveChatMessage(
      eventId: eventId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      message: 'a envoyé ${tipAmount.toStringAsFixed(2)}€',
      type: MessageType.tip,
      sentAt: DateTime.now(),
      tipAmount: tipAmount,
      isSystemMessage: false,
    );
  }

  /// Message système (ex: "X a rejoint le live")
  factory LiveChatMessage.system({
    required String eventId,
    required String message,
  }) {
    return LiveChatMessage(
      eventId: eventId,
      message: message,
      type: MessageType.system,
      sentAt: DateTime.now(),
      isSystemMessage: true,
    );
  }

  // ============================================
  // TO JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'message': message,
      'type': type?.value,
      'sent_at': sentAt != null ? Timestamp.fromDate(sentAt!) : FieldValue.serverTimestamp(),
      'tip_amount': tipAmount,
      'is_system_message': isSystemMessage,
    };
  }
}

/// Types de messages
enum MessageType {
  chat('chat'),
  tip('tip'),
  system('system');

  final String value;
  const MessageType(this.value);

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.chat,
    );
  }
}
