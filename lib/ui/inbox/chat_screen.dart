import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    this.name = 'Sarah M.',
    this.subtitle = 'Game Master • Online',
  });

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FC),
      appBar: _ChatHeader(name: name, subtitle: subtitle),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                _DateDivider(text: 'Today, 2:14 PM'),
                SizedBox(height: 24),
                _StaffMessage(
                  time: 'Sarah • 2:14 PM',
                  message:
                      'Hi there! I see you have a reservation for a table of 4 at 7:00 PM tonight. Would you like me to pre-load any specific board games at your table so they are ready when you arrive?',
                ),
                SizedBox(height: 24),
                _UserMessage(
                  text: "Yes, please! We definitely want to play 'Settlers of Catan'.",
                ),
                SizedBox(height: 24),
                _StaffMessageWithCard(
                  time: 'Sarah • 2:18 PM',
                  message:
                      "Great choice. I've placed the base game at Table 4 for you. We also have the 'Seafarers' expansion available right now. Shall I add that to your reservation for an extra \$5?",
                ),
                SizedBox(height: 24),
                _UserMessage(
                  text: "Actually, let's just stick to the base game for now. Thanks!",
                  readReceipt: 'Read • 2:20 PM',
                ),
                SizedBox(height: 24),
                _TypingIndicator(),
              ],
            ),
          ),
          const _InputArea(),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  const _ChatHeader({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 44,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF414753)),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          const _AvatarWithStatus(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF181C22),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF414753)),
          onPressed: () {},
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E2EB)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class _AvatarWithStatus extends StatelessWidget {
  const _AvatarWithStatus();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Text(
              'S',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E8F1),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF414753),
          ),
        ),
      ),
    );
  }
}

class _StaffAvatar extends StatelessWidget {
  const _StaffAvatar();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return CircleAvatar(
      radius: 16,
      backgroundColor: primary.withValues(alpha: 0.12),
      child: Text(
        'S',
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StaffBubble extends StatelessWidget {
  const _StaffBubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const _StaffAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FF),
                  border: Border.all(color: const Color(0xFFE0E2EB)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffMessage extends StatelessWidget {
  const _StaffMessage({required this.time, required this.message});

  final String time;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StaffBubble(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Color(0xFF717785)),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.43,
              color: Color(0xFF181C22),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffMessageWithCard extends StatelessWidget {
  const _StaffMessageWithCard({required this.time, required this.message});

  final String time;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _StaffBubble(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Color(0xFF717785)),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.43,
              color: Color(0xFF181C22),
            ),
          ),
          const SizedBox(height: 16),
          const _ReservationCard(),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC1C6D5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFFE0E2EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.extension, color: primary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catan: Seafarers Expansion',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.33,
                    color: Color(0xFF181C22),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '+ \$5.00 table fee',
                  style: TextStyle(fontSize: 13, color: Color(0xFF414753)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _AddButton(primary: primary),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 12, color: Color(0xFFFEFCFF)),
              SizedBox(width: 4),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFEFCFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text, this.readReceipt});

  final String text;
  final String? readReceipt;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.43,
                  color: Colors.white,
                ),
              ),
              if (readReceipt != null) ...[
                const SizedBox(height: 4),
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    readReceipt!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAAC7FF),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.7,
      child: _StaffBubble(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF717785),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  const _InputArea();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E2EB))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file,
                    size: 20, color: Color(0xFF717785)),
                onPressed: () {},
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3FC),
                    border: Border.all(color: const Color(0xFFE0E2EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Type your message...',
                      hintStyle:
                          TextStyle(color: Color(0xFF717785), fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: primary,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.send, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
