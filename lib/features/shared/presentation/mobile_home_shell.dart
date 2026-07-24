import 'package:flutter/material.dart';

import '../../auth/state/auth_controller.dart';
import '../../member/data/member_api.dart';
import '../../member/presentation/member_home_screen.dart';
import '../../trainer/data/trainer_api.dart';
import '../../trainer/presentation/trainer_home_screen.dart';
import '../../trainer/presentation/trainer_password_change_screen.dart';
import '../models/mobile_user.dart';

class MobileHomeShell extends StatelessWidget {
  const MobileHomeShell({
    super.key,
    required this.authController,
    required this.memberApi,
    required this.trainerApi,
  });

  final AuthController authController;
  final MemberApi memberApi;
  final TrainerApi trainerApi;

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    if (user?.role == MobileRole.trainer) {
      if (user?.mustChangePassword == true) {
        return TrainerPasswordChangeScreen(
          authController: authController,
          trainerApi: trainerApi,
        );
      }

      return TrainerHomeScreen(
        authController: authController,
        trainerApi: trainerApi,
      );
    }

    return MemberHomeScreen(
      authController: authController,
      memberApi: memberApi,
    );
  }
}
