# 📱 POLITICAL CANDIDATE APP - APPLICATION OVERVIEW

> **Project:** Political Candidate Mobile App MVP  
> **Framework:** Flutter 3.x  
> **Architecture:** Clean Architecture + BLoC/Cubit

---

## 🎯 APPLICATION SUMMARY

A comprehensive political candidate mobile application designed to:
- **Engage** voters through polls, Q&A, and real-time updates
- **Inform** users about news, events, and candidate programs
- **Connect** supporters via media galleries and social integration
- **Mobilize** campaign efforts through notifications and event management

---

## 🏗️ ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Screens   │  │   Widgets   │  │   BLoC/Cubit (State)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                         DOMAIN LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │  Repository Interfaces  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                          DATA LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Models    │  │ Data Sources│  │  Repository Impl        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                          CORE LAYER                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │ Constants│ │  Theme   │ │ Network  │ │   BLoC   │ │ Utils  │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 FULL DIRECTORY STRUCTURE

```
xisbi_app/
│
├── 📁 android/                          # Android platform files
├── 📁 ios/                              # iOS platform files
├── 📁 web/                              # Web platform files
├── 📁 linux/                            # Linux platform files
├── 📁 macos/                            # macOS platform files
│
├── 📁 assets/
│   ├── 📁 fonts/
│   │   ├── Poppins-Regular.ttf
│   │   ├── Poppins-Medium.ttf
│   │   ├── Poppins-SemiBold.ttf
│   │   └── Poppins-Bold.ttf
│   ├── 📁 icons/                        # App icons (SVG/PNG)
│   │   ├── app_logo.svg
│   │   ├── social/
│   │   │   ├── facebook.svg
│   │   │   ├── twitter.svg
│   │   │   ├── instagram.svg
│   │   │   └── youtube.svg
│   │   └── ...
│   └── 📁 images/                       # Static images
│       ├── splash_bg.png
│       ├── placeholder.png
│       └── ...
│
├── 📁 docs/                             # Documentation [NEW]
│   ├── ROADMAP.md
│   ├── FEATURES_TRACKER.md
│   └── APP_OVERVIEW.md
│
├── 📁 lib/
│   │
│   ├── 📄 main.dart                     # App entry point
│   │
│   ├── 📁 core/                         # ✅ EXISTING - Core utilities
│   │   │
│   │   ├── 📄 core.dart                 # Core exports
│   │   │
│   │   ├── 📁 constants/                # ✅ EXISTING
│   │   │   ├── app_colors.dart          # Color palette (Light + Dark)
│   │   │   ├── app_text_styles.dart     # Typography (Poppins)
│   │   │   └── app_constants.dart       # Spacing, Radius, Shadows
│   │   │
│   │   ├── 📁 theme/                    # ✅ EXISTING
│   │   │   ├── app_theme.dart           # Light/Dark ThemeData
│   │   │   ├── theme_provider.dart      # Theme state management
│   │   │   └── theme.dart               # Theme exports
│   │   │
│   │   ├── 📁 network/                  # ✅ EXISTING
│   │   │   ├── network_info.dart        # Network connectivity service
│   │   │   ├── connectivity_cubit.dart  # Connectivity state
│   │   │   └── network.dart             # Network exports
│   │   │
│   │   ├── 📁 bloc/                     # ✅ EXISTING
│   │   │   ├── base_state.dart          # Base states
│   │   │   ├── base_cubit.dart          # Base Cubit
│   │   │   ├── base_bloc.dart           # Base BLoC
│   │   │   └── bloc.dart                # BLoC exports
│   │   │
│   │   ├── 📁 api/                      # 🆕 NEW - API Client
│   │   │   ├── api_client.dart          # Dio HTTP client
│   │   │   ├── api_endpoints.dart       # API endpoint constants
│   │   │   ├── api_interceptors.dart    # Auth, logging interceptors
│   │   │   ├── api_exceptions.dart      # Custom exceptions
│   │   │   └── api.dart                 # API exports
│   │   │
│   │   ├── 📁 di/                       # 🆕 NEW - Dependency Injection
│   │   │   ├── injection_container.dart # get_it setup
│   │   │   └── di.dart                  # DI exports
│   │   │
│   │   ├── 📁 router/                   # 🆕 NEW - Navigation
│   │   │   ├── app_router.dart          # GoRouter configuration
│   │   │   ├── route_names.dart         # Route name constants
│   │   │   ├── route_guards.dart        # Auth guards
│   │   │   └── router.dart              # Router exports
│   │   │
│   │   ├── 📁 storage/                  # 🆕 NEW - Local Storage
│   │   │   ├── secure_storage.dart      # Secure token storage
│   │   │   ├── local_storage.dart       # SharedPreferences wrapper
│   │   │   └── storage.dart             # Storage exports
│   │   │
│   │   ├── 📁 utils/                    # 🆕 NEW - Utilities
│   │   │   ├── validators.dart          # Form validators
│   │   │   ├── date_formatter.dart      # Date formatting
│   │   │   ├── string_extensions.dart   # String extensions
│   │   │   └── utils.dart               # Utils exports
│   │   │
│   │   └── 📁 websocket/                # 🆕 NEW - Real-time
│   │       ├── websocket_client.dart    # WebSocket connection
│   │       ├── websocket_events.dart    # Event types
│   │       └── websocket.dart           # WebSocket exports
│   │
│   ├── 📁 shared/                       # ✅ EXISTING - Shared components
│   │   │
│   │   ├── 📁 widgets/                  # ✅ EXISTING
│   │   │   │
│   │   │   ├── 📄 widgets.dart          # Widget exports
│   │   │   │
│   │   │   ├── 📁 common/               # ✅ EXISTING
│   │   │   │   ├── bottom_nav_bar.dart
│   │   │   │   ├── connectivity_status_widget.dart
│   │   │   │   ├── custom_app_bar.dart
│   │   │   │   ├── custom_button.dart
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   ├── empty_state.dart
│   │   │   │   ├── error_view.dart
│   │   │   │   └── loading_indicator.dart
│   │   │   │
│   │   │   ├── 📁 cards/                # 🆕 NEW - Card widgets
│   │   │   │   ├── news_card.dart
│   │   │   │   ├── event_card.dart
│   │   │   │   ├── poll_card.dart
│   │   │   │   ├── question_card.dart
│   │   │   │   ├── media_card.dart
│   │   │   │   └── cards.dart
│   │   │   │
│   │   │   ├── 📁 skeletons/            # 🆕 NEW - Skeleton loaders
│   │   │   │   ├── news_skeleton.dart
│   │   │   │   ├── event_skeleton.dart
│   │   │   │   ├── card_skeleton.dart
│   │   │   │   └── skeletons.dart
│   │   │   │
│   │   │   └── 📁 dialogs/              # 🆕 NEW - Dialog widgets
│   │   │       ├── confirm_dialog.dart
│   │   │       ├── success_dialog.dart
│   │   │       ├── error_dialog.dart
│   │   │       └── dialogs.dart
│   │   │
│   │   └── 📁 extensions/               # 🆕 NEW - Extensions
│   │       ├── context_extensions.dart
│   │       ├── datetime_extensions.dart
│   │       └── extensions.dart
│   │
│   └── 📁 features/                     # 🆕 NEW - Feature modules
│       │
│       ├── 📁 auth/                     # Authentication Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   ├── auth_remote_datasource.dart
│       │   │   │   └── auth_local_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── user_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── auth_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── user.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       ├── login_usecase.dart
│       │   │       ├── register_usecase.dart
│       │   │       ├── logout_usecase.dart
│       │   │       ├── verify_otp_usecase.dart
│       │   │       └── forgot_password_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 bloc/
│       │       │   ├── auth_bloc.dart
│       │       │   ├── auth_event.dart
│       │       │   ├── auth_state.dart
│       │       │   └── otp_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── splash_screen.dart
│       │       │   ├── welcome_screen.dart
│       │       │   ├── login_screen.dart
│       │       │   ├── register_screen.dart
│       │       │   ├── verification_choice_screen.dart
│       │       │   ├── otp_screen.dart
│       │       │   ├── forgot_password_screen.dart
│       │       │   └── reset_password_screen.dart
│       │       └── 📁 widgets/
│       │           ├── social_login_buttons.dart
│       │           ├── otp_input_field.dart
│       │           └── auth_widgets.dart
│       │
│       ├── 📁 home/                     # Home Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── home_remote_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── dashboard_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── home_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── dashboard.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── home_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       └── get_dashboard_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   ├── home_cubit.dart
│       │       │   └── home_state.dart
│       │       ├── 📁 screens/
│       │       │   └── home_screen.dart
│       │       └── 📁 widgets/
│       │           ├── greeting_section.dart
│       │           ├── social_shortcuts.dart
│       │           ├── featured_news_card.dart
│       │           ├── news_preview_list.dart
│       │           ├── events_preview.dart
│       │           └── home_widgets.dart
│       │
│       ├── 📁 news/                     # News Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── news_remote_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   ├── news_model.dart
│       │   │   │   └── news_category_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── news_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   ├── news.dart
│       │   │   │   └── news_category.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── news_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       ├── get_news_list_usecase.dart
│       │   │       └── get_news_detail_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   ├── news_cubit.dart
│       │       │   └── news_detail_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── news_list_screen.dart
│       │       │   └── news_detail_screen.dart
│       │       └── 📁 widgets/
│       │           ├── news_filter_chips.dart
│       │           └── news_widgets.dart
│       │
│       ├── 📁 events/                   # Events Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── events_remote_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── event_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── events_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── event.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── events_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       ├── get_events_list_usecase.dart
│       │   │       └── get_event_detail_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   ├── events_cubit.dart
│       │       │   └── event_detail_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── events_list_screen.dart
│       │       │   └── event_detail_screen.dart
│       │       └── 📁 widgets/
│       │           ├── events_tabs.dart
│       │           └── events_widgets.dart
│       │
│       ├── 📁 media/                    # Media Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── media_remote_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   ├── photo_model.dart
│       │   │   │   ├── video_model.dart
│       │   │   │   └── album_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── media_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   ├── photo.dart
│       │   │   │   ├── video.dart
│       │   │   │   └── album.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── media_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       ├── get_photos_usecase.dart
│       │   │       └── get_videos_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   ├── photo_gallery_cubit.dart
│       │       │   └── video_gallery_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── media_home_screen.dart
│       │       │   ├── photo_gallery_screen.dart
│       │       │   ├── photo_viewer_screen.dart
│       │       │   ├── video_gallery_screen.dart
│       │       │   └── video_player_screen.dart
│       │       └── 📁 widgets/
│       │           ├── media_tabs.dart
│       │           ├── photo_grid.dart
│       │           ├── video_thumbnail.dart
│       │           └── media_widgets.dart
│       │
│       ├── 📁 timeline/                 # Timeline Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── timeline_remote_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── timeline_item_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── timeline_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── timeline_item.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── timeline_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       └── get_timeline_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   └── timeline_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── timeline_screen.dart
│       │       │   └── timeline_detail_screen.dart
│       │       └── 📁 widgets/
│       │           ├── timeline_step.dart
│       │           └── timeline_widgets.dart
│       │
│       ├── 📁 programs/                 # Programs Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── programs_remote_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── program_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── programs_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── program.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── programs_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       └── get_programs_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   └── programs_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── programs_list_screen.dart
│       │       │   └── program_detail_screen.dart
│       │       └── 📁 widgets/
│       │           └── programs_widgets.dart
│       │
│       ├── 📁 questions/                # Ask Candidate Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   ├── questions_remote_datasource.dart
│       │   │   │   └── questions_websocket_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── question_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── questions_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── question.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── questions_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       ├── get_questions_usecase.dart
│       │   │       ├── ask_question_usecase.dart
│       │   │       └── upvote_question_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   ├── questions_cubit.dart
│       │       │   └── ask_question_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── questions_list_screen.dart
│       │       │   ├── question_detail_screen.dart
│       │       │   └── ask_question_screen.dart
│       │       └── 📁 widgets/
│       │           ├── question_status_badge.dart
│       │           ├── upvote_button.dart
│       │           └── questions_widgets.dart
│       │
│       ├── 📁 polls/                    # Polls Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   ├── polls_remote_datasource.dart
│       │   │   │   └── polls_websocket_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   ├── poll_model.dart
│       │   │   │   └── poll_option_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── polls_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   ├── poll.dart
│       │   │   │   └── poll_option.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── polls_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       ├── get_polls_usecase.dart
│       │   │       └── vote_poll_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   ├── polls_cubit.dart
│       │       │   └── poll_vote_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── polls_list_screen.dart
│       │       │   └── poll_detail_screen.dart
│       │       └── 📁 widgets/
│       │           ├── poll_option_tile.dart
│       │           ├── poll_results_chart.dart
│       │           └── polls_widgets.dart
│       │
│       ├── 📁 profile/                  # Profile Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── profile_remote_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── user_profile_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── profile_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── user_profile.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── profile_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       ├── get_profile_usecase.dart
│       │   │       ├── update_profile_usecase.dart
│       │   │       └── change_password_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   ├── profile_cubit.dart
│       │       │   └── edit_profile_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── profile_screen.dart
│       │       │   ├── edit_profile_screen.dart
│       │       │   └── change_password_screen.dart
│       │       └── 📁 widgets/
│       │           └── profile_widgets.dart
│       │
│       ├── 📁 settings/                 # Settings Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   └── settings_local_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── settings_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── settings_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── settings.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── settings_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       └── update_settings_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   └── settings_cubit.dart
│       │       ├── 📁 screens/
│       │       │   ├── settings_screen.dart
│       │       │   └── notification_preferences_screen.dart
│       │       └── 📁 widgets/
│       │           └── settings_widgets.dart
│       │
│       ├── 📁 notifications/            # Notifications Module
│       │   ├── 📁 data/
│       │   │   ├── 📁 datasources/
│       │   │   │   ├── notifications_remote_datasource.dart
│       │   │   │   └── fcm_datasource.dart
│       │   │   ├── 📁 models/
│       │   │   │   └── notification_model.dart
│       │   │   └── 📁 repositories/
│       │   │       └── notifications_repository_impl.dart
│       │   ├── 📁 domain/
│       │   │   ├── 📁 entities/
│       │   │   │   └── app_notification.dart
│       │   │   ├── 📁 repositories/
│       │   │   │   └── notifications_repository.dart
│       │   │   └── 📁 usecases/
│       │   │       └── get_notifications_usecase.dart
│       │   └── 📁 presentation/
│       │       ├── 📁 cubit/
│       │       │   └── notifications_cubit.dart
│       │       ├── 📁 screens/
│       │       │   └── notifications_screen.dart
│       │       └── 📁 widgets/
│       │           └── notifications_widgets.dart
│       │
│       └── 📁 more/                     # More Tab Module
│           └── 📁 presentation/
│               └── 📁 screens/
│                   └── more_screen.dart
│
├── 📄 pubspec.yaml                      # Dependencies
├── 📄 pubspec.lock                      # Lock file
├── 📄 analysis_options.yaml             # Lint rules
├── 📄 README.md                         # Project README
└── 📄 .gitignore                        # Git ignore
```

