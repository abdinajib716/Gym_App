# Mobile Backend / Flutter Gap Task List

Review date: 2026-07-02

Backend source reviewed: `C:\Users\karsh\Desktop\Gym`

Flutter app reviewed: `C:\Users\karsh\Desktop\gym_app`

Scope: mobile member and trainer APIs only. Super Admin/API v1 management routes are intentionally out of scope for the mobile app.

## Current Status

- Backend mobile APIs exist under `/api/mobile/*` for shared auth, member, trainer, uploads, and device tokens.
- Backend trainer production smoke report says `https://gym.mrk.so` now returns `200` for trainer login, dashboard, profile, members, groups, workouts, and schedules.
- Flutter default API base URL is `https://gym.mrk.so`, with `API_BASE_URL` override support.
- Flutter already has role-aware member/trainer API clients, shared authenticated shell routing, trainer/member dashboard screens, date/time pickers for schedule creation, KPI grids, Android `INTERNET` and `ACCESS_NETWORK_STATE` permissions, and `usesCleartextTraffic=true`.
- Implementation update: trainer first-login password change, trainer Account password rotation, Firebase-backed device-token registration hooks, improved API error classification, endpoint path tests, analyzer, tests, and debug APK build are complete.

## Backend Endpoint Inventory And Flutter Coverage

### Shared Mobile Auth

- [x] `POST /api/mobile/auth/login` - covered by `AuthService.login`.
- [x] `GET /api/mobile/auth/me` - covered by `AuthService.me`.
- [x] `POST /api/mobile/auth/logout` - covered by `AuthService.logout`.
- [x] `POST /api/mobile/auth/forgot-password` - covered by password help flow.
- [x] `POST /api/mobile/auth/reset-password` - covered by password help flow.
- [x] `POST /api/mobile/device-tokens` - Flutter client and Firebase token registration hook exist; requires Firebase config files.
- [x] `DELETE /api/mobile/device-tokens` - Flutter client and logout cleanup hook exist; requires Firebase config files.

### Member Mobile

- [x] `GET /api/mobile/member/dashboard`
- [x] `GET /api/mobile/member/subscription/current`
- [x] `GET /api/mobile/member/subscription/history`
- [x] `GET /api/mobile/member/plans`
- [x] `POST /api/mobile/member/subscription/upgrade`
- [x] `POST /api/mobile/member/subscription/renew`
- [x] `POST /api/mobile/member/payments/waafi/initiate`
- [x] `GET /api/mobile/member/payments/waafi/status/{paymentId}`
- [x] `GET /api/mobile/member/payments/history`
- [x] `GET /api/mobile/member/notifications`
- [x] `PATCH /api/mobile/member/notifications/{notificationId}/read`
- [x] `PATCH /api/mobile/member/notifications/mark-all-read`
- [x] `DELETE /api/mobile/member/notifications/{notificationId}`
- [x] `GET /api/mobile/member/workouts`
- [x] `GET /api/mobile/member/workouts/today`
- [x] `GET /api/mobile/member/workouts/{workoutId}` - API client exists, no clear detail UI yet.
- [x] `GET /api/mobile/member/schedules`
- [x] `GET /api/mobile/member/schedules/today`

### Trainer Mobile

- [x] `POST /api/mobile/trainer/auth/login` - covered by trainer login fallback.
- [x] `POST /api/mobile/trainer/auth/logout`
- [x] `POST /api/mobile/trainer/auth/change-password` - Flutter client, first-login gate, and Account action exist.
- [x] `POST /api/mobile/trainer/auth/forgot-password` - backend alias exists through shared auth.
- [x] `POST /api/mobile/trainer/auth/reset-password` - backend alias exists through shared auth.
- [x] `GET /api/mobile/trainer/profile`
- [x] `PUT /api/mobile/trainer/profile` - API client exists, no edit profile UI yet.
- [x] `GET /api/mobile/trainer/dashboard`
- [x] `GET /api/mobile/trainer/members?search=...`
- [x] `GET /api/mobile/trainer/members/{memberId}`
- [x] `GET /api/mobile/trainer/members/{memberId}/attendance`
- [x] `GET /api/mobile/trainer/members/{memberId}/workouts`
- [x] `GET /api/mobile/trainer/members/{memberId}/schedules`
- [x] `GET /api/mobile/trainer/groups`
- [x] `GET /api/mobile/trainer/groups/{groupId}` - API client exists, no full group detail UI yet.
- [x] `GET /api/mobile/trainer/groups/{groupId}/members`
- [x] `GET /api/mobile/trainer/groups/{groupId}/workouts`
- [x] `GET /api/mobile/trainer/groups/{groupId}/schedules`
- [x] `GET /api/mobile/trainer/attendance/{today|weekly|monthly}` - API client exists, not surfaced in dashboard UI yet.
- [x] `POST /api/mobile/trainer/uploads/image`
- [x] `GET /api/mobile/trainer/workouts`
- [x] `POST /api/mobile/trainer/workouts`
- [x] `GET /api/mobile/trainer/workouts/{workoutId}`
- [x] `PUT /api/mobile/trainer/workouts/{workoutId}`
- [x] `DELETE /api/mobile/trainer/workouts/{workoutId}`
- [x] `POST /api/mobile/trainer/workouts/{workoutId}/assign-member` - API client exists, explicit reassign UI still needs polish.
- [x] `POST /api/mobile/trainer/workouts/{workoutId}/assign-group` - API client exists, depends on group data.
- [x] `GET /api/mobile/trainer/schedules?date=YYYY-MM-DD`
- [x] `POST /api/mobile/trainer/schedules`
- [x] `GET /api/mobile/trainer/schedules/{scheduleId}`
- [x] `PUT /api/mobile/trainer/schedules/{scheduleId}`
- [x] `DELETE /api/mobile/trainer/schedules/{scheduleId}`
- [x] `POST /api/mobile/trainer/schedules/{scheduleId}/complete`
- [x] `POST /api/mobile/trainer/schedules/{scheduleId}/cancel`

