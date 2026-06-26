import 'package:project/data/models/conversation.dart';
import 'package:project/data/models/message.dart';
import 'package:project/data/services/api_client.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  /// GET /api/v1/conversations
  ///
  /// The caller's id + role come from the JWT (sent by [ApiClient] as a Bearer
  /// token), not from query params. The backend wraps the page in ApiResponse:
  /// { success: true, data: { items: [...], page, size, totalElements, ... } }
  Future<List<Conversation>> getConversations() async {
    final response = await _apiClient.get('/conversations');

    final List<dynamic> items = response['data']['items'] as List<dynamic>;

    return items
        .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/conversations with body { storeId }.
  /// Get-or-create: returns the existing thread or a freshly created one.
  /// The customer is resolved from the JWT; only customers may start a thread.
  Future<Conversation> startConversation({
    required String storeId,
  }) async {
    final response = await _apiClient.post(
      '/conversations',
      {'storeId': storeId},
    );
    return Conversation.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// GET /api/v1/conversations/{id}/messages — newest first (page 0).
  Future<List<Message>> getMessages({
    required String conversationId,
    int page = 0,
    int size = 50,
  }) async {
    final response = await _apiClient
        .get('/conversations/$conversationId/messages?page=$page&size=$size');

    final List<dynamic> items = response['data']['items'] as List<dynamic>;

    return items
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/conversations/{id}/messages with body { content, type }.
  /// The sender + role come from the JWT.
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    String type = 'TEXT',
  }) async {
    final response = await _apiClient.post(
      '/conversations/$conversationId/messages',
      {'content': content, 'type': type},
    );

    return Message.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// GET /api/v1/conversations/unread-count
  /// Returns the number of conversations that have unread messages.
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/conversations/unread-count');
    return (response['data'] as num?)?.toInt() ?? 0;
  }

  /// PATCH /api/v1/conversations/{id}/read
  Future<void> markRead({
    required String conversationId,
  }) async {
    await _apiClient.patch('/conversations/$conversationId/read');
  }
}
