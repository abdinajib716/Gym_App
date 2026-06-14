import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/core.dart';
import '../../../core/utils/mobile_phone.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/state/auth_controller.dart';
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
  MemberSubscription? _currentSubscription;
  List<MemberSubscription> _subscriptions = [];
  List<MembershipPlan> _plans = [];
  List<MemberPayment> _payments = [];
  List<MemberNotification> _notifications = [];

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
        widget.memberApi.currentSubscription(),
        widget.memberApi.subscriptionHistory(),
        widget.memberApi.plans(),
        widget.memberApi.paymentHistory(),
        widget.memberApi.notifications(),
      ]);

      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as MemberDashboard;
        _currentSubscription = results[1] as MemberSubscription?;
        _subscriptions = results[2] as List<MemberSubscription>;
        _plans = results[3] as List<MembershipPlan>;
        _payments = results[4] as List<MemberPayment>;
        _notifications = results[5] as List<MemberNotification>;
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
      final subscription = await widget.memberApi.renew(planId: plan?.id);
      _showMessage('Renewal created. Complete payment to activate it.');
      await _loadAll();
      if (!mounted) return;
      await _openPaymentSheet(subscription, plan ?? subscription.plan);
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
        onPaymentChanged: _loadAll,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _title,
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadAll,
            icon: const Icon(IconsaxPlusLinear.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: widget.authController.logout,
            icon: const Icon(IconsaxPlusLinear.logout_1),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavItem(icon: IconsaxPlusLinear.home_1, label: 'Home'),
          BottomNavItem(icon: IconsaxPlusLinear.card, label: 'Plans'),
          BottomNavItem(icon: IconsaxPlusLinear.receipt_1, label: 'Payments'),
          BottomNavItem(icon: IconsaxPlusLinear.notification, label: 'Alerts'),
          BottomNavItem(icon: IconsaxPlusLinear.profile, label: 'Account'),
        ],
      ),
    );
  }

  String get _title {
    return switch (_currentIndex) {
      1 => 'Plans',
      2 => 'Payments',
      3 => 'Notifications',
      4 => 'Account',
      _ => 'Dashboard',
    };
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
            1 => _PlansTab(plans: _plans, onUpgrade: _upgrade, onRenew: _renew),
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
            4 => _AccountTab(
              dashboard: _dashboard,
              authController: widget.authController,
            ),
            _ => _DashboardTab(
              dashboard: _dashboard,
              currentSubscription: _currentSubscription,
              subscriptions: _subscriptions,
              payments: _payments,
              notifications: _notifications,
              onRenew: () => _renew(_currentSubscription?.plan),
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
    required this.currentSubscription,
    required this.subscriptions,
    required this.payments,
    required this.notifications,
    required this.onRenew,
  });

  final MemberDashboard? dashboard;
  final MemberSubscription? currentSubscription;
  final List<MemberSubscription> subscriptions;
  final List<MemberPayment> payments;
  final List<MemberNotification> notifications;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final summary = dashboard?.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${dashboard?.member.fullName ?? 'Member'}',
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(
              label: 'Subscription',
              value: summary?.hasActiveSubscription == true
                  ? 'Active'
                  : 'Inactive',
              icon: IconsaxPlusLinear.medal_star,
            ),
            _MetricTile(
              label: 'Payments',
              value: '${summary?.paymentCount ?? payments.length}',
              icon: IconsaxPlusLinear.receipt_1,
            ),
            _MetricTile(
              label: 'Unread',
              value: '${summary?.unreadNotifications ?? 0}',
              icon: IconsaxPlusLinear.notification,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: 'Current Subscription',
          action: 'Renew',
          onTap: onRenew,
        ),
        if (currentSubscription == null)
          const EmptyState(
            icon: IconsaxPlusLinear.card_remove,
            title: 'No active subscription',
            message: 'Choose a plan to create a renewal or upgrade request.',
          )
        else
          _SubscriptionCard(subscription: currentSubscription!),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Recent Payments'),
        ...payments.take(3).map(_PaymentTile.new),
        if (payments.isEmpty) const _PlainEmpty(message: 'No payments yet.'),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Latest Notifications'),
        ...notifications.take(3).map(_NotificationTile.readOnly),
        if (notifications.isEmpty)
          const _PlainEmpty(message: 'No notifications yet.'),
        if (subscriptions.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionTitle(title: 'Subscription History'),
          ...subscriptions.take(3).map(_SubscriptionCard.compact),
        ],
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
  const _AccountTab({required this.dashboard, required this.authController});

  final MemberDashboard? dashboard;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final member = dashboard?.member;
    final account = dashboard?.account;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member?.fullName ?? authController.user?.name ?? 'Member',
                style: AppTextStyles.h1,
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
              _InfoRow(
                label: 'Must change password',
                value: account?.mustChangePassword == true ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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

class _WaafiPaymentSheet extends StatefulWidget {
  const _WaafiPaymentSheet({
    required this.api,
    required this.subscription,
    required this.plan,
    required this.onPaymentChanged,
  });

  final MemberApi api;
  final MemberSubscription subscription;
  final MembershipPlan? plan;
  final Future<void> Function() onPaymentChanged;

  @override
  State<_WaafiPaymentSheet> createState() => _WaafiPaymentSheetState();
}

class _WaafiPaymentSheetState extends State<_WaafiPaymentSheet> {
  final _phoneController = TextEditingController();
  String _provider = 'EVC_PLUS';
  bool _busy = false;
  String? _message;
  MemberPayment? _payment;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      final payment = await widget.api.initiateWaafiPayment(
        subscriptionId: widget.subscription.id,
        provider: _provider,
        phoneNumber: normalizeSomaliaPhone(_phoneController.text),
        amount: widget.plan?.price ?? 0,
        currency: widget.plan?.currency ?? 'USD',
      );
      setState(() {
        _payment = payment;
        _message = 'Payment initiated. Confirm the prompt on your phone.';
      });
      await widget.onPaymentChanged();
      _pollStatus(payment.id);
    } on ApiException catch (error) {
      setState(() => _message = error.message);
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
        setState(() {
          _payment = payment;
          _message = 'Payment status: ${payment.status}';
        });
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
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: AppTextStyles.bodySmall),
          ],
          if (_payment?.failedReason != null) ...[
            const SizedBox(height: 8),
            Text(
              _payment!.failedReason!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      child: _AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryBlue),
            const SizedBox(height: 10),
            Text(value, style: AppTextStyles.h2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription}) : compact = false;
  const _SubscriptionCard.compact(this.subscription) : compact = true;

  final MemberSubscription subscription;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subscription.plan?.name ?? 'Subscription',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Status', value: subscription.status),
          _InfoRow(label: 'Payment', value: subscription.paymentStatus),
          if (!compact) ...[
            _InfoRow(label: 'Start', value: _date(subscription.startDate)),
            _InfoRow(label: 'Expiry', value: _date(subscription.expiryDate)),
          ],
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.notification, {this.onRead, this.onDelete});
  const _NotificationTile.readOnly(this.notification)
    : onRead = null,
      onDelete = null;

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
