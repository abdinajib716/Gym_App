# Mobile App Integration Task List

Created: 2026-06-14
Backend base URL: `https://gym.mrk.so`

## Status Legend

- [ ] Not started
- [~] In progress
- [x] Complete

## Integration Goal

Build the Flutter starter into the Gym mobile app and connect it end to end with the existing backend mobile APIs.

The mobile app must support both member and trainer roles, use `/api/mobile/*` routes only, and keep admin `/api/v1/*` routes out of the client app.

## Guardrails

- [ ] Do not rebuild the backend admin system from the Flutter app.
- [ ] Do not use admin `/api/v1/*` routes in the mobile client.
- [ ] Use mobile Bearer token auth returned by `POST /api/mobile/auth/login`.
- [ ] Store mobile auth token securely on device.
- [ ] Keep member data self-scoped to the logged-in member.
- [ ] Keep trainer data scoped to the logged-in trainer and assigned members only.
- [ ] Do not expose password hashes, admin IDs, Access Control data, or secret config values.
- [ ] Show safe API error messages in the app.
- [ ] Support offline/loading/empty/error UI states using the existing template widgets.

## Phase 1: Backend Connection Setup

- [x] Confirm backend base URL: `https://gym.mrk.so`.
- [x] Add environment/config support for API base URL.
- [x] Add HTTP client package if needed.
- [x] Add secure token storage package.
- [x] Add API client wrapper with base URL, JSON headers, Bearer token injection, and timeout handling.
- [x] Add API error parser for `{ "error": "Message" }` responses.
- [x] Add network connectivity handling into API flows.
- [ ] Add logging hooks for development without exposing tokens.

## Phase 2: App Architecture

- [x] Replace demo starter screen with real app shell.
- [x] Create feature folder structure for auth, member, trainer, payments, notifications, and shared API models.
- [x] Define shared response models for success/error payloads.
- [x] Define shared mobile account model with `accountId`, `role`, `accountStatus`, and `mustChangePassword`.
- [x] Add app router/navigation flow.
- [x] Add authenticated route guard.
- [x] Add role-based navigation after login.
- [x] Add persisted session restore on app start.
- [x] Add logout flow that clears local token and session state.

## Phase 3: Shared Mobile Auth

- [x] Implement `POST /api/mobile/auth/login`.
- [x] Support login by phone or email.
- [x] Normalize phone input for `061...`, `61...`, and `25261...` formats where useful on the client.
- [x] Persist returned token securely.
- [x] Persist safe user profile locally.
- [x] Implement `GET /api/mobile/auth/me`.
- [x] Implement `POST /api/mobile/auth/logout`.
- [x] Implement forgot password screen with `POST /api/mobile/auth/forgot-password`.
- [x] Implement reset password screen with `POST /api/mobile/auth/reset-password`.
- [x] Add `mustChangePassword` handling after login.
- [x] Add disabled/suspended login error handling.

## Phase 4: Member Mobile API Client

- [x] Implement `GET /api/mobile/member/dashboard`.
- [x] Implement `GET /api/mobile/member/subscription/current`.
- [x] Implement `GET /api/mobile/member/subscription/history`.
- [x] Implement `GET /api/mobile/member/plans`.
- [x] Implement `POST /api/mobile/member/subscription/upgrade`.
- [x] Implement `POST /api/mobile/member/subscription/renew`.
- [x] Implement `POST /api/mobile/member/payments/waafi/initiate`.
- [x] Implement `GET /api/mobile/member/payments/waafi/status/:paymentId`.
- [x] Implement `GET /api/mobile/member/payments/history`.
- [x] Implement `GET /api/mobile/member/notifications`.
- [x] Implement `PATCH /api/mobile/member/notifications/:notificationId/read`.
- [x] Implement `PATCH /api/mobile/member/notifications/mark-all-read`.
- [x] Implement `DELETE /api/mobile/member/notifications/:notificationId`.
- [ ] Implement `POST /api/mobile/device-tokens`.
- [ ] Implement `DELETE /api/mobile/device-tokens`.

## Phase 5: Member Mobile Screens

- [x] Member dashboard screen with profile summary, subscription status, payments, and notifications.
- [x] Current subscription detail screen.
- [x] Subscription history screen.
- [x] Plans list screen.
- [x] Upgrade subscription flow.
- [x] Renew subscription flow.
- [x] Waafi payment initiation screen with provider, phone, amount, and validation.
- [x] Waafi payment status screen with pending/success/failed states.
- [x] Payment history screen.
- [x] Notifications list screen.
- [x] Mark notification read interaction.
- [x] Mark all notifications read action.
- [x] Delete notification action.
- [ ] Device token registration hook after login when push setup is available.

## Phase 6: Trainer Mobile API Contract Planning

- [ ] Confirm trainer backend endpoints are implemented or still pending.
- [ ] If pending, create trainer API contract before client implementation.
- [ ] Define trainer dashboard response shape.
- [ ] Define assigned members list response shape.
- [ ] Define assigned member detail response shape.
- [ ] Define trainer-safe subscription response shape without payment details.
- [ ] Define trainer schedule response shape.
- [ ] Define trainer workout, exercise, assignment, and progress note response shapes.
- [ ] Define trainer notification response shape.
- [ ] Define authorization rules for assigned members and trainer-owned workouts.

