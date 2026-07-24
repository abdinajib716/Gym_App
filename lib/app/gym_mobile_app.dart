import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api/api_client.dart';
import '../core/core.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/data/auth_service.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/member/data/member_api.dart';
import '../features/shared/data/firebase_device_token_provider.dart';
import '../features/shared/data/mobile_device_token_api.dart';
import '../features/shared/presentation/mobile_home_shell.dart';
import '../features/shared/presentation/splash_screen.dart';
import '../features/trainer/data/trainer_api.dart';
import '../shared/widgets/widgets.dart';

const _mobileDeviceTokenOverride = String.fromEnvironment(
  'MOBILE_DEVICE_TOKEN',
);

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
  static const _minimumSplashDuration = Duration(milliseconds: 1600);

  late final SessionStorage _storage;
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final AuthController _authController;
  late final MemberApi _memberApi;
  late final TrainerApi _trainerApi;
  late final MobileDeviceTokenApi _deviceTokenApi;
  late final MobileDeviceTokenRegistrar _deviceTokenRegistrar;
  late final FirebaseDeviceTokenProvider _firebaseDeviceTokenProvider;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _storage = SessionStorage();
    _apiClient = ApiClient(tokenProvider: _storage.readToken);
    _authService = AuthService(_apiClient);
    _deviceTokenApi = MobileDeviceTokenApi(_apiClient);
    _firebaseDeviceTokenProvider = const FirebaseDeviceTokenProvider(
      overrideToken: _mobileDeviceTokenOverride,
    );
    _deviceTokenRegistrar = MobileDeviceTokenRegistrar(
      api: _deviceTokenApi,
      tokenProvider: _firebaseDeviceTokenProvider.readToken,
    );
    _authController = AuthController(
      authService: _authService,
      storage: _storage,
      deviceTokenRegistrar: _deviceTokenRegistrar,
    );
    _memberApi = MemberApi(_apiClient);
    _trainerApi = TrainerApi(_apiClient);
    _authController.restore();
    Future<void>.delayed(_minimumSplashDuration, () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
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
            title: BrandLogo.appName,
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
    if (_showSplash || _authController.status == AuthStatus.booting) {
      return const SplashScreen();
    }

    if (_authController.status == AuthStatus.signedOut) {
      return LoginScreen(
        authController: _authController,
        authService: _authService,
      );
    }

    return MobileHomeShell(
      authController: _authController,
      memberApi: _memberApi,
      trainerApi: _trainerApi,
    );
  }
}
