import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project/data/models/conversation.dart';
import 'package:project/data/repositories/chat_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/chat_service.dart';
import 'package:project/data/services/chat_socket_service.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';
import 'package:project/ui/inbox/inbox_viewmodel.dart';
import 'package:project/ui/inbox/widgets/chat_screen.dart';
import 'package:project/ui/presence/presence_viewmodel.dart';

/// Staff-facing conversation inbox: a search field over a list of conversation
/// cards (avatar + last message + unread badge). Reuses [InboxViewModel], so it
/// shares the same REST load + live socket updates as the customer inbox.
class StaffChatInbox extends StatelessWidget {
  const StaffChatInbox({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InboxViewModel(
        ChatRepository(ChatService(ApiClient())),
        ChatSocketService(),
      )..start(),
      child: const _StaffChatView(),
    );
  }
}

class _StaffChatView extends StatelessWidget {
  const _StaffChatView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InboxViewModel>();

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: _SearchField(onChanged: vm.onSearchChanged),
          ),
          Expanded(child: _StaffChatBody(vm: vm)),
        ],
      ),
    );
  }
}

class _StaffChatBody extends StatelessWidget {
  const _StaffChatBody({required this.vm});

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

    final conversations = vm.conversations;
    if (conversations.isEmpty) {
      return const Center(
        child: Text(
          'No conversations yet',
          style: TextStyle(color: StaffDashboardColors.muted, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadConversations,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: conversations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final c = conversations[index];
          return _ConversationCard(
            conversation: c,
            role: vm.role,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<PresenceViewModel>.value(
                    value: context.read<PresenceViewModel>(),
                    child: ChatScreen(
                      conversationId: c.id,
                      name: c.displayNameFor(vm.role),
                      presenceUserIds: [
                        if (c.customerId != null) c.customerId!,
                      ],
                    ),
                  ),
                ),
              );
              // Re-sync unread on return so a thread just read stops looking new.
              await vm.silentReload();
            },
          );
        },
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.role,
    this.onTap,
  });

  final Conversation conversation;
  final String role;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = conversation.hasUnread;
    final name = conversation.displayNameFor(role);

    // Staff watch the customer's presence; a customer would watch the store's staff.
    final presence = context.watch<PresenceViewModel>();
    final isStaffView = role == 'STAFF' || role == 'ADMIN';
    final isOnline = isStaffView
        ? presence.isOnline(conversation.customerId)
        : presence.anyOnline(conversation.staffUserIds);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StaffDashboardColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Blue accent strip down the leading edge for unread threads.
                  Container(
                    width: 4,
                    color: isUnread
                        ? StaffDashboardColors.accent
                        : Colors.transparent,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ConversationAvatar(
                            name: name,
                            imageUrl: conversation.avatarUrlFor(role),
                            isOnline: isOnline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: StaffDashboardColors.text,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      conversation.relativeLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isUnread
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isUnread
                                            ? StaffDashboardColors.accent
                                            : StaffDashboardColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        conversation.previewFor(role),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.3,
                                          fontWeight: isUnread
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isUnread
                                              ? StaffDashboardColors.text
                                              : StaffDashboardColors.muted,
                                        ),
                                      ),
                                    ),
                                    if (isUnread) ...[
                                      const SizedBox(width: 8),
                                      _UnreadBadge(
                                        count: conversation.unreadCount,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({
    required this.name,
    required this.imageUrl,
    this.isOnline = false,
  });

  final String name;
  final String imageUrl;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    final avatar = CircleAvatar(
      radius: 26,
      backgroundColor: StaffDashboardColors.accent.withValues(alpha: 0.12),
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isNotEmpty
          ? null
          : Text(
              initial,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: StaffDashboardColors.accent,
              ),
            ),
    );

    // Always show the dot: green when the other party is connected, grey when not.
    return Stack(
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: StaffDashboardColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
          color: StaffDashboardColors.muted,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: StaffDashboardColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: StaffDashboardColors.accent),
        ),
      ),
    );
  }
}