---

## 🎨 SCREEN FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              APP LAUNCH                                  │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                         ┌──────────────────┐
                         │   SPLASH SCREEN   │
                         └──────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
            (Not Authenticated)              (Authenticated)
                    │                               │
                    ▼                               ▼
         ┌──────────────────┐            ┌──────────────────┐
         │  WELCOME/LOGIN   │            │   MAIN SHELL     │
         └──────────────────┘            │  (Bottom Tabs)   │
                    │                    └──────────────────┘
         ┌──────────┴──────────┐                 │
         │                     │     ┌───────────┼───────────┬───────────┬───────────┐
         ▼                     ▼     │           │           │           │           │
  ┌──────────────┐    ┌──────────────┐▼           ▼           ▼           ▼           ▼
  │   REGISTER   │    │FORGOT PASSWD │┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐
  └──────────────┘    └──────────────┘│  HOME  ││  NEWS  ││ EVENTS ││ MEDIA  ││  MORE  │
         │                     │      └────────┘└────────┘└────────┘└────────┘└────────┘
         ▼                     │           │         │         │         │         │
  ┌──────────────┐             │           │         │         │         │         │
  │VERIFICATION  │             │           │         │         │         │         │
  │   CHOICE     │             │           │         │         │         │    ┌────┴────┐
  └──────────────┘             │           │         │         │         │    │         │
         │                     │           │         │         │         │    ▼         │
         ▼                     │           │         │         │         │ ┌─────────┐  │
  ┌──────────────┐             │           │         │         │         │ │ Profile │  │
  │  OTP SCREEN  │             │           │         │         │         │ │Timeline │  │
  └──────────────┘             │           │         │         │         │ │Programs │  │
         │                     ▼           │         │         │         │ │Questions│  │
         │            ┌──────────────┐     │         │         │         │ │  Polls  │  │
         │            │RESET PASSWORD│     │         │         │         │ │Settings │  │
         │            └──────────────┘     │         │         │         │ └─────────┘  │
         │                     │           │         │         │         │              │
         └─────────────────────┴───────────┴─────────┴─────────┴─────────┴──────────────┘
                                                    │
                                                    ▼
                                        ┌──────────────────┐
                                        │  NOTIFICATIONS   │
                                        │    (Overlay)     │
                                        └──────────────────┘
