import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/core.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/state/auth_controller.dart';

class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final user = authController.user;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Trainer',
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: authController.logout,
            icon: const Icon(IconsaxPlusLinear.logout_1),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        child: EmptyState(
          icon: IconsaxPlusLinear.user_octagon,
          title: 'Trainer workspace pending',
          message:
              'Signed in as ${user?.name ?? 'trainer'}. Trainer mobile endpoints are still marked pending in the backend task list, so this shell is ready for the API contract phase.',
        ),
      ),
    );
  }
}