## Priority Task List

### P0 - Must Fix Before APK QA

- [x] Add `TrainerApi.changePassword(currentPassword, newPassword)` for `POST /trainer/auth/change-password`.
- [x] Add first-login password change flow when `mustChangePassword == true`, especially for trainer temporary passwords.
- [x] Add `MobileDeviceTokenApi` for `POST /device-tokens` and `DELETE /device-tokens`.
- [x] Decide whether Firebase/FCM is in this release. If yes, wire token registration after login and removal during logout. Yes we Are Using Firbase we missing Googlejson and info Josn we Will add it
- [x] Add API-client tests proving all mobile paths stay under `/api/mobile/*` and no Flutter mobile client calls `/api/v1/*`.
- [x] Run an APK smoke test against `https://gym.mrk.so` for member login, trainer login, dashboard loading, workout create, schedule create, and logout.

### P1 - Trainer Client Completion

- [ ] Add trainer profile edit screen using `PUT /trainer/profile`.
- [x] Add trainer change-password screen from Account, and force it on first login.
- [ ] Surface attendance summaries on trainer dashboard: today, weekly, monthly.
- [ ] Add a group detail sheet/page showing group members, group workouts, and group schedules.
- [ ] Improve workout detail/edit flow so existing workouts can be reassigned to member/group clearly.
- [ ] Add schedule date filtering UI backed by `GET /trainer/schedules?date=YYYY-MM-DD`.
- [ ] Add better create/edit validation before submit: exactly one target, title required, date required, workout required, start/end required, positive sets/reps/minutes.
- [ ] Add upload progress and clear image preview/removal behavior in workout create/edit.

### P1 - Member Client Completion

- [ ] Add member workout detail UI using `GET /member/workouts/{workoutId}`.
- [ ] Add clearer training detail cards for assigned workout, schedule time, trainer, status, image, sets/reps/minutes.
- [ ] Add member account password-change flow if backend shared member change-password is added later.
- [ ] Add empty-state copy for members with active subscription but no assigned trainer/workouts.

### P1 - Network And Loading UX

- [x] Replace broad “Unable to connect” handling with more specific messages: timeout, DNS/server unreachable, 401 session expired, 403 role mismatch, 404 route missing, validation error.
- [ ] Debounce or gate offline banners so the app does not show “No internet” when the device has transport and only the API request failed.
- [ ] Consider a lightweight API reachability check against `GET /api/mobile/auth/me` only when a token exists; avoid treating raw `connectivity_plus` transport changes as backend availability.
- [ ] Add per-tab refresh/loading states so trainer pages do not feel like every endpoint is blocking the whole screen.
- [ ] Keep dashboard usable with partial data, but show endpoint-specific retry actions instead of one combined warning for all trainer sections.

### P2 - UI / UX Polish

- [ ] Verify member and trainer KPI grids on small Android screens; use `SliverGridDelegateWithFixedCrossAxisCount` or responsive `childAspectRatio` if any text overflows.
- [ ] Verify bottom navigation labels for 5 and 6 tab layouts on 360px wide devices.
- [ ] Verify all bottom sheets in dark mode: dropdown labels, selected rows, input text, status menus, and modal background contrast.
- [ ] Add detail screens/routes where sheets are getting too tall: member detail, group detail, workout detail, schedule detail.
- [ ] Standardize snackbars through `AppSnackBar` instead of raw `ScaffoldMessenger` calls.

### P2 - Tests

- [ ] Add broader `ApiClient` unit tests for PUT/PATCH/DELETE, multipart upload, timeout, and backend error parsing.
- [ ] Add `MemberApi` endpoint tests for dashboard, training, plans, payments, notifications.
- [ ] Add `TrainerApi` endpoint tests for dashboard, members, groups, attendance, upload, workout CRUD, schedule CRUD/actions.
- [ ] Add auth tests for shared member login and trainer login response shape.
- [ ] Add model tests for group detail, member detail, attendance summary, workout assignment targets, and schedule action responses.
- [x] Add a static test that scans `lib/` for `/api/v1/` and fails if any mobile client references it.

## Backend Notes To Keep In Sync

- Trainer schedule statuses: `UPCOMING`, `COMPLETED`, `MISSED`, `CANCELLED`.
- Workout statuses: `ACTIVE`, `INACTIVE`.
- Workout difficulty values: `BEGINNER`, `INTERMEDIATE`, `ADVANCED`.
- Trainer schedule create requires `date`, `workoutId`, `startTime`, `endTime`, and exactly one of `memberId` or `groupId`.
- Workout create requires `title` and exactly one of `memberId` or `groupId`.
- Upload accepts only JPG, PNG, WEBP and max 5MB, returning `{ url, fileName }`.
- Device token platforms accepted by backend: `ANDROID`, `IOS`, `WEB`, `UNKNOWN`.

## Verification Commands For Next Work

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug = Skip it we will run local device 
```

Just For production we dont need it Local 
```

For production testing:

```bash
flutter run --dart-define=API_BASE_URL=https://gym.mrk.so
```
