import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/media_image_card.dart';
import 'package:project/ui/boardgame_store/widgets/section_title.dart';
import 'package:project/ui/boardgame_store/widgets/store_feedback.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class StoreMediaSection extends StatelessWidget {
  const StoreMediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreProfileViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: 'Store Media'),
            TextButton.icon(
              onPressed: () => showStoreAction(context, 'Image upload opened'),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
              label: const Text('Add Images'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MediaImageCard(
          height: 192,
          imagePath: 'assets/images/booking/booking_room_dragon.png',
          imageUrl: viewModel.coverLetterUrl,
          overlay: FilledButton.tonalIcon(
            onPressed: () =>
                showStoreAction(context, 'Cover photo picker opened'),
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text('Change Cover Photo'),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: const _GalleryTile(
                    imagePath: 'assets/images/booking/booking_room_cyber.png',
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: const _GalleryTile(
                    imagePath: 'assets/images/booking/booking_room_dragon.jpeg',
                  ),
                ),
                SizedBox(width: tileWidth, child: const _UploadTile()),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: MediaImageCard(height: double.infinity, imagePath: imagePath),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: OutlinedButton(
        onPressed: () => showStoreAction(context, 'Upload slot selected'),
        style: OutlinedButton.styleFrom(
          foregroundColor: StaffDashboardColors.muted,
          side: const BorderSide(
            color: StaffDashboardColors.border,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded),
            SizedBox(height: 6),
            Text(
              'Upload',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
