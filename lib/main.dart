import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

// Core imports
import 'core/core.dart';

// Widget imports
import 'shared/widgets/widgets.dart';

/// Global instances
late ConnectivityCubit connectivityCubit;
late ThemeProvider themeProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Network Info
  final networkInfo = NetworkInfoImpl();
  
  // Initialize Connectivity Cubit
  connectivityCubit = ConnectivityCubit(networkInfo: networkInfo);
  
  // Initialize Theme Provider
  themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Connectivity Cubit - For offline/online UI
        BlocProvider.value(value: connectivityCubit),
      ],
      child: ListenableBuilder(
        listenable: themeProvider,
        builder: (context, _) {
          return MaterialApp(
            title: 'Flutter UI Kit',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.effectiveThemeMode,
            
            home: const ExampleHomePage(),
          );
        },
      ),
    );
  }
}

/// Example Home Page - Shows all UI Kit features
class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  int _currentNavIndex = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap with connectivity status to show offline banner
      body: ConnectivityStatusWidget(
        showAtTop: true,
        onRetry: () {
          context.read<ConnectivityCubit>().checkConnectivity();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('UI Kit Demo', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  'All reusable components',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Connectivity Status
                _buildSection('Connectivity Status'),
                BlocBuilder<ConnectivityCubit, ConnectivityState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: state.isConnected 
                                ? AppColors.success 
                                : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isConnected ? 'Online' : 'Offline',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Theme Toggle
                _buildSection('Theme'),
                Row(
                  children: [
                    Text('Dark Mode', style: AppTextStyles.bodyMedium),
                    const Spacer(),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeTrackColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Buttons Section
                _buildSection('Buttons'),
                CustomButton(
                  text: 'Primary Button',
                  onPressed: () {},
                  type: ButtonType.primary,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Secondary Button',
                  onPressed: () {},
                  type: ButtonType.secondary,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Outline Button',
                  onPressed: () {},
                  type: ButtonType.outline,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Loading Button',
                  onPressed: () {},
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Disabled Button',
                  onPressed: null,
                ),
                
                const SizedBox(height: 24),
                
                // Text Fields Section
                _buildSection('Text Fields'),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const SearchTextField(
                  hintText: 'Search...',
                ),
                
                const SizedBox(height: 24),
                
                // Loading Indicators
                _buildSection('Loading Indicators'),
                const Row(
                  children: [
                    LoadingIndicator(size: 24),
                    SizedBox(width: 16),
                    LoadingIndicator(size: 32),
                    SizedBox(width: 16),
                    LoadingIndicator(size: 40),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    ShimmerBox(height: 40, width: 100),
                    SizedBox(width: 16),
                    ShimmerCircle(size: 40),
                  ],
                ),
                
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        items: const [
          BottomNavItem(icon: IconsaxPlusLinear.home_1, label: 'Home'),
          BottomNavItem(icon: IconsaxPlusLinear.search_normal_1, label: 'Search'),
          BottomNavItem(icon: IconsaxPlusLinear.heart, label: 'Favorites'),
          BottomNavItem(icon: IconsaxPlusLinear.profile, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.h2,
      ),
    );
  }
}
