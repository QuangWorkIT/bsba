import '../models/conversation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _service;

  ChatRepository(this._service);

  Future<List<Conversation>> fetchConversations({
    required String userId,
    String role = 'CUSTOMER',
  }) {
    return _service.getConversations(userId: userId, role: role);
  }

  Future<List<Message>> fetchMessages({
    required String conversationId,
    int page = 0,
    int size = 50,
  }) {
    return _service.getMessages(
      conversationId: conversationId,
      page: page,
      size: size,
    );
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String userId,
    required String content,
    String role = 'CUSTOMER',
  }) {
    return _service.sendMessage(
      conversationId: conversationId,
      userId: userId,
      content: content,
      role: role,
    );
  }

  Future<void> markRead({
    required String conversationId,
    required String userId,
    String role = 'CUSTOMER',
  }) {
    return _service.markRead(
      conversationId: conversationId,
      userId: userId,
      role: role,
    );
  }

  Future<int> fetchUnreadCount({
    required String userId,
    String role = 'CUSTOMER',
  }) {
    return _service.getUnreadCount(userId: userId, role: role);
  }
}
