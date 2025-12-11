# 🗺️ POLITICAL CANDIDATE MOBILE APP - DEVELOPMENT ROADMAP

> **Project:** Political Candidate Mobile App MVP  
> **Started:** December 2024  
> **Status:** 🚀 In Development

---

## 📋 ROADMAP OVERVIEW

This roadmap is divided into **6 major phases** covering the complete end-to-end development of the Political Candidate Mobile App MVP.

| Phase | Name | Duration | Status |
|-------|------|----------|--------|
| 1 | Foundation & Authentication | Week 1-2 | ⏳ Pending |
| 2 | Core Navigation & Home | Week 2-3 | ⏳ Pending |
| 3 | News & Events Modules | Week 3-4 | ⏳ Pending |
| 4 | Media & Content Modules | Week 4-5 | ⏳ Pending |
| 5 | Engagement Features | Week 5-6 | ⏳ Pending |
| 6 | Polish & Launch Prep | Week 6-7 | ⏳ Pending |

---

## 🔵 PHASE 1: FOUNDATION & AUTHENTICATION (Week 1-2)

### 1.1 Project Setup & Architecture
- [ ] Set up feature-based folder structure
- [ ] Configure dependency injection (get_it)
- [ ] Set up API client with Dio
- [ ] Configure environment variables
- [ ] Set up Firebase project (Auth, Firestore, Storage, FCM)
- [ ] Configure GoRouter navigation

### 1.2 Authentication Data Layer
- [ ] Create User entity and model
- [ ] Create AuthRepository interface
- [ ] Implement Firebase Auth repository
- [ ] Create auth use cases (Login, Register, Logout, ForgotPassword)
- [ ] Set up secure token storage

### 1.3 Authentication UI Screens
- [ ] **Splash Screen** - Logo, brand colors, auto-transition
- [ ] **Welcome/Login Screen** - Social login, email/phone login
- [ ] **Registration Screen** - Full registration form
- [ ] **Verification Choice Screen** - SMS/Email OTP selection
- [ ] **OTP Verification Screen** - 6-digit input, resend functionality
- [ ] **Forgot Password Screen** - Email/SMS reset option
- [ ] **Reset Password Screen** - New password form

### 1.4 Authentication BLoC/Cubit
- [ ] Create AuthBloc for authentication state
- [ ] Create OTPCubit for verification flow
- [ ] Create PasswordResetCubit
- [ ] Implement auth state persistence

### 1.5 Phase 1 Testing & QA
- [ ] Unit tests for auth repository
- [ ] Widget tests for auth screens
- [ ] Integration test for complete auth flow

---

## 🔵 PHASE 2: CORE NAVIGATION & HOME (Week 2-3)

### 2.1 Main Navigation Structure
- [ ] Implement 5-tab bottom navigation (Home, News, Events, Media, More)
- [ ] Configure nested navigation with GoRouter
- [ ] Set up tab persistence
- [ ] Implement deep linking support

### 2.2 Home Data Layer
- [ ] Create News entity/model
- [ ] Create Event entity/model
- [ ] Create HomeRepository
- [ ] Implement dashboard API endpoints

### 2.3 Home Dashboard Screen
- [ ] Personalized greeting section
- [ ] Social media shortcut icons (Facebook, Twitter, Instagram, YouTube)
- [ ] Featured news card (large image)
- [ ] Latest news list preview (horizontal scroll)
- [ ] Upcoming events preview
- [ ] Latest photos/videos preview
- [ ] Real-time update indicators
- [ ] Pull-to-refresh functionality

### 2.4 Home BLoC/Cubit
- [ ] Create HomeCubit for dashboard state
- [ ] Implement real-time data refresh
- [ ] Handle loading/error states

### 2.5 Phase 2 Testing & QA
- [ ] Unit tests for home repository
- [ ] Widget tests for home components
- [ ] Navigation flow testing

---

## 🔵 PHASE 3: NEWS & EVENTS MODULES (Week 3-4)

### 3.1 News Data Layer
- [ ] Create NewsCategory entity
- [ ] Create NewsRepository
- [ ] Implement news API endpoints
- [ ] Set up pagination for news list

### 3.2 News UI Screens
- [ ] **News List Screen** - Cards with image, title, category, timestamp
- [ ] **News Filters** - Category filtering
- [ ] **News Detail Screen** - Full article view
- [ ] Share functionality
- [ ] Related news section

### 3.3 News BLoC/Cubit
- [ ] Create NewsCubit with PaginatedCubit
- [ ] Create NewsDetailCubit
- [ ] Implement category filtering

### 3.4 Events Data Layer
- [ ] Create Event entity/model
- [ ] Create EventRepository
- [ ] Implement events API endpoints
- [ ] Set up event categorization (Upcoming/Past)

### 3.5 Events UI Screens
- [ ] **Events List Screen** - Segmented tabs (Upcoming/Past)
- [ ] **Event Cards** - Date, title, location, thumbnail
- [ ] **Event Detail Screen** - Full event information
- [ ] Map integration (optional)
- [ ] Add to calendar functionality

### 3.6 Events BLoC/Cubit
- [ ] Create EventsCubit
- [ ] Create EventDetailCubit
- [ ] Implement tab filtering

### 3.7 Phase 3 Testing & QA
- [ ] Unit tests for news/events repositories
- [ ] Widget tests for list and detail screens
- [ ] Pagination testing

---

## 🔵 PHASE 4: MEDIA & CONTENT MODULES (Week 4-5)

