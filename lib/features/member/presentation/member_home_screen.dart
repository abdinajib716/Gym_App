import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/core.dart';
import '../../../core/utils/mobile_phone.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/state/auth_controller.dart';
import '../../store/presentation/store_tab.dart';
import '../../training/data/training_models.dart';
import '../data/member_api.dart';
import '../data/member_models.dart';

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({
    super.key,
    required this.authController,
    required this.memberApi,
  });

  final AuthController authController;
  final MemberApi memberApi;

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  MemberDashboard? _dashboard;
  MemberProfile? _profile;
  MemberSubscription? _currentSubscription;
  List<MemberSubscription> _subscriptions = [];
  List<MembershipPlan> _plans = [];
  List<MemberPayment> _payments = [];
  List<MemberNotification> _notifications = [];
  MemberAttendance? _attendance;
  MemberProgress? _progress;
  List<TrainingWorkout> _workouts = [];
  List<TrainingWorkout> _todayWorkouts = [];
  List<TrainingSchedule> _schedules = [];
  List<TrainingSchedule> _todaySchedules = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        widget.memberApi.dashboard(),
        widget.memberApi.profile(),
        widget.memberApi.currentSubscription(),
        widget.memberApi.subscriptionHistory(),
        widget.memberApi.plans(),
        widget.memberApi.paymentHistory(),
        widget.memberApi.notifications(),
        widget.memberApi.attendance(),
        widget.memberApi.progress(days: 30),
        widget.memberApi.workouts(),
        widget.memberApi.todayWorkouts(),
        widget.memberApi.schedules(),
        widget.memberApi.todaySchedules(),
      ]);

      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as MemberDashboard;
        _profile = results[1] as MemberProfile;
        _currentSubscription = results[2] as MemberSubscription?;
        _subscriptions = results[3] as List<MemberSubscription>;
        _plans = results[4] as List<MembershipPlan>;
        _payments = results[5] as List<MemberPayment>;
        _notifications = results[6] as List<MemberNotification>;
        _attendance = results[7] as MemberAttendance;
        _progress = results[8] as MemberProgress;
        _workouts = results[9] as List<TrainingWorkout>;
        _todayWorkouts = results[10] as List<TrainingWorkout>;
        _schedules = results[11] as List<TrainingSchedule>;
        _todaySchedules = results[12] as List<TrainingSchedule>;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _markNotificationRead(MemberNotification notification) async {
    try {
      await widget.memberApi.markNotificationRead(notification.id);
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _markAllNotificationsRead() async {
    try {
      final count = await widget.memberApi.markAllNotificationsRead();
      _showMessage('$count notifications marked as read');
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _deleteNotification(MemberNotification notification) async {
    try {
      await widget.memberApi.deleteNotification(notification.id);
      _showMessage('Notification deleted');
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _renew(MembershipPlan? plan) async {
    try {
      final selectedPlan = plan ?? _currentSubscription?.plan;
      final subscription = await widget.memberApi.renew(
        planId: selectedPlan?.id,
      );
      final paymentPlan =
          selectedPlan ?? subscription.plan ?? _currentSubscription?.plan;
      if (paymentPlan == null || paymentPlan.price <= 0) {
        _showMessage('Renewal created. Choose a plan to complete payment.');
        await _loadAll();
        return;
      }
      _showMessage('Renewal created. Complete payment to activate it.');
      await _loadAll();
      if (!mounted) return;
      await _openPaymentSheet(subscription, paymentPlan);
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _upgrade(MembershipPlan plan) async {
    try {
      final subscription = await widget.memberApi.upgrade(planId: plan.id);
      _showMessage('Upgrade created. Complete payment to activate it.');
      await _loadAll();
      if (!mounted) return;
      await _openPaymentSheet(subscription, plan);
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _openPaymentSheet(
    MemberSubscription subscription,
    MembershipPlan? plan,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WaafiPaymentSheet(
        api: widget.memberApi,
        subscription: subscription,
        plan: plan,
        defaultPhone:
            _profile?.phoneNumber ??
            _dashboard?.member.phoneNumber ??
            widget.authController.user?.phone,
        onPaymentChanged: _loadAll,
      ),
    );
  }

  Future<void> _openMemberProfileSheet() async {
    final profile = _profile ?? _dashboard?.member;
    if (profile == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MemberProfileSheet(
        api: widget.memberApi,
        profile: profile,
        onChanged: _loadAll,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    AppSnackBar.info(context, message);
  }

  int get _bottomNavIndex {
    return switch (_currentIndex) {
      0 => 0,
      1 => 1,
      2 => 2,
      3 => 3,
      _ => 4,
    };
  }

  Widget _notificationAction() {
    final unread = _notifications
        .where((notification) => notification.readStatus == 'UNREAD')
        .length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => setState(() => _currentIndex = 3),
          icon: const Icon(IconsaxPlusLinear.notification),
        ),
        if (unread > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17),
              height: 17,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textWhite,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: const BrandLogo.appBar(),
        showBackButton: false,
        actions: [
          _notificationAction(),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadAll,
            icon: const Icon(IconsaxPlusLinear.refresh),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = switch (index) {
              0 => 0,
              1 => 1,
              2 => 2,
              3 => 3,
              _ => 4,
            };
          });
        },
        items: const [
          BottomNavItem(icon: IconsaxPlusLinear.home_1, label: 'Home'),
          BottomNavItem(icon: IconsaxPlusLinear.activity, label: 'Training'),
          BottomNavItem(icon: IconsaxPlusLinear.receipt_1, label: 'Payments'),
          BottomNavItem(
            icon: IconsaxPlusLinear.notification,
            label: 'Notifications',
          ),
          BottomNavItem(icon: Icons.more_horiz, label: 'More'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: LoadingIndicator(size: 36));
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _loadAll);
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        children: [
          switch (_currentIndex) {
            1 => _TrainingTab(
              workouts: _workouts,
              todayWorkouts: _todayWorkouts,
              schedules: _schedules,
              todaySchedules: _todaySchedules,
            ),
            2 => _PaymentsTab(
              payments: _payments,
              onCheckStatus: (payment) async {
                try {
                  final updated = await widget.memberApi.waafiPaymentStatus(
                    payment.id,
                  );
                  _showMessage('Payment status: ${updated.status}');
                  await _loadAll();
                } on ApiException catch (error) {
                  _showMessage(error.message);
                }
              },
            ),
            3 => _NotificationsTab(
              notifications: _notifications,
              onRead: _markNotificationRead,
              onMarkAll: _markAllNotificationsRead,
              onDelete: _deleteNotification,
            ),
            5 => _PlansTab(plans: _plans, onUpgrade: _upgrade, onRenew: _renew),
            6 => _AccountTab(
              profile: _profile ?? _dashboard?.member,
              dashboard: _dashboard,
              authController: widget.authController,
              onEditProfile: _openMemberProfileSheet,
            ),
            7 => StoreTab(
              products: widget.memberApi.storeProducts,
              orders: widget.memberApi.storeOrders,
              productDetail: widget.memberApi.storeProductDetail,
              orderDetail: widget.memberApi.storeOrderDetail,
              purchase: widget.memberApi.purchaseStoreProduct,
              defaultPhone:
                  _profile?.phoneNumber ??
                  _dashboard?.member.phoneNumber ??
                  widget.authController.user?.phone,
            ),
            8 => _SubscriptionHistoryTab(
              api: widget.memberApi,
              subscriptions: _subscriptions,
            ),
            4 => _MoreTab(
              profile: _profile ?? _dashboard?.member,
              dashboard: _dashboard,
              notificationCount: _notifications
                  .where((notification) => notification.readStatus == 'UNREAD')
                  .length,
              onOpenPlans: () => setState(() => _currentIndex = 5),
              onOpenStore: () => setState(() => _currentIndex = 7),
              onOpenSubscriptionHistory: () =>
                  setState(() => _currentIndex = 8),
              onOpenAlerts: () => setState(() => _currentIndex = 3),
              onOpenAccount: () => setState(() => _currentIndex = 6),
              onLogout: widget.authController.logout,
            ),
            _ => _DashboardTab(
              dashboard: _dashboard,
              profile: _profile,
              currentSubscription: _currentSubscription,
              subscriptions: _subscriptions,
              payments: _payments,
              notifications: _notifications,
              todayWorkouts: _todayWorkouts,
              todaySchedules: _todaySchedules,
              attendance: _attendance,
              progress: _progress,
              onRenew: () => _renew(_currentSubscription?.plan),
              onViewTraining: () => setState(() => _currentIndex = 1),
              onViewPayments: () => setState(() => _currentIndex = 2),
              onViewNotifications: () => setState(() => _currentIndex = 3),
              onOpenStore: () => setState(() => _currentIndex = 7),
            ),
          },
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.dashboard,
    required this.profile,
    required this.currentSubscription,
    required this.subscriptions,
    required this.payments,
    required this.notifications,
    required this.todayWorkouts,
    required this.todaySchedules,
    required this.attendance,
    required this.progress,
    required this.onRenew,
    required this.onViewTraining,
    required this.onViewPayments,
    required this.onViewNotifications,
    required this.onOpenStore,
  });

  final MemberDashboard? dashboard;
  final MemberProfile? profile;
  final MemberSubscription? currentSubscription;
  final List<MemberSubscription> subscriptions;
  final List<MemberPayment> payments;
  final List<MemberNotification> notifications;
  final List<TrainingWorkout> todayWorkouts;
  final List<TrainingSchedule> todaySchedules;
  final MemberAttendance? attendance;
  final MemberProgress? progress;
  final VoidCallback onRenew;
  final VoidCallback onViewTraining;
  final VoidCallback onViewPayments;
  final VoidCallback onViewNotifications;
  final VoidCallback onOpenStore;

  @override
  Widget build(BuildContext context) {
    final subscription = currentSubscription ?? dashboard?.currentSubscription;
    final latestNotifications = notifications.isNotEmpty
        ? notifications
        : dashboard?.latestNotifications ?? const [];
    final upcoming = <_UpcomingItem>[
      ..._upcomingItems(subscription: subscription),
      ..._upcomingTrainingItems(todaySchedules),
    ]..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MembershipStatusCard(
          memberName:
              profile?.fullName ?? dashboard?.member.fullName ?? 'Member',
          profileImage: profile?.profileImage ?? dashboard?.member.profileImage,
          subscription: subscription,
          isActive: dashboard?.summary.hasActiveSubscription == true,
          onRenew: onRenew,
        ),
        const SizedBox(height: 18),
        _TodayWorkoutCard(
          workouts: todayWorkouts,
          schedules: todaySchedules,
          onViewWorkout: onViewTraining,
          onMarkDone: onViewTraining,
        ),
        const SizedBox(height: 18),
        _ProgressSummaryCard(progress: progress),
        const SizedBox(height: 18),
        _AttendanceSummaryCard(attendance: attendance, progress: progress),
        const SizedBox(height: 18),
        _UpcomingCard(items: upcoming.take(3).toList(), onView: onViewTraining),
        const SizedBox(height: 18),
        _LatestNotificationsCard(
          notifications: latestNotifications.take(3).toList(),
          onViewAll: onViewNotifications,
        ),
        const SizedBox(height: 18),
        _QuickActionsGrid(
          isExpired:
              _membershipState(subscription).status ==
              _MembershipStatus.expired,
          onRenew: onRenew,
          onPayments: onViewPayments,
          onWorkout: onViewTraining,
          onStore: onOpenStore,
        ),
      ],
    );
  }

  List<_UpcomingItem> _upcomingItems({MemberSubscription? subscription}) {
    final dueDate = subscription?.expiryDate;
    if (dueDate == null) return [];
    return [
      _UpcomingItem(
        icon: IconsaxPlusLinear.card,
        date: dueDate,
        title: 'Next payment due',
        subtitle: _relativeDate(dueDate),
        meta: _date(dueDate),
      ),
    ];
  }

  List<_UpcomingItem> _upcomingTrainingItems(List<TrainingSchedule> schedules) {
    final now = DateTime.now();
    final upcomingSchedules =
        schedules.where((schedule) {
          final date = schedule.date;
          if (date == null) return false;
          return !date.isBefore(DateTime(now.year, now.month, now.day));
        }).toList()..sort((a, b) {
          final dateCompare = (a.date ?? now).compareTo(b.date ?? now);
          if (dateCompare != 0) return dateCompare;
          return (a.startTime ?? '').compareTo(b.startTime ?? '');
        });

    return upcomingSchedules
        .map(
          (schedule) => _UpcomingItem(
            icon: IconsaxPlusLinear.calendar_1,
            date: schedule.date ?? DateTime.now(),
            title: schedule.workout?.title ?? 'Training session',
            subtitle: _relativeDate(schedule.date),
            meta: schedule.startTime ?? '',
          ),
        )
        .toList();
  }
}

enum _MembershipStatus { active, expiringSoon, expired }

class _MembershipViewState {
  const _MembershipViewState({
    required this.status,
    required this.label,
    required this.color,
    required this.daysLeftText,
    required this.planName,
    required this.expiryText,
    required this.message,
  });

  final _MembershipStatus status;
  final String label;
  final Color color;
  final String daysLeftText;
  final String planName;
  final String expiryText;
  final String message;
}

class _MembershipStatusCard extends StatelessWidget {
  const _MembershipStatusCard({
    required this.memberName,
    required this.profileImage,
    required this.subscription,
    required this.isActive,
    required this.onRenew,
  });

  final String memberName;
  final String? profileImage;
  final MemberSubscription? subscription;
  final bool isActive;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final state = _membershipState(subscription, fallbackActive: isActive);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = state.status == _MembershipStatus.expired
        ? AppColors.error.withValues(alpha: isDark ? 0.18 : 0.10)
        : isDark
        ? AppColors.darkCard
        : AppColors.backgroundWhite;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: DesignTokens.borderRadiusLarge,
        border: Border.all(color: state.color.withValues(alpha: 0.35)),
        boxShadow: AppShadows.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                image: profileImage,
                fallbackIcon: IconsaxPlusLinear.profile,
                size: 48,
                backgroundColor: AppColors.textWhite.withValues(alpha: 0.14),
                iconColor: AppColors.textWhite,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Welcome, $memberName', style: AppTextStyles.h1),
              ),
              _StatusBadge(label: state.label, color: state.color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            state.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: state.status == _MembershipStatus.expired
                  ? AppColors.error
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MembershipPill(
                icon: IconsaxPlusLinear.timer_1,
                label: state.daysLeftText,
              ),
              _MembershipPill(
                icon: IconsaxPlusLinear.card,
                label: state.planName,
              ),
              if (subscription?.plan != null)
                _MembershipPill(
                  icon: Icons.attach_money,
                  label: _money(
                    subscription!.plan!.price,
                    subscription!.plan!.currency,
                  ),
                ),
              _MembershipPill(
                icon: IconsaxPlusLinear.calendar_1,
                label: state.expiryText,
              ),
            ],
          ),
          if (subscription?.startDate != null &&
              subscription?.expiryDate != null) ...[
            const SizedBox(height: 16),
            _MembershipProgressBar(subscription: subscription!),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: state.status == _MembershipStatus.expired
                ? 'Renew Now'
                : 'Renew Membership',
            icon: IconsaxPlusLinear.card_send,
            type: state.status == _MembershipStatus.expired
                ? ButtonType.primary
                : ButtonType.outline,
            onPressed: onRenew,
          ),
        ],
      ),
    );
  }
}

