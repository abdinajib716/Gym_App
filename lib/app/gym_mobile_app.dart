import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api/api_client.dart';
import '../core/core.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/data/auth_service.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/member/data/member_api.dart';
import '../features/member/presentation/member_home_screen.dart';
import '../features/shared/models/mobile_user.dart';
import '../features/trainer/presentation/trainer_home_screen.dart';
import '../shared/widgets/widgets.dart';

class GymMobileApp extends StatefulWidget {
  const GymMobileApp({
    super.key,
    required this.themeProvider,
    required this.connectivityCubit,
  });

  final ThemeProvider themeProvider;
  final ConnectivityCubit connectivityCubit;

  @override
  State<GymMobileApp> createState() => _GymMobileAppState();
}

class _GymMobileAppState extends State<GymMobileApp> {
  late final SessionStorage _storage;
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final AuthController _authController;
  late final MemberApi _memberApi;

  @override
  void initState() {
    super.initState();
    _storage = SessionStorage();
    _apiClient = ApiClient(tokenProvider: _storage.readToken);
    _authService = AuthService(_apiClient);
    _authController = AuthController(
      authService: _authService,
      storage: _storage,
    );
    _memberApi = MemberApi(_apiClient);
    _authController.restore();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: widget.connectivityCubit)],
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.themeProvider, _authController]),
        builder: (context, _) {
          return MaterialApp(
            title: 'Gym App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: widget.themeProvider.effectiveThemeMode,
            home: ConnectivityStatusWidget(
              showAtTop: true,
              onRetry: () =>
                  context.read<ConnectivityCubit>().checkConnectivity(),
              child: _buildHome(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHome() {
    if (_authController.status == AuthStatus.booting) {
      return const Scaffold(body: Center(child: LoadingIndicator(size: 36)));
    }

    if (_authController.status == AuthStatus.signedOut) {
      return LoginScreen(
        authController: _authController,
        authService: _authService,
      );
    }

    final user = _authController.user;
    if (user?.role == MobileRole.trainer) {
      return TrainerHomeScreen(authController: _authController);
    }

    return MemberHomeScreen(
      authController: _authController,
      memberApi: _memberApi,
    );
  }
}
