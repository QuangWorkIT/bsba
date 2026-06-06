import 'package:flutter/material.dart';
import 'package:project/data/models/map_store.dart';

class MapSearchResultsDropdown extends StatelessWidget {
  const MapSearchResultsDropdown({
    super.key,
    required this.results,
    required this.isLoading,
    required this.onStoreSelected,
    required this.distanceLabelFor,
  });

  final List<MapStore> results;
  final bool isLoading;
  final ValueChanged<MapStore> onStoreSelected;
  final String Function(MapStore) distanceLabelFor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 4,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: isLoading && results.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Text(
                      'No board-game spaces found.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: results.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: colorScheme.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final store = results[index];
                      final distance = distanceLabelFor(store);

                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(
                          Icons.storefront_outlined,
                          color: colorScheme.primary,
                        ),
                        title: Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          store.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: distance.isEmpty
                            ? null
                            : Text(
                                distance,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                        onTap: () => onStoreSelected(store),
                      );
                    },
                  ),
      ),
    );
  }
}
