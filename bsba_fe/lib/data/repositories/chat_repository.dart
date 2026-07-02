import '../models/conversation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _service;

  ChatRepository(this._service);

  Future<List<Conversation>> fetchConversations() {
    return _service.getConversations();
  }

  Future<Conversation> startConversation({
    required String storeId,
  }) {
    return _service.startConversation(storeId: storeId);
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
    required String content,
  }) {
    return _service.sendMessage(
      conversationId: conversationId,
      content: content,
    );
  }

  Future<void> markRead({
    required String conversationId,
  }) {
    return _service.markRead(conversationId: conversationId);
  }

  Future<int> fetchUnreadCount() {
    return _service.getUnreadCount();
  }
}
