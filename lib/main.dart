import 'package:flutter/material.dart';

import 'app/gym_mobile_app.dart';
import 'core/core.dart';

late ConnectivityCubit connectivityCubit;
late ThemeProvider themeProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final networkInfo = NetworkInfoImpl();
  connectivityCubit = ConnectivityCubit(networkInfo: networkInfo);

  themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    GymMobileApp(
      themeProvider: themeProvider,
      connectivityCubit: connectivityCubit,
    ),
  );
}
