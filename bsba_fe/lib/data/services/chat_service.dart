import 'package:project/data/models/conversation.dart';
import 'package:project/data/models/message.dart';
import 'package:project/data/services/api_client.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  /// GET /api/v1/conversations?userId=..&role=..
  ///
  /// The backend wraps the page in ApiResponse:
  /// { success: true, data: { items: [...], page, size, totalElements, ... } }
  Future<List<Conversation>> getConversations({
    required String userId,
    String role = 'CUSTOMER',
  }) async {
    final response =
        await _apiClient.get('/conversations?userId=$userId&role=$role');

    final List<dynamic> items = response['data']['items'] as List<dynamic>;

    return items
        .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/conversations?userId=.. with body { storeId }.
  /// Get-or-create: returns the existing thread or a freshly created one.
  Future<Conversation> startConversation({
    required String userId,
    required String storeId,
  }) async {
    final response = await _apiClient.post(
      '/conversations?userId=$userId',
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

  /// POST /api/v1/conversations/{id}/messages?userId=..&role=..
  Future<Message> sendMessage({
    required String conversationId,
    required String userId,
    required String content,
    String role = 'CUSTOMER',
    String type = 'TEXT',
  }) async {
    final response = await _apiClient.post(
      '/conversations/$conversationId/messages?userId=$userId&role=$role',
      {'content': content, 'type': type},
    );

    return Message.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// GET /api/v1/conversations/unread-count?userId=..&role=..
  /// Returns the number of conversations that have unread messages.
  Future<int> getUnreadCount({
    required String userId,
    String role = 'CUSTOMER',
  }) async {
    final response = await _apiClient
        .get('/conversations/unread-count?userId=$userId&role=$role');
    return (response['data'] as num?)?.toInt() ?? 0;
  }

  /// PATCH /api/v1/conversations/{id}/read?userId=..&role=..
  Future<void> markRead({
    required String conversationId,
    required String userId,
    String role = 'CUSTOMER',
  }) async {
    await _apiClient
        .patch('/conversations/$conversationId/read?userId=$userId&role=$role');
  }
}
