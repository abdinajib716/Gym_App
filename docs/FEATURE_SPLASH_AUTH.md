# 🚀 FEATURE: SPLASH SCREEN & AUTHENTICATION

> **Version:** Mock UI/UX MVP  
> **Status:** 📋 Ready for Implementation  
> **Approach:** Modal Sheets (wolt_modal_sheet) + Placeholder Images

---

## 📋 OVERVIEW

This document outlines the **Splash Screen** and **Authentication** features for the Mock UI/UX MVP. We use:

| Component | Package | Usage |
|-----------|---------|-------|
| **Modal Sheets** | `wolt_modal_sheet` | All auth forms (Login, Register, OTP, etc.) |
| **Toast Messages** | Flutter `SnackBar` | Success/info/warning notifications |
| **Alert Dialogs** | `awesome_dialog` | Confirmation, error, success alerts |
| **Images** | Placeholder | Will replace with real assets later |

---

## 🎯 KEY DESIGN DECISIONS

### ✅ Modal Sheets Instead of Screens

**Why:**
- Better UX with smooth transitions
- User stays in context
- Easy to dismiss with X button
- Modern mobile app pattern
- Reduces navigation complexity

**Implementation:**
- Shared `AppModalSheet` component
- X close button on all sheets
- Different content for different use cases
- Consistent styling across all sheets

### ✅ Feedback System

| Type | Component | When to Use |
|------|-----------|-------------|
| **Toast** | `SnackBar` | Quick feedback (success, info, warning) |
| **Alert** | `AwesomeDialog` | Important actions, confirmations, errors |

---

## 🔵 FEATURE 1: SPLASH SCREEN

### 1.1 Screen Specification

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│           ┌─────────────┐           │
│           │             │           │
│           │    LOGO     │           │
│           │  (Image)    │           │
│           │             │           │
│           └─────────────┘           │
│                                     │
│         [App Name/Tagline]          │
│                                     │
│                                     │
│           ◐ Loading...              │
│                                     │
│                                     │
└─────────────────────────────────────┘
         Brand Color Background
```

### 1.2 UI Components

| Element | Specification |
|---------|---------------|
| **Background** | `AppColors.primaryBlue` (brand color) |
| **Logo** | Placeholder image, centered, ~120x120 |
| **App Name** | Optional tagline, `AppTextStyles.h1`, white |
| **Loader** | `LoadingIndicator` (existing), white color |

### 1.3 Behavior

| Step | Action | Duration |
|------|--------|----------|
| 1 | Show splash with fade-in animation | 300ms |
| 2 | Display logo + loading | 2-3 seconds |
| 3 | Check auth state | - |
| 4a | If authenticated → Navigate to Home | - |
| 4b | If not authenticated → Navigate to Welcome | - |

### 1.4 State Management

```dart
// SplashCubit
States:
  - SplashInitial
  - SplashLoading
  - SplashAuthenticated
  - SplashUnauthenticated
```

### 1.5 File Structure

```
lib/features/splash/
├── presentation/
│   ├── cubit/
│   │   ├── splash_cubit.dart
│   │   └── splash_state.dart
│   └── screens/
│       └── splash_screen.dart
```

### 1.6 Tasks Checklist

- [ ] Create `splash_cubit.dart` with states
- [ ] Create `splash_screen.dart` with UI
- [ ] Add placeholder logo image
- [ ] Implement auto-transition logic
- [ ] Add fade-in animation
- [ ] Connect to router

---

## 🔵 FEATURE 2: AUTHENTICATION

### 2.1 Flow Overview

```
┌──────────────┐
│    Splash    │
└──────┬───────┘
       │ (Not Authenticated)
       ▼
┌──────────────┐
│   Welcome    │◄────────────────────────────────┐
│   Screen     │                                 │
└──────┬───────┘                                 │
       │                                         │
       ├──────────────────────┐                  │
       │                      │                  │
       ▼                      ▼                  │
┌──────────────┐      ┌──────────────┐           │
│ Login Sheet  │      │Register Sheet│           │
│  (Modal)     │      │   (Modal)    │           │
└──────┬───────┘      └──────┬───────┘           │
       │                      │                  │
       │              ┌───────┴───────┐          │
       │              │               │          │
       │              ▼               │          │
       │      ┌──────────────┐        │          │
       │      │Verification  │        │          │
       │      │Choice Sheet  │        │          │
       │      └──────┬───────┘        │          │
       │              │               │          │
       │              ▼               │          │
       │      ┌──────────────┐        │          │
       │      │  OTP Sheet   │        │          │
       │      └──────┬───────┘        │          │
       │              │               │          │
       ├──────────────┴───────────────┤          │
       │                              │          │
       │    ┌──────────────┐          │          │
       ├───►│Forgot Password│         │          │
       │    │    Sheet     │          │          │
       │    └──────┬───────┘          │          │
       │           │                  │          │
       │           ▼                  │          │
       │    ┌──────────────┐          │          │
       │    │ Reset Pass   │          │          │
       │    │    Sheet     │          │          │
       │    └──────────────┘          │          │
       │                              │          │
       ▼                              ▼          │