### 4.1 Media Data Layer
- [ ] Create Photo entity/model
- [ ] Create Video entity/model
- [ ] Create Album entity/model
- [ ] Create MediaRepository
- [ ] Implement media API endpoints

### 4.2 Media UI Screens
- [ ] **Media Home** - Tabs (Photos/Videos)
- [ ] **Photo Gallery** - Grid view with albums
- [ ] **Photo Viewer** - Full screen, swipe, zoom
- [ ] **Video Gallery** - Thumbnails with play button
- [ ] **Video Player** - Full video playback

### 4.3 Media BLoC/Cubit
- [ ] Create PhotoGalleryCubit
- [ ] Create VideoGalleryCubit
- [ ] Create MediaViewerCubit

### 4.4 Timeline (Candidate History)
- [ ] Create TimelineItem entity
- [ ] Create TimelineRepository
- [ ] **Timeline Overview Screen** - Vertical step timeline
- [ ] **Timeline Detail Screen** - Full description with photos
- [ ] Categories (Education, Career, Projects, Achievements)

### 4.5 Programs & Agenda
- [ ] Create Program entity
- [ ] Create ProgramRepository
- [ ] **Programs List Screen** - Categories
- [ ] **Program Detail Screen** - Full program information

### 4.6 Phase 4 Testing & QA
- [ ] Unit tests for media repository
- [ ] Widget tests for gallery and player
- [ ] Media loading performance testing

---

## 🔵 PHASE 5: ENGAGEMENT FEATURES (Week 5-6)

### 5.1 Ask the Candidate Data Layer
- [ ] Create Question entity/model
- [ ] Create QuestionRepository
- [ ] Implement WebSocket for real-time updates
- [ ] Set up upvote system

### 5.2 Ask the Candidate UI Screens
- [ ] **Ask Question Screen** - Text input, submit
- [ ] **Public Questions List** - Question cards with upvotes
- [ ] **Question Detail Screen** - Full Q&A view
- [ ] Status indicators (Pending/Answered/Highlighted)
- [ ] Real-time upvote updates

### 5.3 Ask the Candidate BLoC/Cubit
- [ ] Create QuestionsCubit
- [ ] Create AskQuestionCubit
- [ ] Create QuestionDetailCubit
- [ ] Implement real-time WebSocket handling

### 5.4 Polls Data Layer
- [ ] Create Poll entity/model
- [ ] Create PollRepository
- [ ] Implement voting system
- [ ] Set up real-time results

### 5.5 Polls UI Screens
- [ ] **Poll List Screen** - Active/Completed tabs
- [ ] **Poll Detail Screen** - Vote and view results
- [ ] Real-time results visualization
- [ ] Vote animation

### 5.6 Polls BLoC/Cubit
- [ ] Create PollsCubit
- [ ] Create PollVoteCubit
- [ ] Implement real-time results update

### 5.7 Phase 5 Testing & QA
- [ ] Unit tests for Q&A and polls repositories
- [ ] Real-time functionality testing
- [ ] Upvote/vote system testing

---

## 🔵 PHASE 6: POLISH & LAUNCH PREP (Week 6-7)

### 6.1 Profile & Settings
- [ ] Create UserProfile entity
- [ ] Create ProfileRepository
- [ ] **Profile Screen** - User info display
- [ ] **Edit Profile Screen** - Update information
- [ ] **Change Password Screen**
- [ ] **Settings Screen** - Notifications, language, dark mode
- [ ] **Notification Preferences Screen**

### 6.2 Notifications System
- [ ] Set up Firebase Cloud Messaging
- [ ] Create NotificationRepository
- [ ] **Notification List Screen**
- [ ] Deep link from notifications
- [ ] Notification badges

### 6.3 App-Wide Polish
- [ ] **Error Screens** - 404, No internet, Timeout
- [ ] **Loading States** - Full-page loader, skeleton cards
- [ ] Consistent typography and colors
- [ ] Animation polish
- [ ] Performance optimization

### 6.4 Real-Time Features Polish
- [ ] WebSocket connection indicator
- [ ] Live refresh badges
- [ ] Instant update animations
- [ ] Offline mode handling

### 6.5 Final Testing & QA
- [ ] Full app integration testing
- [ ] Performance testing
- [ ] Security audit
- [ ] Accessibility testing

### 6.6 Launch Preparation
- [ ] App store assets (screenshots, descriptions)
- [ ] Privacy policy and terms
- [ ] Build release versions
- [ ] Play Store / App Store submission

---

## 📊 MILESTONE MARKERS

| Milestone | Target | Deliverable |
|-----------|--------|-------------|
| M1 | End of Phase 1 | Working authentication flow |
| M2 | End of Phase 2 | Complete home dashboard |
| M3 | End of Phase 3 | News & events fully functional |
| M4 | End of Phase 4 | Media & content modules complete |
| M5 | End of Phase 5 | All engagement features working |
| M6 | End of Phase 6 | MVP ready for launch |

---

## 🛠️ TECH STACK SUMMARY

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| State Management | BLoC/Cubit |
| Navigation | GoRouter |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| Real-Time | WebSocket / Firebase Realtime |
| API Client | Dio |
| DI | get_it |
| Local Storage | SharedPreferences, Hive |
| Icons | Iconsax Plus |
| UI | Custom Design System (Existing Kit) |

---

## 📝 NOTES

- Each phase builds on the previous one
- Testing is integrated into each phase
- Real-time features are critical for engagement
- Focus on clean, maintainable architecture
- Leverage existing UI kit components

---

**Last Updated:** 12 . December 2024  
**Next Review:** After Phase 1 completion
