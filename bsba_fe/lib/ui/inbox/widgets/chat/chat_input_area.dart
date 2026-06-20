import 'dart:async';

import 'package:flutter/material.dart';

/// Bottom message composer: attach button, text field and send button.
class ChatInputArea extends StatefulWidget {
  const ChatInputArea({
    super.key,
    this.onSend,
    this.enabled = true,
    this.loadDraft,
    this.onDraftChanged,
  });

  /// Called with the trimmed, non-empty message when the user sends.
  final ValueChanged<String>? onSend;
  final bool enabled;

  /// Restores a previously saved draft when the composer first appears.
  final Future<String?> Function()? loadDraft;

  /// Persists the current draft (called with '' to clear it).
  final ValueChanged<String>? onDraftChanged;

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  /// Height of the text field. The buttons are kept smaller so the composer is
  /// dominated by the field, not the controls.
  static const double _fieldHeight = 44;
  static const double _buttonSize = 38;
  static const double _fieldHPadding = 12;
  static const TextStyle _fieldTextStyle =
      TextStyle(color: Color(0xFF181C22), fontSize: 14);

  final TextEditingController _controller = TextEditingController();
  Timer? _saveDebounce;

  /// True once the typed text wraps to a second line; the send/attach buttons
  /// jump to the top instead of staying vertically centred.
  bool _isMultiline = false;
  double _contentWidth = 0;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
    _controller.addListener(_scheduleSave);
    _controller.addListener(_updateMultiline);
  }

  /// Capture the field's content width during layout, then re-evaluate the
  /// line count once the frame settles (can't setState mid-build).
  void _syncContentWidth(double width) {
    if (width == _contentWidth || width <= 0) return;
    _contentWidth = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateMultiline();
    });
  }

  /// Measure the current text against the field's content width and flip
  /// [_isMultiline] when it spans more than one line.
  void _updateMultiline() {
    if (_contentWidth <= 0) return;
    final painter = TextPainter(
      text: TextSpan(text: _controller.text, style: _fieldTextStyle),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _contentWidth);
    final next = painter.computeLineMetrics().length > 1;
    if (next != _isMultiline) {
      setState(() => _isMultiline = next);
    }
  }

  Future<void> _restoreDraft() async {
    final draft = await widget.loadDraft?.call();
    // Don't clobber anything typed while the draft was loading.
    if (!mounted || draft == null || draft.isEmpty || _controller.text.isNotEmpty) {
      return;
    }
    _controller.text = draft;
    _controller.selection =
        TextSelection.collapsed(offset: draft.length);
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 400),
      () => widget.onDraftChanged?.call(_controller.text),
    );
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    // Flush the latest draft immediately so backing out never loses it.
    widget.onDraftChanged?.call(_controller.text);
    _controller.removeListener(_scheduleSave);
    _controller.removeListener(_updateMultiline);
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend?.call(text);
    _saveDebounce?.cancel();
    _controller.clear();
    widget.onDraftChanged?.call(''); // sent → discard the saved draft
  }

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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            // Single line → buttons centred on the field. Once the text wraps to
            // a second line the buttons jump to the top.
            crossAxisAlignment:
                _isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _buttonSize,
                height: _buttonSize,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.attach_file,
                      size: 20, color: Color(0xFF717785)),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: _fieldHeight),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3FC),
                    border: Border.all(color: const Color(0xFFE0E2EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: _fieldHPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // The width text actually gets to fill before wrapping.
                      _syncContentWidth(constraints.maxWidth);
                      return TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        style: _fieldTextStyle,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Type your message...',
                          hintStyle:
                              TextStyle(color: Color(0xFF717785), fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: primary,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _handleSend,
                  child: const SizedBox(
                    width: _buttonSize,
                    height: _buttonSize,
                    child: Center(
                      child: Icon(Icons.send, size: 18, color: Colors.white),
                    ),
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