┌─────────────────────────────────────────┐      │
│              HOME SCREEN                │──────┘
│           (Main App Shell)              │ (Logout)
└─────────────────────────────────────────┘
```

### 2.2 Welcome Screen (Base Screen)

```
┌─────────────────────────────────────┐
│                                     │
│           ┌─────────────┐           │
│           │             │           │
│           │    LOGO     │           │
│           │             │           │
│           └─────────────┘           │
│                                     │
│        Welcome to [App Name]        │
│     Your voice matters in our       │
│           democracy                 │
│                                     │
│  ┌─────────────────────────────┐    │
│  │   🔵  Continue with Google  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │   🔵  Continue with Facebook│    │
│  └─────────────────────────────┘    │
│                                     │
│  ───────────── or ──────────────    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      Sign in with Email     │    │
│  └─────────────────────────────┘    │
│                                     │
│       Don't have an account?        │
│            [Register]               │
│                                     │
└─────────────────────────────────────┘
```

### 2.3 Modal Sheet Specifications

---

#### 2.3.1 Login Sheet

```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║  [X]                          ║  │
│  ║                               ║  │
│  ║         Sign In               ║  │
│  ║   Welcome back! Please        ║  │
│  ║   enter your details          ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 📧 Email or Phone       │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 🔒 Password          👁️ │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║       [Forgot Password?]      ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │       SIGN IN           │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ╚═══════════════════════════════╝  │
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
└─────────────────────────────────────┘
        (Dimmed background)
```

**Fields:**
- Email/Phone input (CustomTextField)
- Password input (obscured, toggle visibility)
- Forgot Password link
- Sign In button (CustomButton)
- X close button (top-left or top-right)

---

#### 2.3.2 Register Sheet

```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║  [X]                          ║  │
│  ║                               ║  │
│  ║       Create Account          ║  │
│  ║   Join us and make your       ║  │
│  ║       voice heard             ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 👤 Full Name            │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 📧 Email                │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 📱 Phone Number         │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 🔒 Password          👁️ │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │      REGISTER           │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ╚═══════════════════════════════╝  │
└─────────────────────────────────────┘
```

**Fields:**
- Full Name input
- Email input
- Phone Number input
- Password input (with visibility toggle)
- Register button

---

#### 2.3.3 Verification Choice Sheet

```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║  [X]                          ║  │
│  ║                               ║  │
│  ║      Verify Your Account      ║  │
│  ║   Choose how you'd like to    ║  │
│  ║     receive your code         ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │  📱  SMS to +1***456    │  ║  │
│  ║  │      ○ Select           │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │  📧  Email to j***@...  │  ║  │
│  ║  │      ○ Select           │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │      SEND CODE          │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ╚═══════════════════════════════╝  │
└─────────────────────────────────────┘
```

**Options:**
- SMS OTP (radio button)
- Email OTP (radio button)
- Send Code button

---

#### 2.3.4 OTP Verification Sheet

```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║  [X]                          ║  │
│  ║                               ║  │
│  ║      Enter Verification       ║  │
│  ║           Code                ║  │
│  ║                               ║  │
│  ║   We sent a code to           ║  │
│  ║   +1 (555) ***-456            ║  │
│  ║                               ║  │
│  ║    ┌───┬───┬───┬───┬───┬───┐  ║  │
│  ║    │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │  ║  │
│  ║    └───┴───┴───┴───┴───┴───┘  ║  │
│  ║                               ║  │
│  ║    Didn't receive code?       ║  │
│  ║    [Resend] (00:59)           ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │        VERIFY           │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ╚═══════════════════════════════╝  │
└─────────────────────────────────────┘
```

**Components:**
- 6-digit OTP input (individual boxes)
- Masked phone/email display
- Resend link with countdown timer
- Verify button

---

#### 2.3.5 Forgot Password Sheet

```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║  [X]                          ║  │
│  ║                               ║  │
│  ║      Forgot Password?         ║  │
│  ║                               ║  │
│  ║   Enter your email or phone   ║  │
│  ║   to receive reset code       ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 📧 Email or Phone       │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │     SEND RESET CODE     │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║    [Back to Login]            ║  │
│  ║                               ║  │
│  ╚═══════════════════════════════╝  │
└─────────────────────────────────────┘
```

---

#### 2.3.6 Reset Password Sheet

```
┌─────────────────────────────────────┐
│  ╔═══════════════════════════════╗  │
│  ║  [X]                          ║  │
│  ║                               ║  │
│  ║      Create New Password      ║  │
│  ║                               ║  │
│  ║   Your new password must be   ║  │
│  ║   different from previous     ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 🔒 New Password      👁️ │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │ 🔒 Confirm Password  👁️ │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ║  ┌─────────────────────────┐  ║  │
│  ║  │     RESET PASSWORD      │  ║  │
│  ║  └─────────────────────────┘  ║  │
│  ║                               ║  │
│  ╚═══════════════════════════════╝  │
└─────────────────────────────────────┘
```

---

## 🧩 SHARED COMPONENTS

### 3.1 AppModalSheet (Shared Component)

```dart
/// Reusable modal sheet wrapper using wolt_modal_sheet
/// 
/// Usage Scenarios:
/// - Login form
/// - Registration form
/// - OTP verification
/// - Forgot password
/// - Any future modal needs
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `title` | `String` | Sheet title |
| `subtitle` | `String?` | Optional subtitle |
| `child` | `Widget` | Content body |
| `showCloseButton` | `bool` | Show X button (default: true) |
| `onClose` | `VoidCallback?` | Close callback |
| `isScrollable` | `bool` | Enable scrolling (default: true) |
| `enableDrag` | `bool` | Enable drag to close (default: true) |

