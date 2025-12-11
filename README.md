# app_kit

# Flutter UI Kit Template

Reusable Flutter UI Kit - Template ahaan loo isticmaali karo application kasta oo cusub.

**Features:**
- ✅ BLoC/Cubit State Management (BLoC = Business Logic, Cubit = Frontend)
- ✅ Offline/Online Connectivity Control + UI Banner
- ✅ Light/Dark Theme Support
- ✅ Reusable UI Components

## 📁 Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       # Color palette (Light + Dark)
│   │   ├── app_text_styles.dart  # Typography (Poppins)
│   │   └── app_constants.dart    # Spacing, Radius, Shadows
│   ├── theme/
│   │   ├── app_theme.dart        # Light/Dark ThemeData
│   │   ├── theme_provider.dart   # Theme state management
│   │   └── theme.dart            # Theme exports
│   ├── network/
│   │   ├── network_info.dart       # Network connectivity service
│   │   ├── connectivity_cubit.dart # Cubit for UI connectivity state
│   │   └── network.dart            # Network exports
│   ├── bloc/
│   │   ├── base_state.dart    # Base states (initial, loading, success, failure)
│   │   ├── base_cubit.dart    # Base Cubit for frontend
│   │   ├── base_bloc.dart     # Base BLoC for business logic
│   │   └── bloc.dart          # BLoC exports
│   └── core.dart              # Core exports
│
└── shared/
    └── widgets/
        ├── common/
        │   ├── custom_button.dart              # Primary/Secondary/Outline
        │   ├── custom_text_field.dart          # Text input + Search
        │   ├── loading_indicator.dart          # Spinner + Shimmer
        │   ├── empty_state.dart                # Empty views
        │   ├── error_view.dart                 # Error states
        │   ├── custom_app_bar.dart             # AppBar
        │   ├── bottom_nav_bar.dart             # Bottom tabs
        │   └── connectivity_status_widget.dart # Offline banner
        └── widgets.dart                        # Widget exports
```

## 🚀 Usage

### 1. Copy to your project
Copy the `lib/core/` and `lib/shared/` folders to your new project.

### 2. Update package name
Replace `flutter_ui_kit_template` with your app package name in all files.

### 3. Add dependencies to pubspec.yaml
```yaml
dependencies:
  # State Management
  flutter_bloc: ^9.1.1
  equatable: ^2.0.5
  dartz: ^0.10.1
  
  # Connectivity
  connectivity_plus: ^7.0.0
  internet_connection_checker: ^1.0.0+1
  
  # Navigation
  go_router: ^13.0.0
  
  # Storage & UI
  shared_preferences: ^2.5.3
  shimmer: ^3.0.0
  awesome_dialog: ^3.3.0
  wolt_modal_sheet: ^0.11.0
  iconsax: ^0.0.8
```

### 4. Add Poppins font files
Download Poppins font and add to `assets/fonts/`

### 5. Import and use
```dart
// Import core utilities
import 'package:your_app/core/core.dart';

// Import widgets
import 'package:your_app/shared/widgets/widgets.dart';

// Use widgets
CustomButton(
  text: 'Continue',
  onPressed: () {},
  type: ButtonType.primary,
);

CustomTextField(
  labelText: 'Email',
  hintText: 'Enter your email',
  prefixIcon: Iconsax.sms,
);
```

## 🎨 Colors

| Color | Light | Dark |
|-------|-------|------|
| Primary | `#233973` | `#233973` |
| Accent | `#8959C1` | `#8959C1` |
| Background | `#FFFFFF` | `#121212` |
| Text Primary | `#233973` | `#E1E1E1` |
| Text Secondary | `#8B93A5` | `#9E9E9E` |

## 🔤 Typography (Poppins)

| Style | Size | Weight |
|-------|------|--------|
| H1 | 22px | SemiBold |
| H2 | 16px | SemiBold |
| H3 | 14px | SemiBold |
| Body Large | 16px | Regular |
| Body Medium | 14px | Regular |
| Body Small | 12px | Regular |
| Button | 14px | SemiBold |

## 📱 Widgets

### CustomButton
```dart
CustomButton(
  text: 'Sign In',
  onPressed: () {},
  type: ButtonType.primary,  // primary, secondary, outline
  size: ButtonSize.medium,   // small, medium, large
  isLoading: false,
  icon: Iconsax.login,
);
```

### CustomTextField
```dart
CustomTextField(
  labelText: 'Password',
  hintText: 'Enter password',
  obscureText: true,
  prefixIcon: Iconsax.lock,
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
);
```

### BottomNavBar
```dart
BottomNavBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  items: [
    BottomNavItem(icon: Iconsax.home_2, label: 'Home'),
    BottomNavItem(icon: Iconsax.search_normal, label: 'Search'),
    BottomNavItem(icon: Iconsax.user, label: 'Profile'),
  ],
);
```

## 🌐 Connectivity (Offline/Online)

### Setup in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Network
  final networkInfo = NetworkInfoImpl();
  final connectivityCubit = ConnectivityCubit(networkInfo: networkInfo);
  
  runApp(
    BlocProvider.value(
      value: connectivityCubit,
      child: MyApp(),
    ),
  );
}
```

### Show Offline Banner
```dart
Scaffold(
  body: ConnectivityStatusWidget(
    showAtTop: true,
    onRetry: () => context.read<ConnectivityCubit>().checkConnectivity(),
    child: YourContent(),
  ),
);
```

### Check Connectivity in Code
```dart
// Using extension
if (context.isOffline) {
  showError('No internet connection');
  return;
}

// Using BlocBuilder
BlocBuilder<ConnectivityCubit, ConnectivityState>(
  builder: (context, state) {
    if (!state.isConnected) {
      return OfflineView();
    }
    return OnlineView();
  },
);
```

## 🔄 State Management (BLoC/Cubit)

### Cubit for Frontend (Simple UI State)
```dart
// State
class CounterState extends GenericState<int> {
  const CounterState({super.status, super.data, super.errorMessage});
}

// Cubit
class CounterCubit extends GenericCubit<int> {
  void increment() => setSuccess((state.data ?? 0) + 1);
  void decrement() => setSuccess((state.data ?? 0) - 1);
}
```

### BLoC for Business Logic (Complex Logic)
```dart
// Events
abstract class UserEvent extends BaseEvent {}
class LoadUser extends UserEvent {
  final String userId;
  LoadUser(this.userId);
}

// State
class UserState extends BaseState {
  final User? user;
  const UserState({super.status, super.errorMessage, this.user});
}

// BLoC
class UserBloc extends BaseBloc<UserEvent, UserState> {
  final UserRepository _repo;
  
  UserBloc(this._repo) : super(const UserState()) {
    on<LoadUser>(_onLoadUser);
  }
  
  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    await executeEither(
      operation: () => _repo.getUser(event.userId),
      emit: emit,
      onLoading: () => UserState(status: StateStatus.loading),
      onSuccess: (user) => UserState(status: StateStatus.success, user: user),
      onFailure: (e) => UserState(status: StateStatus.failure, errorMessage: e),
    );
  }
}
```

### Paginated List Cubit
```dart
class BooksCubit extends PaginatedCubit<Book> {
  final BookRepository _repo;
  BooksCubit(this._repo);
  
  @override
  Future<Either<String, List<Book>>> fetchData(int page) {
    return _repo.getBooks(page: page);
  }
}

// Usage
BooksCubit()..loadInitial();
// On scroll end
BooksCubit()..loadMore();
// Pull to refresh
BooksCubit()..refresh();
```

---

**Waxaa sameeyey:** Ardaykaab UI Kit

