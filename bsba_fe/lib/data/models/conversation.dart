class Conversation {
  final String id;
  final String? storeId;
  final String? storeName;
  final String? storeCoverImageUrl;
  final String? customerId;
  final String? customerName;
  final String? customerAvatarUrl;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    this.storeId,
    this.storeName,
    this.storeCoverImageUrl,
    this.customerId,
    this.customerName,
    this.customerAvatarUrl,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// The conversation title from the viewer's perspective:
  /// a customer sees the store, while staff/admin see the customer.
  String displayNameFor(String role) {
    final isStaff = role == 'STAFF' || role == 'ADMIN';
    if (isStaff) return customerName ?? storeName ?? 'Conversation';
    return storeName ?? customerName ?? 'Conversation';
  }

  String avatarUrlFor(String role) {
    final isStaff = role == 'STAFF' || role == 'ADMIN';
    if (isStaff) return customerAvatarUrl ?? storeCoverImageUrl ?? '';
    return storeCoverImageUrl ?? customerAvatarUrl ?? '';
  }

  String get preview => lastMessagePreview ?? 'No messages yet';

  bool get hasUnread => unreadCount > 0;

  /// A compact, locale-free label for the inbox row (e.g. "12:45 PM",
  /// "Yesterday", "Mon", "Oct 12").
  String get timeLabel {
    final dt = lastMessageAt;
    if (dt == null) return '';

    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(thatDay).inDays;

    if (diffDays <= 0) {
      final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final ampm = local.hour < 12 ? 'AM' : 'PM';
      return '$hour12:${local.minute.toString().padLeft(2, '0')} $ampm';
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[local.weekday - 1];
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[local.month - 1]} ${local.day}';
    }
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? v) => v == null ? null : DateTime.tryParse(v);

    return Conversation(
      id: json['id'] as String,
      storeId: json['storeId'] as String?,
      storeName: json['storeName'] as String?,
      storeCoverImageUrl: json['storeCoverImageUrl'] as String?,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerAvatarUrl: json['customerAvatarUrl'] as String?,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: parse(json['lastMessageAt'] as String?),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      createdAt: parse(json['createdAt'] as String?),
      updatedAt: parse(json['updatedAt'] as String?),
    );
  }

  Conversation copyWith({int? unreadCount, String? lastMessagePreview, DateTime? lastMessageAt}) {
    return Conversation(
      id: id,
      storeId: storeId,
      storeName: storeName,
      storeCoverImageUrl: storeCoverImageUrl,
      customerId: customerId,
      customerName: customerName,
      customerAvatarUrl: customerAvatarUrl,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Conversation && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