```

---

## 📦 DEPENDENCIES (Updated pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # ✅ EXISTING - State Management
  flutter_bloc: ^9.1.1
  equatable: ^2.0.5
  dartz: ^0.10.1
  
  # ✅ EXISTING - Network & Connectivity
  connectivity_plus: ^7.0.0
  internet_connection_checker: ^1.0.0+1
  
  # ✅ EXISTING - Navigation
  go_router: ^13.0.0
  
  # ✅ EXISTING - Storage
  shared_preferences: ^2.5.3
  
  # ✅ EXISTING - UI Components
  shimmer: ^3.0.0
  awesome_dialog: ^3.3.0
  wolt_modal_sheet: ^0.11.0
  
  # ✅ EXISTING - Icons
  cupertino_icons: ^1.0.2
  iconsax_plus: ^1.0.0

  # 🆕 NEW - HTTP Client
  dio: ^5.4.0
  
  # 🆕 NEW - Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # 🆕 NEW - Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.9
  
  # 🆕 NEW - Social Auth
  google_sign_in: ^6.2.1
  flutter_facebook_auth: ^6.1.1
  
  # 🆕 NEW - Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # 🆕 NEW - Image/Video
  cached_network_image: ^3.3.1
  photo_view: ^0.14.0
  video_player: ^2.8.2
  chewie: ^1.7.4
  
  # 🆕 NEW - WebSocket
  web_socket_channel: ^2.4.0
  
  # 🆕 NEW - Utilities
  intl: ^0.18.1
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  
  # 🆕 NEW - Calendar
  add_2_calendar: ^3.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # 🆕 NEW - Code Generation
  build_runner: ^2.4.8
  injectable_generator: ^2.4.1
  json_serializable: ^6.7.1
```

