import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project/data/repositories/chat_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/chat_service.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/ui/inbox/inbox_viewmodel.dart';
import 'package:project/ui/inbox/widgets/chat_item.dart';
import 'package:project/ui/inbox/widgets/chat_screen.dart';
import 'package:project/ui/presence/presence_viewmodel.dart';

class InboxContent extends StatelessWidget {
  const InboxContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InboxViewModel(
        ChatRepository(ChatService(ApiClient())),
        ChatSocketService(),
      )..start(),
      child: const _InboxView(),
    );
  }
}

class _InboxView extends StatelessWidget {
  const _InboxView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InboxViewModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: _SearchField(onChanged: vm.onSearchChanged),
        ),
        Expanded(child: _InboxBody(vm: vm)),
      ],
    );
  }
}

class _InboxBody extends StatelessWidget {
  const _InboxBody({required this.vm});

  final InboxViewModel vm;

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
              onPressed: vm.loadConversations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.isEmpty) {
      return const Center(
        child: Text(
          'No conversations yet',
          style: TextStyle(color: Color(0xFF717785), fontSize: 14),
        ),
      );
    }

    final conversations = vm.conversations;
    // The customer sees the store as online when any of its staff is connected.
    final presence = context.watch<PresenceViewModel>();

    return RefreshIndicator(
      onRefresh: vm.loadConversations,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final c = conversations[index];
          return ChatItem(
            name: c.displayNameFor(vm.role),
            message: c.previewFor(vm.role),
            draft: vm.draftFor(c.id),
            time: c.relativeLabel,
            unreadCount: c.unreadCount,
            isOnline: presence.anyOnline(c.staffUserIds),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<PresenceViewModel>.value(
                    value: context.read<PresenceViewModel>(),
                    child: ChatScreen(
                      conversationId: c.id,
                      name: c.displayNameFor(vm.role),
                      presenceUserIds: c.staffUserIds,
                    ),
                  ),
                ),
              );
              // Re-sync unread + drafts on return: covers a missed/out-of-order
              // socket update so a thread you just read isn't still bold.
              await vm.silentReload();
            },
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: Color(0xFFC1C6D5), fontSize: 14),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF717785),
          size: 20,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F3FC),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC1C6D5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC1C6D5)),
        ),
      ),
    );
  }
}
