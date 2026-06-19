import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/data/repositories/store_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/current_user.dart';
import 'package:project/data/services/map_service.dart';
import 'package:project/data/services/store_service.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/store_profile_content.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return ChangeNotifierProvider(
      create: (_) => StoreProfileViewModel(
        repository: StoreRepository(
          MapService(apiClient),
          null,
          StoreService(apiClient),
        ),
        staffId: CurrentUser.instance.id,
      )..loadStore(),
      child: const StoreProfileContent(),
    );
  }
}
