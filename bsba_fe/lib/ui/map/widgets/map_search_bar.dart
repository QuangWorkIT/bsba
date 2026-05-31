import 'package:flutter/material.dart';

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({super.key, required this.query});

  final String query;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.05),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.tune,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