## Phase 7: Trainer Mobile API Client

- [ ] Implement `GET /api/mobile/trainer/dashboard`.
- [ ] Implement `GET /api/mobile/trainer/members`.
- [ ] Implement `GET /api/mobile/trainer/members/:memberId`.
- [ ] Implement `GET /api/mobile/trainer/members/:memberId/subscription`.
- [ ] Implement `GET /api/mobile/trainer/schedule/today`.
- [ ] Implement `GET /api/mobile/trainer/schedule`.
- [ ] Implement `GET /api/mobile/trainer/workouts`.
- [ ] Implement `POST /api/mobile/trainer/workouts`.
- [ ] Implement `GET /api/mobile/trainer/workouts/:workoutId`.
- [ ] Implement `PUT /api/mobile/trainer/workouts/:workoutId`.
- [ ] Implement `DELETE /api/mobile/trainer/workouts/:workoutId`.
- [ ] Implement `POST /api/mobile/trainer/workouts/:workoutId/assign-member`.
- [ ] Implement `GET /api/mobile/trainer/members/:memberId/workouts`.
- [ ] Implement `POST /api/mobile/trainer/members/:memberId/progress-note`.
- [ ] Implement `GET /api/mobile/trainer/members/:memberId/attendance`.
- [ ] Implement `GET /api/mobile/trainer/notifications`.
- [ ] Implement `PATCH /api/mobile/trainer/notifications/:notificationId/read`.

## Phase 8: Trainer Mobile Screens

- [ ] Trainer dashboard screen.
- [ ] Assigned members list screen.
- [ ] Assigned member detail screen.
- [ ] Member subscription summary screen without payment details.
- [ ] Today schedule screen.
- [ ] Full schedule screen.
- [ ] Workouts list screen.
- [ ] Create workout flow.
- [ ] Edit workout flow.
- [ ] Workout detail screen.
- [ ] Assign workout to member flow.
- [ ] Member workouts screen.
- [ ] Add progress note flow.
- [ ] Member attendance screen.
- [ ] Trainer notifications screen.
- [ ] Mark trainer notification read interaction.

## Phase 9: UI Foundation and Polish

- [ ] Define app theme for member/trainer mobile experience using existing Poppins assets.
- [ ] Replace generic template colors if needed for gym brand direction.
- [ ] Build reusable authenticated app scaffold.
- [ ] Build role-aware bottom navigation.
- [ ] Build reusable cards for subscription, payment, notification, plan, member, and workout data.
- [ ] Build skeleton loaders using existing `LoadingIndicator` and shimmer widgets.
- [ ] Build empty states for each feature.
- [ ] Build retryable error states.
- [ ] Ensure responsive layouts on small Android devices and larger phones.
- [ ] Ensure text does not overflow in cards, buttons, or tabs.

## Phase 10: Push Notifications

- [ ] Add Firebase client packages if mobile push is in scope for this phase.
- [ ] Configure Android Firebase files.
- [ ] Configure iOS Firebase files if building iOS now.
- [ ] Request notification permissions.
- [ ] Register FCM token through `POST /api/mobile/device-tokens`.
- [ ] Remove FCM token on logout through `DELETE /api/mobile/device-tokens`.
- [ ] Handle foreground notifications.
- [ ] Handle notification taps into the relevant screen.

## Phase 11: Payment UX Verification

- [ ] Validate Somalia phone number before Waafi initiation.
- [ ] Show clear pending customer prompt state after Waafi initiation.
- [ ] Poll payment status using the status endpoint.
- [ ] Stop polling after success, failure, timeout, or user cancellation.
- [ ] Refresh subscription and payment history after payment status changes.
- [ ] Show Waafi `responseMessage` and failure reason when returned.
- [ ] Confirm successful payment activates subscription in the app view.

## Phase 12: Smoke Testing

- [ ] Login as member using smoke credentials.
- [ ] Member dashboard loads.
- [ ] Current subscription loads.
- [ ] Subscription history loads.
- [ ] Plans load.
- [ ] Upgrade creates pending subscription.
- [ ] Renew creates pending subscription.
- [ ] Payment history loads.
- [ ] Waafi invalid phone returns clean validation error.
- [ ] Waafi status endpoint returns only logged-in member payment.
- [ ] Notifications load.
- [ ] Mark notification read works.
- [ ] Mark all notifications read works.
- [ ] Delete notification works.
- [ ] Logout clears token and blocks protected screens.
- [ ] Login as trainer works after trainer API is ready.
- [ ] Trainer cannot access unassigned member.
- [ ] Trainer cannot view member payment details.
- [ ] Member cannot access trainer endpoints.
- [ ] Trainer cannot access member endpoints.

## Phase 13: Build Verification

- [x] Run `flutter pub get`.
- [x] Run `dart format lib`.
- [x] Run `flutter analyze`.
- [x] Add widget/unit tests for auth API client and session handling where practical.
- [x] Run `flutter test` after test directory exists.
- [ ] Run Android emulator smoke test.
- [ ] Run iOS simulator smoke test if iOS is in scope.
- [ ] Document backend base URL setup for development and production.