class _MembershipPill extends StatelessWidget {
  const _MembershipPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MembershipProgressBar extends StatelessWidget {
  const _MembershipProgressBar({required this.subscription});

  final MemberSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final start = subscription.startDate!;
    final expiry = subscription.expiryDate!;
    final now = DateTime.now();
    final totalDays = expiry.difference(start).inDays.clamp(1, 10000);
    final usedDays = now.difference(start).inDays.clamp(0, totalDays);
    final value = usedDays / totalDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.10),
            color: _membershipState(subscription).color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Started ${_date(start)}',
                style: AppTextStyles.caption,
              ),
            ),
            Text('Renews ${_date(expiry)}', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({
    required this.workouts,
    required this.schedules,
    required this.onViewWorkout,
    required this.onMarkDone,
  });

  final List<TrainingWorkout> workouts;
  final List<TrainingSchedule> schedules;
  final VoidCallback onViewWorkout;
  final VoidCallback onMarkDone;

  @override
  Widget build(BuildContext context) {
    final schedule = schedules.isNotEmpty ? schedules.first : null;
    final workout =
        schedule?.workout ?? (workouts.isNotEmpty ? workouts.first : null);

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: "Today's Workout"),
          if (workout == null)
            const _DashboardEmpty(
              icon: IconsaxPlusLinear.activity,
              message: 'No workout scheduled for today',
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: DesignTokens.borderRadiusMedium,
                  ),
                  child: const Icon(
                    IconsaxPlusLinear.activity,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(workout.title, style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text(
                        '${schedule?.startTime ?? workout.schedule?.startTime ?? 'Time not set'}'
                        ' - ${schedule?.trainer?.fullName ?? workout.trainer?.fullName ?? 'Trainer'}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _StatusBadge(
              label: _trainingStatusLabel(schedule?.status ?? workout.status),
              color: _trainingStatusColor(schedule?.status ?? workout.status),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Workout',
                    size: ButtonSize.small,
                    icon: IconsaxPlusLinear.eye,
                    onPressed: onViewWorkout,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Mark as Done',
                    size: ButtonSize.small,
                    type: ButtonType.outline,
                    icon: IconsaxPlusLinear.tick_circle,
                    onPressed: onMarkDone,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  const _ProgressSummaryCard({required this.progress});

  final MemberProgress? progress;

  @override
  Widget build(BuildContext context) {
    final training = progress?.training;
    final completionRate = (training?.completionRate ?? 0).clamp(0, 100);

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Progress'),
          if (training == null)
            const _DashboardEmpty(
              icon: Icons.insights,
              message: 'No progress data yet',
            )
          else ...[
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.14),
                    borderRadius: DesignTokens.borderRadiusMedium,
                  ),
                  child: const Icon(Icons.insights, color: AppColors.success),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completionRate% complete',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: completionRate / 100,
                          minHeight: 8,
                          backgroundColor: AppColors.success.withValues(
                            alpha: 0.12,
                          ),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.95,
              children: [
                _CompactMetricTile(
                  icon: IconsaxPlusLinear.activity,
                  label: 'Workouts',
                  value: '${training.activeWorkouts}',
                  color: AppColors.primaryBlue,
                ),
                _CompactMetricTile(
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: '${training.completedSchedules}',
                  color: AppColors.success,
                ),
                _CompactMetricTile(
                  icon: IconsaxPlusLinear.calendar_1,
                  label: 'Upcoming',
                  value: '${training.upcomingSchedules}',
                  color: AppColors.info,
                ),
                _CompactMetricTile(
                  icon: Icons.warning_amber_rounded,
                  label: 'Missed',
                  value: '${training.missedSchedules}',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.attendance,
    required this.progress,
  });

  final MemberAttendance? attendance;
  final MemberProgress? progress;

  @override
  Widget build(BuildContext context) {
    final summary = attendance?.summary;
    final progressAttendance = progress?.attendance;
    final lastCheckIn =
        summary?.lastCheckIn ?? progressAttendance?.lastCheckIn?.checkInDate;
    final records = attendance?.records.take(2).toList() ?? const [];

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Attendance'),
          if (summary == null && progressAttendance == null)
            const _DashboardEmpty(
              icon: IconsaxPlusLinear.calendar_1,
              message: 'No attendance data yet',
            )
          else ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.95,
              children: [
                _CompactMetricTile(
                  icon: IconsaxPlusLinear.calendar_1,
                  label: 'Total visits',
                  value:
                      '${summary?.total ?? progressAttendance?.totalPresent ?? 0}',
                  color: AppColors.primaryBlue,
                ),
                _CompactMetricTile(
                  icon: Icons.check_circle_outline,
                  label: 'Present',
                  value:
                      '${summary?.present ?? progressAttendance?.presentInRange ?? 0}',
                  color: AppColors.success,
                ),
                _CompactMetricTile(
                  icon: IconsaxPlusLinear.timer_1,
                  label: 'This month',
                  value: '${progressAttendance?.presentThisMonth ?? 0}',
                  color: AppColors.info,
                ),
                _CompactMetricTile(
                  icon: Icons.cancel_outlined,
                  label: 'Cancelled',
                  value: '${summary?.cancelled ?? 0}',
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Last check-in', value: _date(lastCheckIn)),
            if (records.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...records.map(
                (record) => _InfoRow(
                  label: _date(record.checkInDate),
                  value: record.status,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CompactMetricTile extends StatelessWidget {
  const _CompactMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.backgroundLight,
        borderRadius: DesignTokens.borderRadiusMedium,
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.h3.copyWith(color: color)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingItem {
  const _UpcomingItem({
    required this.icon,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final IconData icon;
  final DateTime date;
  final String title;
  final String subtitle;
  final String meta;
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.items, required this.onView});

  final List<_UpcomingItem> items;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Upcoming',
            action: 'View Calendar',
            onTap: onView,
          ),
          if (items.isEmpty)
            const _DashboardEmpty(
              icon: IconsaxPlusLinear.calendar_1,
              message: 'No upcoming activities',
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(item.icon, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item.subtitle} - ${item.title}'
                        '${item.meta.isEmpty ? '' : ' - ${item.meta}'}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LatestNotificationsCard extends StatelessWidget {
  const _LatestNotificationsCard({
    required this.notifications,
    required this.onViewAll,
  });

  final List<MemberNotification> notifications;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Latest Notifications',
            action: 'View All',
            onTap: onViewAll,
          ),
          if (notifications.isEmpty)
            const _DashboardEmpty(
              icon: IconsaxPlusLinear.notification,
              message: 'No notifications yet',
            )
          else
            ...notifications.map((notification) {
              final isUnread = notification.readStatus == 'UNREAD';
              return Opacity(
                opacity: isUnread ? 1 : 0.58,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: isUnread
                              ? AppColors.primaryBlue
                              : AppColors.divider,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.title, style: AppTextStyles.h3),
                            Text(
                              notification.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.isExpired,
    required this.onRenew,
    required this.onPayments,
    required this.onWorkout,
    required this.onStore,
  });

  final bool isExpired;
  final VoidCallback onRenew;
  final VoidCallback onPayments;
  final VoidCallback onWorkout;
  final VoidCallback onStore;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: IconsaxPlusLinear.card_send,
        label: 'Renew Membership',
        tone: isExpired ? AppColors.error : AppColors.primaryBlue,
        highlighted: isExpired,
        onTap: onRenew,
      ),
      _QuickAction(
        icon: IconsaxPlusLinear.receipt_1,
        label: 'View Payments',
        tone: AppColors.primaryBlue,
        onTap: onPayments,
      ),
      _QuickAction(
        icon: IconsaxPlusLinear.activity,
        label: 'View Workout',
        tone: AppColors.info,
        onTap: onWorkout,
      ),
      _QuickAction(
        icon: Icons.storefront,
        label: 'Store',
        tone: AppColors.accentPurple,
        onTap: onStore,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Quick Actions'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.48,
          children: actions.map(_QuickActionTile.new).toList(),
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final Color tone;
  final VoidCallback onTap;
  final bool highlighted;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile(this.action);

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.highlighted
          ? action.tone.withValues(alpha: 0.14)
          : Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkCard
          : AppColors.backgroundWhite,
      borderRadius: DesignTokens.borderRadiusMedium,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: DesignTokens.borderRadiusMedium,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: DesignTokens.borderRadiusMedium,
            border: Border.all(
              color: action.highlighted
                  ? action.tone.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
            boxShadow: AppShadows.cardShadows,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.tone),
              const SizedBox(height: 10),
              Text(
                action.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardEmpty extends StatelessWidget {
  const _DashboardEmpty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrainingTab extends StatelessWidget {
  const _TrainingTab({
    required this.workouts,
    required this.todayWorkouts,
    required this.schedules,
    required this.todaySchedules,
  });

  final List<TrainingWorkout> workouts;
  final List<TrainingWorkout> todayWorkouts;
  final List<TrainingSchedule> schedules;
  final List<TrainingSchedule> todaySchedules;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty && schedules.isEmpty) {
      return const EmptyState(
        icon: IconsaxPlusLinear.activity,
        title: 'No training yet',
        message: 'Trainer-assigned workouts and schedules will appear here.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Today'),
        if (todayWorkouts.isEmpty && todaySchedules.isEmpty)
          const _PlainEmpty(message: 'No training assigned for today.'),
        ...todayWorkouts.map(_WorkoutTile.new),
        ...todaySchedules.map(_ScheduleTile.new),
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Assigned Workouts'),
        if (workouts.isEmpty) const _PlainEmpty(message: 'No workouts yet.'),
        ...workouts.map(_WorkoutTile.new),
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Schedules'),
        if (schedules.isEmpty) const _PlainEmpty(message: 'No schedules yet.'),
        ...schedules.map(_ScheduleTile.new),
      ],
    );
  }
}

class _PlansTab extends StatelessWidget {
  const _PlansTab({
    required this.plans,
    required this.onUpgrade,
    required this.onRenew,
  });

  final List<MembershipPlan> plans;
  final Future<void> Function(MembershipPlan plan) onUpgrade;
  final Future<void> Function(MembershipPlan plan) onRenew;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const EmptyState(
        icon: IconsaxPlusLinear.card,
        title: 'No active plans',
        message: 'Membership plans will appear here when available.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: plans
          .map(
            (plan) => _AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(plan.name, style: AppTextStyles.h2)),
                      Text(
                        _money(plan.price, plan.currency),
                        style: AppTextStyles.h2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${plan.type} - ${plan.durationDays} days'),
                  if (plan.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      plan.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Renew',
                          size: ButtonSize.small,
                          type: ButtonType.outline,
                          onPressed: () => onRenew(plan),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Upgrade',
                          size: ButtonSize.small,
                          onPressed: () => onUpgrade(plan),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({required this.payments, required this.onCheckStatus});

  final List<MemberPayment> payments;
  final Future<void> Function(MemberPayment payment) onCheckStatus;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const EmptyState(
        icon: IconsaxPlusLinear.receipt_1,
        title: 'No payments',
        message: 'Your payment history will appear here.',
      );
    }

    return Column(
      children: payments
          .map(
            (payment) => _PaymentTile(
              payment,
              onCheckStatus: payment.method == 'WAAFI_PAY'
                  ? () => onCheckStatus(payment)
                  : null,
            ),
          )
          .toList(),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab({
    required this.notifications,
    required this.onRead,
    required this.onMarkAll,
    required this.onDelete,
  });

  final List<MemberNotification> notifications;
  final Future<void> Function(MemberNotification notification) onRead;
  final Future<void> Function() onMarkAll;
  final Future<void> Function(MemberNotification notification) onDelete;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const EmptyState(
        icon: IconsaxPlusLinear.notification,
        title: 'No notifications',
        message: 'Gym announcements and payment updates will appear here.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onMarkAll,
            icon: const Icon(IconsaxPlusLinear.tick_circle),
            label: const Text('Mark all read'),
          ),
        ),
        ...notifications.map(
          (notification) => _NotificationTile(
            notification,
            onRead: () => onRead(notification),
            onDelete: () => onDelete(notification),
          ),
        ),
      ],
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.profile,
    required this.dashboard,
    required this.authController,
    required this.onEditProfile,
  });

  final MemberProfile? profile;
  final MemberDashboard? dashboard;
  final AuthController authController;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final member = profile ?? dashboard?.member;
    final account = dashboard?.account;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(
                    image:
                        member?.profileImage ??
                        authController.user?.profileImage,
                    fallbackIcon: IconsaxPlusLinear.profile,
                    size: 58,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      member?.fullName ?? authController.user?.name ?? 'Member',
                      style: AppTextStyles.h1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Phone',
                value: member?.phoneNumber ?? authController.user?.phone ?? '-',
              ),
              _InfoRow(
                label: 'Email',
                value: member?.email ?? authController.user?.email ?? '-',
              ),
              _InfoRow(
                label: 'Status',
                value:
                    member?.status ?? authController.user?.accountStatus ?? '-',
              ),
              if (member?.gender != null)
                _InfoRow(label: 'Gender', value: member!.gender!),
              if (member?.address != null)
                _InfoRow(label: 'Address', value: member!.address!),
              if (member?.dateOfBirth != null)
                _InfoRow(
                  label: 'Date of birth',
                  value: _date(member!.dateOfBirth),
                ),
              if (member?.emergencyContact != null)
                _InfoRow(
                  label: 'Emergency contact',
                  value: member!.emergencyContact!,
                ),
              _InfoRow(
                label: 'Must change password',
                value: account?.mustChangePassword == true ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Edit Profile',
          icon: IconsaxPlusLinear.edit,
          onPressed: onEditProfile,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Logout',
          icon: IconsaxPlusLinear.logout_1,
          type: ButtonType.outline,
          onPressed: authController.logout,
        ),
      ],
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab({
    required this.profile,
    required this.dashboard,
    required this.notificationCount,
    required this.onOpenPlans,
    required this.onOpenStore,
    required this.onOpenSubscriptionHistory,
    required this.onOpenAlerts,
    required this.onOpenAccount,
    required this.onLogout,
  });

  final MemberProfile? profile;
  final MemberDashboard? dashboard;
  final int notificationCount;
  final VoidCallback onOpenPlans;
  final VoidCallback onOpenStore;
  final VoidCallback onOpenSubscriptionHistory;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final member = profile ?? dashboard?.member;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppCard(
          child: Row(
            children: [
              AppAvatar(
                image: member?.profileImage,
                fallbackIcon: IconsaxPlusLinear.profile,
                size: 54,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member?.fullName ?? 'Member', style: AppTextStyles.h2),
                    const SizedBox(height: 2),
                    Text(
                      member?.phoneNumber ?? member?.email ?? 'Mobile account',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _MoreActionTile(
          icon: IconsaxPlusLinear.card,
          title: 'Plans',
          subtitle: 'Renew or upgrade membership',
          onTap: onOpenPlans,
        ),
        _MoreActionTile(
          icon: Icons.storefront,
          title: 'Store',
          subtitle: 'Buy gym products and view orders',
          onTap: onOpenStore,
        ),
        _MoreActionTile(
          icon: Icons.history,
          title: 'Subscription History',
          subtitle: 'Filter memberships by status and period',
          onTap: onOpenSubscriptionHistory,
        ),
        _MoreActionTile(
          icon: IconsaxPlusLinear.notification,
          title: 'Notifications',
          subtitle: notificationCount == 0
              ? 'No unread alerts'
              : '$notificationCount unread alerts',
          trailingText: notificationCount == 0 ? null : '$notificationCount',
          onTap: onOpenAlerts,
        ),
        _MoreActionTile(
          icon: IconsaxPlusLinear.profile,
          title: 'Account',
          subtitle: 'Profile and membership details',
          onTap: onOpenAccount,
        ),
        _MoreActionTile(
          icon: IconsaxPlusLinear.logout_1,
          title: 'Logout',
          subtitle: 'Sign out from this device',
          isDestructive: true,
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _MoreActionTile extends StatelessWidget {
  const _MoreActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = isDestructive ? AppColors.error : AppColors.primaryBlue;

    return _AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.borderRadiusMedium,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: DesignTokens.borderRadiusMedium,
              ),
              child: Icon(icon, color: tone),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trailingText!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionHistoryTab extends StatefulWidget {
  const _SubscriptionHistoryTab({
    required this.api,
    required this.subscriptions,
  });

  final MemberApi api;
  final List<MemberSubscription> subscriptions;

  @override
  State<_SubscriptionHistoryTab> createState() =>
      _SubscriptionHistoryTabState();
}

class _SubscriptionHistoryTabState extends State<_SubscriptionHistoryTab> {
  final _planId = TextEditingController();
  final _dateFrom = TextEditingController();
  final _dateTo = TextEditingController();
  String? _status;
  String? _paymentStatus;
  String? _period;
  bool _loading = false;
  String? _error;
  List<MemberSubscription>? _results;

  @override
  void dispose() {
    _planId.dispose();
    _dateFrom.dispose();
    _dateTo.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final subscriptions = await widget.api.subscriptionHistory(
        status: _status,
        paymentStatus: _paymentStatus,
        planId: _planId.text.trim(),
        period: _period,
        dateFrom: DateTime.tryParse(_dateFrom.text.trim()),
        dateTo: DateTime.tryParse(_dateTo.text.trim()),
      );
      if (mounted) setState(() => _results = subscriptions);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clear() {
    setState(() {
      _status = null;
      _paymentStatus = null;
      _period = null;
      _results = null;
      _error = null;
      _planId.clear();
      _dateFrom.clear();
      _dateTo.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = _results ?? widget.subscriptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Status',
                      value: _status,
                      values: const [
                        'ACTIVE',
                        'EXPIRED',
                        'PENDING',
                        'SUSPENDED',
                      ],
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Payment',
                      value: _paymentStatus,
                      values: const [
                        'PAID',
                        'PENDING',
                        'FAILED',
                        'CANCELLED',
                        'EXPIRED',
                      ],
                      onChanged: (value) =>
                          setState(() => _paymentStatus = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FilterDropdown(
                label: 'Period',
                value: _period,
                values: const ['today', 'week', 'month', 'year'],
                onChanged: (value) => setState(() => _period = value),
              ),
              const SizedBox(height: 12),
              CustomTextField(controller: _planId, labelText: 'Plan ID'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _dateFrom,
                      labelText: 'Date from',
                      hintText: '2026-07-01',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _dateTo,
                      labelText: 'Date to',
                      hintText: '2026-07-31',
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Clear',
                      type: ButtonType.outline,
                      onPressed: _clear,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: 'Apply',
                      isLoading: _loading,
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (subscriptions.isEmpty)
          const EmptyState(
            icon: IconsaxPlusLinear.receipt_1,
            title: 'No subscriptions',
            message: 'Subscription history will appear here.',
          )
        else
          ...subscriptions.map(_SubscriptionTile.new),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: null, child: Text('Any')),
        ...values.map(
          (value) => DropdownMenuItem(value: value, child: Text(value)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile(this.subscription);

  final MemberSubscription subscription;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _displayPlanName(subscription.plan),
                  style: AppTextStyles.h3,
                ),
              ),
              _StatusBadge(
                label: subscription.status,
                color: subscription.status == 'ACTIVE'
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Payment', value: subscription.paymentStatus),
          _InfoRow(label: 'Start', value: _date(subscription.startDate)),
          _InfoRow(label: 'Expiry', value: _date(subscription.expiryDate)),
          _InfoRow(label: 'Created', value: _date(subscription.createdAt)),
        ],
      ),
    );
  }
}

class _MemberProfileSheet extends StatefulWidget {
  const _MemberProfileSheet({
    required this.api,
    required this.profile,
    required this.onChanged,
  });

  final MemberApi api;
  final MemberProfile profile;
  final Future<void> Function() onChanged;

  @override
  State<_MemberProfileSheet> createState() => _MemberProfileSheetState();
}

class _MemberProfileSheetState extends State<_MemberProfileSheet> {
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _phone = TextEditingController(
    text: widget.profile.phoneNumber ?? '',
  );
  late final _email = TextEditingController(text: widget.profile.email ?? '');
  late final _gender = TextEditingController(text: widget.profile.gender ?? '');
  late final _address = TextEditingController(
    text: widget.profile.address ?? '',
  );
  late final _dateOfBirth = TextEditingController(
    text: _date(widget.profile.dateOfBirth) == '-'
        ? ''
        : _date(widget.profile.dateOfBirth),
  );
  late final _emergency = TextEditingController(
    text: widget.profile.emergencyContact ?? '',
  );
  late final _profileImage = TextEditingController(
    text: widget.profile.profileImage ?? '',
  );
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _gender.dispose();
    _address.dispose();
    _dateOfBirth.dispose();
    _emergency.dispose();
    _profileImage.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _message = 'Full name is required');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.api.updateProfile(
        MemberProfile(
          id: widget.profile.id,
          fullName: _name.text.trim(),
          phoneNumber: _optionalText(_phone),
          email: _optionalText(_email),
          gender: _optionalText(_gender),
          address: _optionalText(_address),
          dateOfBirth: DateTime.tryParse(_dateOfBirth.text.trim()),
          emergencyContact: _optionalText(_emergency),
          profileImage: _optionalText(_profileImage),
          status: widget.profile.status,
        ),
      );
      await widget.onChanged();
      if (mounted) Navigator.pop(context);
    } on ApiException catch (error) {
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileSheetFrame(
      title: 'Edit Profile',
      child: Column(
        children: [
          AppAvatar(
            image: _profileImage.text,
            fallbackIcon: IconsaxPlusLinear.profile,
            size: 76,
          ),
          const SizedBox(height: 16),
          CustomTextField(controller: _name, labelText: 'Full name'),
          const SizedBox(height: 12),
          CustomTextField(controller: _phone, labelText: 'Phone number'),
          const SizedBox(height: 12),
          CustomTextField(controller: _email, labelText: 'Email'),
          const SizedBox(height: 12),
          CustomTextField(controller: _gender, labelText: 'Gender'),
          const SizedBox(height: 12),
          CustomTextField(controller: _address, labelText: 'Address'),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _dateOfBirth,
            labelText: 'Date of birth',
            hintText: '2000-01-01',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _emergency,
            labelText: 'Emergency contact',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _profileImage,
            labelText: 'Profile image URL',
            onChanged: (_) => setState(() {}),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: 'Save Profile',
            isLoading: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _ProfileSheetFrame extends StatelessWidget {
  const _ProfileSheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: EdgeInsets.only(
            left: DesignTokens.screenPadding,
            right: DesignTokens.screenPadding,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: 16),
            child,
          ],
        );
      },
    );
  }
}

class _WaafiPaymentSheet extends StatefulWidget {
  const _WaafiPaymentSheet({
    required this.api,
    required this.subscription,
    required this.plan,
    required this.defaultPhone,
    required this.onPaymentChanged,
  });

  final MemberApi api;
  final MemberSubscription subscription;
  final MembershipPlan? plan;
  final String? defaultPhone;
  final Future<void> Function() onPaymentChanged;

  @override
  State<_WaafiPaymentSheet> createState() => _WaafiPaymentSheetState();
}

class _WaafiPaymentSheetState extends State<_WaafiPaymentSheet> {
  final _phoneController = TextEditingController();
  String _provider = 'EVC_PLUS';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.defaultPhone ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final amount = widget.plan?.price ?? 0;
    final phone = normalizeSomaliaPhone(_phoneController.text);
    if (amount <= 0) {
      AppSnackBar.error(context, 'This plan has no payable amount.');
      return;
    }
    if (!_isSomaliaMobilePhone(phone)) {
      AppSnackBar.error(
        context,
        'Enter a valid Somalia phone number, for example 252612345678.',
      );
      return;
    }
    setState(() {
      _busy = true;
    });
    AppSnackBar.info(
      context,
      'Sending Waafi prompt to $phone. Confirm it on your phone.',
    );

    try {
      final payment = await widget.api.initiateWaafiPayment(
        subscriptionId: widget.subscription.id,
        provider: _provider,
        phoneNumber: phone,
        amount: amount,
        currency: widget.plan?.currency ?? 'USD',
      );
      if (!mounted) return;
      AppSnackBar.info(
        context,
        'Payment initiated. Confirm the prompt on your phone.',
      );
      await widget.onPaymentChanged();
      _pollStatus(payment.id);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.error(context, error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pollStatus(String paymentId) async {
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      try {
        final payment = await widget.api.waafiPaymentStatus(paymentId);
        if (!mounted) return;
        AppSnackBar.info(context, 'Payment status: ${payment.status}');
        await widget.onPaymentChanged();
        if (payment.status != 'PENDING') return;
      } catch (_) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = _money(
      widget.plan?.price ?? 0,
      widget.plan?.currency ?? 'USD',
    );

    return Padding(
      padding: EdgeInsets.only(
        left: DesignTokens.screenPadding,
        right: DesignTokens.screenPadding,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Waafi Payment', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text('${widget.plan?.name ?? 'Subscription'} - $amount'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _provider,
            items: const [
              DropdownMenuItem(value: 'EVC_PLUS', child: Text('EVC PLUS')),
              DropdownMenuItem(value: 'JEEB', child: Text('JEEB')),
              DropdownMenuItem(value: 'ZAAD', child: Text('ZAAD')),
              DropdownMenuItem(value: 'SAHAL', child: Text('SAHAL')),
            ],
            onChanged: (value) =>
                setState(() => _provider = value ?? _provider),
            decoration: const InputDecoration(labelText: 'Provider'),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _phoneController,
            labelText: 'Payment phone',
            hintText: '252612345678',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Pay with Waafi',
            isLoading: _busy,
            icon: IconsaxPlusLinear.card_send,
            onPressed: _pay,
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile(this.payment, {this.onCheckStatus});

  final MemberPayment payment;
  final VoidCallback? onCheckStatus;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Row(
        children: [
          const Icon(IconsaxPlusLinear.receipt_1, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _money(payment.amount, payment.currency),
                  style: AppTextStyles.h2,
                ),
                Text('${payment.method} - ${payment.status}'),
                if (payment.requestId != null)
                  Text(
                    payment.requestId!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (onCheckStatus != null)
            IconButton(
              tooltip: 'Check status',
              onPressed: onCheckStatus,
              icon: const Icon(IconsaxPlusLinear.refresh),
            ),
        ],
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile(this.workout);

  final TrainingWorkout workout;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (workout.sets != null) '${workout.sets} sets',
      if (workout.reps != null) '${workout.reps} reps',
      if (workout.durationMinutes != null) '${workout.durationMinutes} min',
      if (workout.difficulty != null) workout.difficulty!,
    ].join(' - ');

    return _AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(IconsaxPlusLinear.activity, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title, style: AppTextStyles.h3),
                if (workout.description != null) ...[
                  const SizedBox(height: 4),
                  Text(workout.description!),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (workout.trainer != null)
                  Text(
                    'Trainer: ${workout.trainer!.fullName}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile(this.schedule);

  final TrainingSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final title = schedule.workout?.title ?? 'Training session';
    return _AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            IconsaxPlusLinear.calendar_1,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  '${_date(schedule.date)} ${schedule.startTime ?? ''}-${schedule.endTime ?? ''}',
                ),
                if (schedule.notes != null) Text(schedule.notes!),
                Text(
                  schedule.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.notification, {this.onRead, this.onDelete});

  final MemberNotification notification;
  final VoidCallback? onRead;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.readStatus == 'UNREAD';

    return _AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUnread
                ? IconsaxPlusLinear.notification
                : IconsaxPlusLinear.tick_circle,
            color: isUnread ? AppColors.accentPurple : AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(notification.message),
                const SizedBox(height: 4),
                Text(
                  '${notification.type} - ${notification.readStatus}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRead != null && isUnread)
            IconButton(
              tooltip: 'Mark read',
              onPressed: onRead,
              icon: const Icon(IconsaxPlusLinear.tick_circle),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(IconsaxPlusLinear.trash),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.h2)),
          if (action != null)
            TextButton(onPressed: onTap, child: Text(action!)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _PlainEmpty extends StatelessWidget {
  const _PlainEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.backgroundWhite,
        borderRadius: DesignTokens.borderRadiusMedium,
        boxShadow: AppShadows.cardShadows,
      ),
      child: child,
    );
  }
}

_MembershipViewState _membershipState(
  MemberSubscription? subscription, {
  bool fallbackActive = false,
}) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final expiry = subscription?.expiryDate;
  final rawStatus = subscription?.status.toUpperCase();
  final plan = subscription?.plan;
  final planName = _displayPlanName(plan);

  if (subscription == null && fallbackActive) {
    return _MembershipViewState(
      status: _MembershipStatus.active,
      label: 'Active',
      color: AppColors.success,
      daysLeftText: 'Active',
      planName: planName,
      expiryText: 'Expiry not set',
      message: 'Your membership is active',
    );
  }

  final isExpired =
      subscription == null ||
      rawStatus != 'ACTIVE' ||
      expiry == null ||
      expiry.isBefore(startOfToday);

  if (isExpired) {
    return _MembershipViewState(
      status: _MembershipStatus.expired,
      label: 'Expired',
      color: AppColors.error,
      daysLeftText: 'Expired',
      planName: planName,
      expiryText: expiry == null
          ? 'No expiry date'
          : 'Expired on ${_date(expiry)}',
      message: 'Your membership has expired',
    );
  }

  final daysLeft = expiry.difference(startOfToday).inDays;
  if (daysLeft <= 7) {
    return _MembershipViewState(
      status: _MembershipStatus.expiringSoon,
      label: 'Expiring Soon',
      color: AppColors.warning,
      daysLeftText: '$daysLeft days left',
      planName: planName,
      expiryText: 'Expires on ${_date(expiry)}',
      message: 'Your plan expires soon',
    );
  }

  return _MembershipViewState(
    status: _MembershipStatus.active,
    label: 'Active',
    color: AppColors.success,
    daysLeftText: '$daysLeft days left',
    planName: planName,
    expiryText: 'Expires on ${_date(expiry)}',
    message: 'Your membership is active',
  );
}

String _displayPlanName(MembershipPlan? plan) {
  final name = plan?.name.trim();
  if (name != null && name.isNotEmpty) return name;

  final type = plan?.type.trim();
  if (type == null || type.isEmpty) return 'Membership Plan';

  return type
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');
}

String _trainingStatusLabel(String? status) {
  return switch (status?.toUpperCase()) {
    'COMPLETED' => 'Completed',
    'IN_PROGRESS' => 'In Progress',
    _ => 'Not Started',
  };
}

Color _trainingStatusColor(String? status) {
  return switch (status?.toUpperCase()) {
    'COMPLETED' => AppColors.success,
    'IN_PROGRESS' => AppColors.warning,
    _ => AppColors.primaryBlue,
  };
}

String _relativeDate(DateTime? date) {
  if (date == null) return 'Soon';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = target.difference(today).inDays;

  return switch (difference) {
    0 => 'Today',
    1 => 'Tomorrow',
    > 1 && <= 7 => 'In $difference days',
    _ => _date(date),
  };
}

String _money(double amount, String currency) {
  final clean = amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);
  return '$clean $currency';
}

String _date(DateTime? date) {
  if (date == null) return '-';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String? _optionalText(TextEditingController controller) {
  final value = controller.text.trim();
  return value.isEmpty ? null : value;
}

bool _isSomaliaMobilePhone(String phone) {
  return RegExp(r'^2526[123]\d{7}$').hasMatch(phone);
}