**File Location:**
```
lib/shared/widgets/sheets/
├── app_modal_sheet.dart
├── sheet_header.dart
└── sheets.dart
```

---

### 3.2 AppSnackBar (Toast Messages)

```dart
/// Wrapper for Flutter SnackBar
/// 
/// Types:
/// - success (green)
/// - error (red)
/// - warning (orange)
/// - info (blue)
```

**Usage:**
```dart
AppSnackBar.show(
  context,
  message: 'Login successful!',
  type: SnackBarType.success,
);
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `message` | `String` | Toast message |
| `type` | `SnackBarType` | success, error, warning, info |
| `duration` | `Duration` | Display duration |
| `action` | `SnackBarAction?` | Optional action button |

**File Location:**
```
lib/shared/widgets/feedback/
├── app_snackbar.dart
└── feedback.dart
```

---

### 3.3 AppAlertDialog (Using awesome_dialog)

```dart
/// Wrapper for awesome_dialog
/// 
/// Types:
/// - success
/// - error
/// - warning
/// - info
/// - question (confirmation)
```

**Usage:**
```dart
AppAlertDialog.show(
  context,
  type: AlertType.success,
  title: 'Account Created!',
  message: 'Your account has been created successfully.',
  onOk: () => navigateToHome(),
);

// Confirmation dialog
AppAlertDialog.confirm(
  context,
  title: 'Logout?',
  message: 'Are you sure you want to logout?',
  onConfirm: () => logout(),
  onCancel: () {},
);
```

**File Location:**
```
lib/shared/widgets/feedback/
├── app_alert_dialog.dart
└── feedback.dart
```

---

### 3.4 OTPInputField (Custom Widget)

```dart
/// 6-digit OTP input with individual boxes
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `length` | `int` | Number of digits (default: 6) |
| `onCompleted` | `Function(String)` | Called when all digits entered |
| `onChanged` | `Function(String)` | Called on each change |
| `autoFocus` | `bool` | Auto-focus first field |

**File Location:**
```
lib/features/auth/presentation/widgets/
├── otp_input_field.dart
└── auth_widgets.dart
```

---

## 📁 FILE STRUCTURE

```
lib/
├── features/
│   │
│   ├── splash/
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── splash_cubit.dart
│   │       │   └── splash_state.dart
│   │       └── screens/
│   │           └── splash_screen.dart
│   │
│   └── auth/
│       ├── data/
│       │   └── repositories/
│       │       └── mock_auth_repository.dart  # Mock for UI MVP
│       │
│       ├── domain/
│       │   └── entities/
│       │       └── user.dart
│       │
│       └── presentation/
│           ├── cubit/
│           │   ├── auth_cubit.dart
│           │   ├── auth_state.dart
│           │   ├── otp_cubit.dart
│           │   └── otp_state.dart
│           │
│           ├── screens/
│           │   └── welcome_screen.dart
│           │
│           ├── sheets/                    # Modal sheet contents
│           │   ├── login_sheet_content.dart
│           │   ├── register_sheet_content.dart
│           │   ├── verification_choice_sheet_content.dart
│           │   ├── otp_sheet_content.dart
│           │   ├── forgot_password_sheet_content.dart
│           │   └── reset_password_sheet_content.dart
│           │
│           └── widgets/
│               ├── social_login_buttons.dart
│               ├── otp_input_field.dart
│               └── auth_widgets.dart
│
└── shared/
    └── widgets/
        ├── sheets/                        # 🆕 NEW
        │   ├── app_modal_sheet.dart
        │   ├── sheet_header.dart
        │   └── sheets.dart
        │
        └── feedback/                      # 🆕 NEW
            ├── app_snackbar.dart
            ├── app_alert_dialog.dart
            └── feedback.dart
```

