import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/basic_information_section.dart';
import 'package:project/ui/boardgame_store/widgets/contact_details_section.dart';
import 'package:project/ui/boardgame_store/widgets/location_section.dart';
import 'package:project/ui/boardgame_store/widgets/operations_section.dart';
import 'package:project/ui/boardgame_store/widgets/save_changes_button.dart';
import 'package:project/ui/boardgame_store/widgets/store_media_section.dart';
import 'package:project/ui/boardgame_store/widgets/store_profile_title.dart';

class StoreProfileContent extends StatelessWidget {
  const StoreProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Form(
            key: context.read<StoreProfileViewModel>().formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              children: const [
                StoreProfileTitle(),
                SizedBox(height: 20),
                StoreMediaSection(),
                SizedBox(height: 28),
                BasicInformationSection(),
                SizedBox(height: 18),
                OperationsSection(),
                SizedBox(height: 18),
                LocationSection(),
                SizedBox(height: 18),
                ContactDetailsSection(),
                SizedBox(height: 24),
                SaveChangesButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
