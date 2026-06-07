class Message {
  final String id;
  final String conversationId;
  final String? senderId;
  final String senderType; // CUSTOMER or STAFF
  final String content;
  final String type; // TEXT, IMAGE, GAME_CARD, SYSTEM
  final bool isRead;
  final DateTime? createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    this.senderId,
    required this.senderType,
    required this.content,
    this.type = 'TEXT',
    this.isRead = false,
    this.createdAt,
  });

  bool get isFromCustomer => senderType == 'CUSTOMER';

  /// Copy of this message with a fallback [createdAt] (used to keep the
  /// optimistic sent-time when the server response omits it).
  Message withCreatedAt(DateTime? value) => Message(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        senderType: senderType,
        content: content,
        type: type,
        isRead: isRead,
        createdAt: value,
      );

  /// Copy of this message flagged as read (for live read receipts).
  Message asRead() => Message(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        senderType: senderType,
        content: content,
        type: type,
        isRead: true,
        createdAt: createdAt,
      );

  /// Short clock label like "2:14 PM".
  String get timeLabel {
    final dt = createdAt;
    if (dt == null) return '';
    final local = dt.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '$hour12:${local.minute.toString().padLeft(2, '0')} $ampm';
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String?,
      senderType: json['senderType'] as String? ?? 'STAFF',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'TEXT',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Message && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