---

## 🔌 INTEGRATION POINTS

### Existing Components to Leverage

| Component | Location | Usage |
|-----------|----------|-------|
| `AppColors` | `core/constants/` | All screens |
| `AppTextStyles` | `core/constants/` | All text |
| `DesignTokens` | `core/constants/` | Spacing, radius |
| `AppTheme` | `core/theme/` | Light/Dark themes |
| `ThemeProvider` | `core/theme/` | Theme toggling |
| `ConnectivityCubit` | `core/network/` | Offline handling |
| `BaseBloc` | `core/bloc/` | All BLoCs |
| `BaseCubit` | `core/bloc/` | All Cubits |
| `PaginatedCubit` | `core/bloc/` | Lists with pagination |
| `CustomButton` | `shared/widgets/` | All buttons |
| `CustomTextField` | `shared/widgets/` | All inputs |
| `CustomAppBar` | `shared/widgets/` | All app bars |
| `BottomNavBar` | `shared/widgets/` | Main navigation |
| `LoadingIndicator` | `shared/widgets/` | Loading states |
| `EmptyState` | `shared/widgets/` | Empty views |
| `ErrorView` | `shared/widgets/` | Error states |
| `ConnectivityStatusWidget` | `shared/widgets/` | Offline banner |

---

## 📝 NOTES

- **Existing Kit**: All existing `core/` and `shared/` components will be reused
- **Feature Modules**: Each feature follows clean architecture pattern
- **State Management**: BLoC for complex logic, Cubit for simple UI state
- **Real-Time**: WebSocket for Q&A upvotes and poll results
- **Offline Support**: Leveraging existing connectivity infrastructure

---

**Last Updated:** December 2024  
**Architecture:** Clean Architecture + BLoC/Cubit  
**Platform:** Flutter 3.x (Android, iOS)
