import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class GameItem {
  final String title;
  final String imageUrl;
  final String players;
  final String playtime;
  final int stock;
  final String? tag;
  final Color? tagColor;

  GameItem({
    required this.title,
    required this.imageUrl,
    required this.players,
    required this.playtime,
    required this.stock,
    this.tag,
    this.tagColor,
  });
}

class StaffGamesTemplate extends StatefulWidget {
  const StaffGamesTemplate({super.key});

  @override
  State<StaffGamesTemplate> createState() => _StaffGamesTemplateState();
}

class _StaffGamesTemplateState extends State<StaffGamesTemplate> {
  final List<GameItem> _games = [
    GameItem(
      title: 'Gloomhaven',
      imageUrl:
          'https://i0.wp.com/theboardgameschronicle.com/wp-content/uploads/2021/07/40_07.jpg?fit=816%2C494&ssl=1',
      players: '1-4 Players',
      playtime: '120 min',
      stock: 3,
      tag: 'Premium',
      tagColor: StaffDashboardColors.primary,
    ),
    GameItem(
      title: 'Catan',
      imageUrl:
          'https://www.meeplemountain.com/wp-content/uploads/2025/11/CATAN-CK-1-1200x900-cropped.jpg',
      players: '3-4 Players',
      playtime: '60 min',
      stock: 8,
      tag: 'Classic',
      tagColor: const Color(0xFFD96B27),
    ),
    GameItem(
      title: 'Wingspan',
      imageUrl:
          'https://www.myboardgameguides.com/wp-content/uploads/2024/05/IMG_0965-scaled.jpg',
      players: '1-5 Players',
      playtime: '40 min',
      stock: 1,
    ),
    GameItem(
      title: 'Scythe',
      imageUrl:
          'https://b1803394.smushcdn.com/1803394/wp-content/uploads/2017/09/IMG_0586-1200x900-cropped.jpg?lossy=1&strip=1&webp=1&size=1825x0',
      players: '1-5 Players',
      playtime: '90 min',
      stock: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: StaffDashboardColors.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: StaffDashboardColors.muted,
                  ),
                  hintText: 'Search game library...',
                  hintStyle: const TextStyle(color: StaffDashboardColors.muted),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: StaffDashboardColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: StaffDashboardColors.border,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.sort,
                        size: 18,
                        color: StaffDashboardColors.text,
                      ),
                      label: const Text(
                        'Category',
                        style: TextStyle(
                          color: StaffDashboardColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F2F5),
                        side: const BorderSide(
                          color: StaffDashboardColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.filter_list,
                        size: 18,
                        color: StaffDashboardColors.text,
                      ),
                      label: const Text(
                        'Sort',
                        style: TextStyle(
                          color: StaffDashboardColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F2F5),
                        side: const BorderSide(
                          color: StaffDashboardColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _games.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return _buildGameCard(game);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(GameItem game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffDashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                child: Image.network(
                  game.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (game.tag != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: game.tagColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.tag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: StaffDashboardColors.text,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: StaffDashboardColors.muted,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: StaffDashboardColors.muted,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: StaffDashboardColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.players,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StaffDashboardColors.muted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: StaffDashboardColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.playtime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StaffDashboardColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: StaffDashboardColors.border),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.stock > 2 ? 'IN STOCK' : 'LOW STOCK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: game.stock > 2
                            ? StaffDashboardColors.muted
                            : const Color(0xFF8B779A),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: StaffDashboardColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (game.stock > 0) {
                                  _games[_games.indexOf(game)] = GameItem(
                                    title: game.title,
                                    imageUrl: game.imageUrl,
                                    players: game.players,
                                    playtime: game.playtime,
                                    stock: game.stock - 1,
                                    tag: game.tag,
                                    tagColor: game.tagColor,
                                  );
                                }
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: StaffDashboardColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            color: const Color(0xFFF0F2F5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            child: Text(
                              '${game.stock}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: StaffDashboardColors.text,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _games[_games.indexOf(game)] = GameItem(
                                  title: game.title,
                                  imageUrl: game.imageUrl,
                                  players: game.players,
                                  playtime: game.playtime,
                                  stock: game.stock + 1,
                                  tag: game.tag,
                                  tagColor: game.tagColor,
                                );
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: StaffDashboardColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