---

## 🔄 STATE MANAGEMENT

### SplashCubit

```dart
// States
abstract class SplashState {}
class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashAuthenticated extends SplashState {}
class SplashUnauthenticated extends SplashState {}

// Cubit
class SplashCubit extends Cubit<SplashState> {
  Future<void> checkAuthStatus();
}
```

### AuthCubit

```dart
// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState { final User user; }
class AuthFailure extends AuthState { final String message; }
class AuthLoggedOut extends AuthState {}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String phone, String password);
  Future<void> loginWithGoogle();
  Future<void> loginWithFacebook();
  Future<void> logout();
  Future<void> forgotPassword(String emailOrPhone);
  Future<void> resetPassword(String newPassword);
}
```

### OTPCubit

```dart
// States
abstract class OTPState {}
class OTPInitial extends OTPState {}
class OTPSending extends OTPState {}
class OTPSent extends OTPState { final String maskedDestination; }
class OTPVerifying extends OTPState {}
class OTPVerified extends OTPState {}
class OTPFailure extends OTPState { final String message; }
class OTPResendAvailable extends OTPState {}

// Cubit
class OTPCubit extends Cubit<OTPState> {
  Future<void> sendOTP(OTPMethod method);
  Future<void> verifyOTP(String code);
  Future<void> resendOTP();
  void startResendTimer();
}
```

---

## ✅ IMPLEMENTATION CHECKLIST

### Shared Components
- [ ] Create `lib/shared/widgets/sheets/app_modal_sheet.dart`
- [ ] Create `lib/shared/widgets/sheets/sheet_header.dart`
- [ ] Create `lib/shared/widgets/feedback/app_snackbar.dart`
- [ ] Create `lib/shared/widgets/feedback/app_alert_dialog.dart`

### Splash Screen
- [ ] Create `splash_cubit.dart` with states
- [ ] Create `splash_screen.dart` UI
- [ ] Add placeholder logo to assets
- [ ] Implement fade-in animation
- [ ] Implement auto-transition logic

### Auth - Welcome Screen
- [ ] Create `welcome_screen.dart`
- [ ] Create `social_login_buttons.dart`
- [ ] Style according to design

### Auth - Modal Sheets
- [ ] Create `login_sheet_content.dart`
- [ ] Create `register_sheet_content.dart`
- [ ] Create `verification_choice_sheet_content.dart`
- [ ] Create `otp_sheet_content.dart`
- [ ] Create `otp_input_field.dart` widget
- [ ] Create `forgot_password_sheet_content.dart`
- [ ] Create `reset_password_sheet_content.dart`

### Auth - State Management
- [ ] Create `auth_cubit.dart`
- [ ] Create `otp_cubit.dart`
- [ ] Create mock repository for UI testing

### Navigation
- [ ] Set up GoRouter with splash → welcome flow
- [ ] Configure modal sheet navigation

---

## 📝 MOCK DATA

For UI MVP, we use mock delays and responses:

```dart
// Mock delay to simulate API calls
await Future.delayed(Duration(seconds: 2));

// Mock success/failure for testing UI states
bool mockSuccess = true; // Toggle for testing

// Mock user data
final mockUser = User(
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  avatar: null, // Placeholder
);
```

---

## 🎨 DESIGN TOKENS

Using existing design system:

```dart
// Colors
AppColors.primaryBlue      // Primary actions
AppColors.textPrimary      // Main text
AppColors.textSecondary    // Subtitle text
AppColors.background       // Sheet background
AppColors.success          // Success states
AppColors.error            // Error states
AppColors.warning          // Warning states

// Typography
AppTextStyles.h1           // Main titles
AppTextStyles.h2           // Sheet titles
AppTextStyles.bodyLarge    // Body text
AppTextStyles.bodyMedium   // Input labels
AppTextStyles.button       // Button text

// Spacing
DesignTokens.screenPadding // 16.0
DesignTokens.cardPadding   // 16.0
DesignTokens.spacingMd     // 16.0
DesignTokens.spacingLg     // 24.0
```

---

**Last Updated:** December 2024  
**Ready for Implementation:** ✅
