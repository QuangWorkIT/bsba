import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project/data/models/message.dart';
import 'package:project/data/repositories/chat_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/chat_service.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/ui/inbox/chat_viewmodel.dart';
import 'package:project/ui/inbox/widgets/chat/chat_header.dart';
import 'package:project/ui/inbox/widgets/chat/chat_input_area.dart';
import 'package:project/ui/inbox/widgets/chat/chat_staff_message.dart';
import 'package:project/ui/inbox/widgets/chat/chat_user_message.dart';
import 'package:project/ui/presence/presence_viewmodel.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.name,
    this.presenceUserIds = const [],
  });

  final String conversationId;
  final String name;

  /// The other party's user id(s); the header shows them online/offline.
  /// Staff pass the customer's id; a customer passes the store's staff ids.
  final List<String> presenceUserIds;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(
        ChatRepository(ChatService(ApiClient())),
        ChatSocketService(),
        conversationId: conversationId,
      )..start(),
      child: _ChatView(name: name, presenceUserIds: presenceUserIds),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView({required this.name, required this.presenceUserIds});

  final String name;
  final List<String> presenceUserIds;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    // Presence is provided by the inbox/home above this route; tolerate its
    // absence so the chat still opens if a caller didn't supply it.
    PresenceViewModel? presence;
    try {
      presence = context.watch<PresenceViewModel>();
    } catch (_) {
      presence = null;
    }
    final isOnline = presence?.anyOnline(presenceUserIds) ?? false;
    final statusSubtitle =
        !vm.isLive ? 'Connecting…' : (isOnline ? 'Online' : 'Offline');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FC),
      appBar: ChatHeader(
        name: name,
        subtitle: statusSubtitle,
        isOnline: isOnline,
      ),
      body: Column(
        children: [
          Expanded(child: _MessageList(vm: vm)),
          ChatInputArea(
            enabled: !vm.isSending,
            onSend: vm.sendMessage,
            loadDraft: vm.loadDraft,
            onDraftChanged: vm.saveDraft,
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.vm});

  final ChatViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                vm.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Say hello!',
          style: TextStyle(color: Color(0xFF717785), fontSize: 14),
        ),
      );
    }

    // Feed newest-first into a reversed list so it sticks to the bottom and
    // new messages appear without manual scrolling.
    final reversed = vm.messages.reversed.toList();

    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.all(24),
      itemCount: reversed.length,
      separatorBuilder: (_, _) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final Message m = reversed[index];
        if (vm.isMine(m)) {
          return ChatUserMessage(
            text: m.content,
            time: m.timeLabel,
            readReceipt: m.id == vm.lastReadMineId ? 'Đã xem' : null,
          );
        }
        return ChatStaffMessage(time: m.timeLabel, message: m.content);
      },
    );
  }
}
