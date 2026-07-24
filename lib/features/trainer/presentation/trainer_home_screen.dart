import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/core.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/state/auth_controller.dart';
import '../../member/data/member_models.dart';
import '../../store/presentation/store_tab.dart';
import '../../training/data/training_models.dart';
import '../data/trainer_api.dart';
import '../data/trainer_models.dart';
import 'trainer_password_change_screen.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({
    super.key,
    required this.authController,
    required this.trainerApi,
  });

  final AuthController authController;
  final TrainerApi trainerApi;

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  String? _loadWarning;
  TrainerDashboard? _dashboard;
  TrainerProfile? _profile;
  List<TrainerMember> _members = [];
  List<TrainerGroup> _groups = [];
  List<TrainingWorkout> _workouts = [];
  List<TrainingSchedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final isInitialLoad =
        _dashboard == null &&
        _profile == null &&
        _members.isEmpty &&
        _workouts.isEmpty &&
        _schedules.isEmpty;

    setState(() {
      _loading = isInitialLoad;
      _error = null;
      _loadWarning = null;
    });

    final failures = <String>[];
    final results = await Future.wait<dynamic>([
      _optional('dashboard', widget.trainerApi.dashboard(), failures),
      _optional('profile', widget.trainerApi.profile(), failures),
      _optional('members', widget.trainerApi.members(), failures),
      _optional('groups', widget.trainerApi.groups(), failures),
      _optional('workouts', widget.trainerApi.workouts(), failures),
      _optional('schedules', widget.trainerApi.schedules(), failures),
    ]);

    final dashboard = results[0] as TrainerDashboard?;
    final profile =
        results[1] as TrainerProfile? ?? _profile ?? _profileFromSession();
    var members = results[2] as List<TrainerMember>? ?? _members;
    if (members.isEmpty && dashboard?.recentMembers.isNotEmpty == true) {
      members = dashboard!.recentMembers;
    }
    final groups = results[3] as List<TrainerGroup>? ?? _groups;
    final workouts = results[4] as List<TrainingWorkout>? ?? _workouts;
    final schedules = results[5] as List<TrainingSchedule>? ?? _schedules;

    if (!mounted) return;
    setState(() {
      _dashboard = dashboard;
      _profile = profile;
      _members = members;
      _groups = groups;
      _workouts = workouts;
      _schedules = schedules;
      _loadWarning = failures.isEmpty
          ? null
          : 'Some trainer sections are not available yet: ${failures.join(', ')}.';
      _loading = false;
    });
  }

  Future<T?> _optional<T>(
    String label,
    Future<T> future,
    List<String> failures,
  ) async {
    try {
      return await future;
    } on ApiException {
      failures.add(label);
      return null;
    }
  }

  TrainerProfile _profileFromSession() {
    final user = widget.authController.user;
    return TrainerProfile(
      id: user?.id ?? '',
      fullName: user?.name ?? 'Trainer',
      phoneNumber: user?.phone,
      email: user?.email,
      status: user?.accountStatus,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    AppSnackBar.info(context, message);
  }

  Future<void> _openMember(TrainerMember member) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _MemberDetailSheet(api: widget.trainerApi, member: member),
    );
  }

  Future<void> _openGroupSheet([TrainerGroup? group]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _GroupSheet(
        api: widget.trainerApi,
        group: group,
        members: _members,
        onChanged: _loadAll,
      ),
    );
  }

  Future<void> _openGroupDetail(TrainerGroup group) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _GroupDetailSheet(
        api: widget.trainerApi,
        group: group,
        members: _members,
        onChanged: _loadAll,
      ),
    );
  }

  Future<void> _openWorkoutSheet([TrainingWorkout? workout]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WorkoutSheet(
        api: widget.trainerApi,
        members: _members,
        groups: _groups,
        workout: workout,
        onChanged: _loadAll,
      ),
    );
  }

  Future<void> _openScheduleSheet([TrainingSchedule? schedule]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ScheduleSheet(
        api: widget.trainerApi,
        members: _members,
        groups: _groups,
        workouts: _workouts,
        schedule: schedule,
        onChanged: _loadAll,
      ),
    );
  }

  Future<void> _deleteWorkout(TrainingWorkout workout) async {
    try {
      await widget.trainerApi.deleteWorkout(workout.id);
      _showMessage('Workout deleted');
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _deleteSchedule(TrainingSchedule schedule) async {
    try {
      await widget.trainerApi.deleteSchedule(schedule.id);
      _showMessage('Schedule deleted');
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _deleteGroup(TrainerGroup group) async {
    try {
      await widget.trainerApi.deleteGroup(group.id);
      _showMessage('Group deleted');
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _completeSchedule(TrainingSchedule schedule) async {
    try {
      await widget.trainerApi.completeSchedule(schedule.id);
      _showMessage('Schedule completed');
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _cancelSchedule(TrainingSchedule schedule) async {
    try {
      await widget.trainerApi.cancelSchedule(schedule.id);
      _showMessage('Schedule cancelled');
      await _loadAll();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  int get _bottomNavIndex {
    return switch (_currentIndex) {
      0 => 0,
      1 => 1,
      2 => 2,
      _ => 3,
    };
  }

  Future<void> _openPasswordSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TrainerPasswordChangeSheet(
        authController: widget.authController,
        trainerApi: widget.trainerApi,
      ),
    );
  }

  Future<void> _openTrainerProfileSheet() async {
    final profile = _profile ?? _profileFromSession();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TrainerProfileSheet(
        api: widget.trainerApi,
        profile: profile,
        onChanged: _loadAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: const BrandLogo.appBar(),
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showMessage('Trainer notifications coming soon'),
            icon: const Icon(IconsaxPlusLinear.notification),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadAll,
            icon: const Icon(IconsaxPlusLinear.refresh),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _currentIndex == 4
          ? FloatingActionButton(
              onPressed: () => _openWorkoutSheet(),
              child: const Icon(Icons.add),
            )
          : _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () => _openScheduleSheet(),
              child: const Icon(Icons.add),
            )
          : _currentIndex == 7
          ? FloatingActionButton(
              onPressed: () => _openGroupSheet(),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = switch (index) {
              0 => 0,
              1 => 1,
              2 => 2,
              _ => 3,
            };
          });
        },
        items: const [
          BottomNavItem(icon: IconsaxPlusLinear.home_1, label: 'Home'),
          BottomNavItem(icon: IconsaxPlusLinear.profile, label: 'Members'),
          BottomNavItem(icon: IconsaxPlusLinear.calendar_1, label: 'Schedule'),
          BottomNavItem(icon: Icons.more_horiz, label: 'More'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: LoadingIndicator(size: 36));
    if (_error != null) return ErrorView(message: _error!, onRetry: _loadAll);

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        children: [
          if (_loadWarning != null) ...[
            _WarningBanner(message: _loadWarning!),
            const SizedBox(height: 12),
          ],
          switch (_currentIndex) {
            1 => _MembersTab(
              api: widget.trainerApi,
              members: _members,
              onOpenMember: _openMember,
            ),
            2 => _SchedulesTab(
              schedules: _schedules,
              onEdit: _openScheduleSheet,
              onDelete: _deleteSchedule,
              onComplete: _completeSchedule,
              onCancel: _cancelSchedule,
            ),
            4 => _WorkoutsTab(
              workouts: _workouts,
              onEdit: _openWorkoutSheet,
              onDelete: _deleteWorkout,
            ),
            5 => _AccountTab(
              profile: _profile,
              authController: widget.authController,
              trainerApi: widget.trainerApi,
              onEditProfile: _openTrainerProfileSheet,
            ),
            6 => StoreTab(
              products: widget.trainerApi.storeProducts,
              orders: widget.trainerApi.storeOrders,
              productDetail: widget.trainerApi.storeProductDetail,
              orderDetail: widget.trainerApi.storeOrderDetail,
              purchase: widget.trainerApi.purchaseStoreProduct,
              defaultPhone:
                  _profile?.phoneNumber ?? widget.authController.user?.phone,
            ),
            7 => _GroupsTab(
              groups: _groups,
              onCreate: () => _openGroupSheet(),
              onOpen: _openGroupDetail,
              onEdit: _openGroupSheet,
              onDelete: _deleteGroup,
            ),
            3 => _TrainerMoreTab(
              profile: _profile,
              membersCount: _members.length,
              groupsCount: _groups.length,
              workoutsCount: _workouts.length,
              schedulesCount: _schedules.length,
              onOpenWorkouts: () => setState(() => _currentIndex = 4),
              onOpenGroups: () => setState(() => _currentIndex = 7),
              onOpenStore: () => setState(() => _currentIndex = 6),
              onOpenAccount: () => setState(() => _currentIndex = 5),
              onChangePassword: _openPasswordSheet,
              onLogout: widget.authController.logout,
            ),
            _ => _DashboardTab(
              profile: _profile,
              dashboard: _dashboard,
              members: _members,
              schedules: _schedules,
              workouts: _workouts,
            ),
          },
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.profile,
    required this.dashboard,
    required this.members,
    required this.schedules,
    required this.workouts,
  });

  final TrainerProfile? profile;
  final TrainerDashboard? dashboard;
  final List<TrainerMember> members;
  final List<TrainingSchedule> schedules;
  final List<TrainingWorkout> workouts;

  @override
  Widget build(BuildContext context) {
    final kpis = dashboard?.kpis;
    final dashboardTrainerName = dashboard?.trainer.fullName ?? '';
    final trainerName = dashboardTrainerName.isEmpty
        ? 'Trainer'
        : dashboardTrainerName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHero(
          title: 'Welcome, $trainerName',
          subtitle: dashboard?.trainer.specialty ?? 'Trainer workspace',
          icon: IconsaxPlusLinear.user_octagon,
          profileImage:
              profile?.profileImage ?? dashboard?.trainer.profileImage,
          stats: [
            _HeroStat(
              label: 'Members',
              value: '${kpis?.totalMembers ?? members.length}',
            ),
            _HeroStat(label: 'Today', value: '${kpis?.todaySessions ?? 0}'),
          ],
        ),
        const SizedBox(height: 18),
        _MetricGrid(
          children: [
            _MetricTile(
              label: 'Members',
              value: '${kpis?.totalMembers ?? members.length}',
              icon: IconsaxPlusLinear.profile,
              tone: AppColors.primaryBlue,
            ),
            _MetricTile(
              label: 'Groups',
              value: '${kpis?.totalGroups ?? 0}',
              icon: IconsaxPlusLinear.user_octagon,
              tone: AppColors.accentPurple,
            ),
            _MetricTile(
              label: 'Today',
              value: '${kpis?.todaySessions ?? 0}',
              icon: IconsaxPlusLinear.calendar_1,
              tone: AppColors.info,
            ),
            _MetricTile(
              label: 'Workouts',
              value: '${workouts.length}',
              icon: IconsaxPlusLinear.activity,
              tone: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Today Schedule'),
        if ((dashboard?.todaySchedule ?? schedules).isEmpty)
          const _PlainEmpty(message: 'No sessions scheduled today.'),
        ...(dashboard?.todaySchedule ?? schedules)
            .take(4)
            .map(_ScheduleTile.new),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Recent Members'),
        if ((dashboard?.recentMembers ?? members).isEmpty)
          const _PlainEmpty(message: 'No assigned members yet.'),
        ...(dashboard?.recentMembers ?? members)
            .take(4)
            .map(_MemberTile.readOnly),
      ],
    );
  }
}

class _MembersTab extends StatefulWidget {
  const _MembersTab({
    required this.api,
    required this.members,
    required this.onOpenMember,
  });

  final TrainerApi api;
  final List<TrainerMember> members;
  final Future<void> Function(TrainerMember member) onOpenMember;

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  final _search = TextEditingController();
  List<TrainerMember>? _results;
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String value) async {
    setState(() => _busy = true);
    try {
      final results = await widget.api.members(search: value);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = _results ?? widget.members;
    if (widget.members.isEmpty && members.isEmpty) {
      return const EmptyState(
        icon: IconsaxPlusLinear.profile,
        title: 'No assigned members',
        message: 'Assigned members will appear here.',
      );
    }

    return Column(
      children: [
        SearchTextField(
          controller: _search,
          hintText: 'Search members',
          onSubmitted: _runSearch,
          onChanged: (value) {
            if (value.trim().isEmpty) setState(() => _results = null);
          },
        ),
        if (_busy)
          const Padding(
            padding: EdgeInsets.all(12),
            child: LoadingIndicator(size: 22),
          ),
        const SizedBox(height: 12),
        ...members.map(
          (member) =>
              _MemberTile(member, onTap: () => widget.onOpenMember(member)),
        ),
      ],
    );
  }
}

class _WorkoutsTab extends StatelessWidget {
  const _WorkoutsTab({
    required this.workouts,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TrainingWorkout> workouts;
  final Future<void> Function(TrainingWorkout workout) onEdit;
  final Future<void> Function(TrainingWorkout workout) onDelete;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const EmptyState(
        icon: IconsaxPlusLinear.activity,
        title: 'No workouts',
        message: 'Create a workout and assign it to a member or group.',
      );
    }

    return Column(
      children: workouts
          .map(
            (workout) => _WorkoutTile(
              workout,
              onEdit: () => onEdit(workout),
              onDelete: () => onDelete(workout),
            ),
          )
          .toList(),
    );
  }
}

class _SchedulesTab extends StatelessWidget {
  const _SchedulesTab({
    required this.schedules,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
    required this.onCancel,
  });

  final List<TrainingSchedule> schedules;
  final Future<void> Function(TrainingSchedule schedule) onEdit;
  final Future<void> Function(TrainingSchedule schedule) onDelete;
  final Future<void> Function(TrainingSchedule schedule) onComplete;
  final Future<void> Function(TrainingSchedule schedule) onCancel;

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const EmptyState(
        icon: IconsaxPlusLinear.calendar_1,
        title: 'No schedules',
        message: 'Create sessions for assigned members or groups.',
      );
    }

    return Column(
      children: schedules
          .map(
            (schedule) => _ScheduleTile(
              schedule,
              onEdit: () => onEdit(schedule),
              onDelete: () => onDelete(schedule),
              onComplete: schedule.status == 'UPCOMING'
                  ? () => onComplete(schedule)
                  : null,
              onCancel: schedule.status == 'UPCOMING'
                  ? () => onCancel(schedule)
                  : null,
            ),
          )
          .toList(),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.profile,
    required this.authController,
    required this.trainerApi,
    required this.onEditProfile,
  });

  final TrainerProfile? profile;
  final AuthController authController;
  final TrainerApi trainerApi;
  final VoidCallback onEditProfile;

  Future<void> _openPasswordSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TrainerPasswordChangeSheet(
        authController: authController,
        trainerApi: trainerApi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        profile?.profileImage ??
                        authController.user?.profileImage,
                    fallbackIcon: IconsaxPlusLinear.user_octagon,
                    size: 58,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      profile?.fullName ??
                          authController.user?.name ??
                          'Trainer',
                      style: AppTextStyles.h1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoRow(label: 'Phone', value: profile?.phoneNumber ?? '-'),
              _InfoRow(label: 'Email', value: profile?.email ?? '-'),
              _InfoRow(label: 'Specialty', value: profile?.specialty ?? '-'),
              _InfoRow(
                label: 'Availability',
                value: profile?.availability ?? '-',
              ),
              _InfoRow(label: 'Status', value: profile?.status ?? '-'),
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
          text: 'Change Password',
          icon: IconsaxPlusLinear.lock,
          type: ButtonType.outline,
          onPressed: () => _openPasswordSheet(context),
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

class _TrainerMoreTab extends StatelessWidget {
  const _TrainerMoreTab({
    required this.profile,
    required this.membersCount,
    required this.groupsCount,
    required this.workoutsCount,
    required this.schedulesCount,
    required this.onOpenWorkouts,
    required this.onOpenGroups,
    required this.onOpenStore,
    required this.onOpenAccount,
    required this.onChangePassword,
    required this.onLogout,
  });

  final TrainerProfile? profile;
  final int membersCount;
  final int groupsCount;
  final int workoutsCount;
  final int schedulesCount;
  final VoidCallback onOpenWorkouts;
  final VoidCallback onOpenGroups;
  final VoidCallback onOpenStore;
  final VoidCallback onOpenAccount;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppCard(
          child: Row(
            children: [
              AppAvatar(
                image: profile?.profileImage,
                fallbackIcon: IconsaxPlusLinear.user_octagon,
                size: 54,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.fullName ?? 'Trainer',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.specialty ??
                          profile?.email ??
                          'Trainer workspace',
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
        _MetricGrid(
          children: [
            _MetricTile(
              label: 'Members',
              value: '$membersCount',
              icon: IconsaxPlusLinear.profile,
              tone: AppColors.primaryBlue,
            ),
            _MetricTile(
              label: 'Workouts',
              value: '$workoutsCount',
              icon: IconsaxPlusLinear.activity,
              tone: AppColors.success,
            ),
            _MetricTile(
              label: 'Groups',
              value: '$groupsCount',
              icon: IconsaxPlusLinear.calendar_1,
              tone: AppColors.info,
            ),
            _MetricTile(
              label: 'Schedules',
              value: '$schedulesCount',
              icon: IconsaxPlusLinear.calendar_1,
              tone: AppColors.accentPurple,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TrainerMoreActionTile(
          icon: IconsaxPlusLinear.user_octagon,
          title: 'Groups',
          subtitle: 'Create groups and manage group members',
          onTap: onOpenGroups,
        ),
        _TrainerMoreActionTile(
          icon: IconsaxPlusLinear.activity,
          title: 'Workouts',
          subtitle: 'Create, edit, assign, and delete workouts',
          onTap: onOpenWorkouts,
        ),
        _TrainerMoreActionTile(
          icon: Icons.storefront,
          title: 'Store',
          subtitle: 'Buy products and review store orders',
          onTap: onOpenStore,
        ),
        _TrainerMoreActionTile(
          icon: IconsaxPlusLinear.user_octagon,
          title: 'Account',
          subtitle: 'Profile and trainer details',
          onTap: onOpenAccount,
        ),
        _TrainerMoreActionTile(
          icon: IconsaxPlusLinear.lock,
          title: 'Change Password',
          subtitle: 'Update your trainer login password',
          onTap: onChangePassword,
        ),
        _TrainerMoreActionTile(
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

class _TrainerMoreActionTile extends StatelessWidget {
  const _TrainerMoreActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _MemberDetailSheet extends StatefulWidget {
  const _MemberDetailSheet({required this.api, required this.member});

  final TrainerApi api;
  final TrainerMember member;

  @override
  State<_MemberDetailSheet> createState() => _MemberDetailSheetState();
}

class _MemberDetailSheetState extends State<_MemberDetailSheet> {
  late Future<TrainerMemberDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.memberDetail(widget.member.id);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: widget.member.fullName,
      child: FutureBuilder<TrainerMemberDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: LoadingIndicator(size: 28));
          }
          if (snapshot.hasError) {
            return Text(
              snapshot.error.toString(),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            );
          }
          final detail = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(
                    image: detail.member.profileImage,
                    fallbackIcon: IconsaxPlusLinear.profile,
                    size: 58,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      detail.member.fullName,
                      style: AppTextStyles.h2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Phone', value: detail.member.phoneNumber ?? '-'),
              _InfoRow(label: 'Email', value: detail.member.email ?? '-'),
              _InfoRow(label: 'Status', value: detail.member.status ?? '-'),
              const SizedBox(height: 16),
              _MemberProgressCard(detail: detail),
              const SizedBox(height: 16),
              _MemberAttendanceFilterCard(
                api: widget.api,
                memberId: detail.member.id,
                initialRows: detail.recentAttendance,
              ),
              const SizedBox(height: 16),
              const _SectionTitle(title: 'Recent Workouts'),
              if (detail.recentWorkouts.isEmpty)
                const _PlainEmpty(message: 'No recent workouts.'),
              ...detail.recentWorkouts.take(3).map(_WorkoutTile.readOnly),
              const SizedBox(height: 16),
              const _SectionTitle(title: 'Recent Schedules'),
              if (detail.recentSchedules.isEmpty)
                const _PlainEmpty(message: 'No recent schedules.'),
              ...detail.recentSchedules.take(3).map(_ScheduleTile.new),
            ],
          );
        },
      ),
    );
  }
}

class _MemberProgressCard extends StatelessWidget {
  const _MemberProgressCard({required this.detail});

  final TrainerMemberDetail detail;

  @override
  Widget build(BuildContext context) {
    final progress = detail.progress;
    final training = progress?.training;
    final attendance = progress?.attendance;
    final totalSchedules =
        training?.totalSchedules ?? detail.recentSchedules.length;
    final completedSchedules =
        training?.completedSchedules ??
        _countSchedules(detail.recentSchedules, 'COMPLETED');
    final upcomingSchedules =
        training?.upcomingSchedules ??
        _countSchedules(detail.recentSchedules, 'UPCOMING');
    final missedSchedules =
        training?.missedSchedules ??
        _countSchedules(detail.recentSchedules, 'MISSED');
    final completionRate =
        training?.completionRate ??
        (totalSchedules == 0
            ? 0
            : ((completedSchedules / totalSchedules) * 100).round());
    final activeWorkouts =
        training?.activeWorkouts ?? detail.recentWorkouts.length;
    final presentInRange =
        attendance?.presentInRange ?? _countAttendance(detail.recentAttendance);
    final presentThisMonth =
        attendance?.presentThisMonth ??
        _countAttendanceThisMonth(detail.recentAttendance);
    final lastCheckIn =
        attendance?.lastCheckIn?.checkInDate ??
        _latestAttendanceDate(detail.recentAttendance);
    final subscriptionStatus =
        progress?.subscription?.status ??
        _latestSubscriptionStatus(detail.subscriptionHistory);
    final clampedRate = completionRate.clamp(0, 100);

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Member Progress'),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
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
                    Text('$clampedRate% complete', style: AppTextStyles.h2),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: clampedRate / 100,
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
                value: '$activeWorkouts',
                color: AppColors.primaryBlue,
              ),
              _CompactMetricTile(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: '$completedSchedules/$totalSchedules',
                color: AppColors.success,
              ),
              _CompactMetricTile(
                icon: IconsaxPlusLinear.calendar_1,
                label: 'Upcoming',
                value: '$upcomingSchedules',
                color: AppColors.info,
              ),
              _CompactMetricTile(
                icon: Icons.warning_amber_rounded,
                label: 'Missed',
                value: '$missedSchedules',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Present in range', value: '$presentInRange'),
          _InfoRow(label: 'Present this month', value: '$presentThisMonth'),
          _InfoRow(label: 'Last check-in', value: _dateString(lastCheckIn)),
          _InfoRow(label: 'Subscription', value: subscriptionStatus ?? '-'),
        ],
      ),
    );
  }
}

class _MemberAttendanceFilterCard extends StatefulWidget {
  const _MemberAttendanceFilterCard({
    required this.api,
    required this.memberId,
    required this.initialRows,
  });

  final TrainerApi api;
  final String memberId;
  final List<Map<String, dynamic>> initialRows;

  @override
  State<_MemberAttendanceFilterCard> createState() =>
      _MemberAttendanceFilterCardState();
}

class _MemberAttendanceFilterCardState
    extends State<_MemberAttendanceFilterCard> {
  final _dateFrom = TextEditingController();
  final _dateTo = TextEditingController();
  final _limit = TextEditingController(text: '50');
  String _period = 'monthly';
  MemberAttendance? _attendance;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dateFrom.dispose();
    _dateTo.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final attendance = await widget.api.memberAttendance(
        widget.memberId,
        period: _period,
        dateFrom: DateTime.tryParse(_dateFrom.text.trim()),
        dateTo: DateTime.tryParse(_dateTo.text.trim()),
        limit: int.tryParse(_limit.text.trim()),
      );
      if (mounted) setState(() => _attendance = attendance);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _attendance?.records ?? const <MemberAttendanceRecord>[];

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Attendance'),
          DropdownButtonFormField<String>(
            initialValue: _period,
            decoration: const InputDecoration(labelText: 'Period'),
            items: const [
              DropdownMenuItem(value: 'today', child: Text('Today')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'all', child: Text('All')),
            ],
            onChanged: (value) => setState(() => _period = value ?? _period),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _dateFrom,
                  labelText: 'From',
                  hintText: '2026-07-01',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  controller: _dateTo,
                  labelText: 'To',
                  hintText: '2026-07-31',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _limit,
            labelText: 'Limit',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Apply Filters',
            icon: IconsaxPlusLinear.filter,
            isLoading: _loading,
            onPressed: _load,
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          if (_attendance != null) ...[
            const SizedBox(height: 12),
            _InfoRow(label: 'Total', value: '${_attendance!.summary.total}'),
            _InfoRow(
              label: 'Present',
              value: '${_attendance!.summary.present}',
            ),
            _InfoRow(
              label: 'Cancelled',
              value: '${_attendance!.summary.cancelled}',
            ),
            _InfoRow(
              label: 'Last check-in',
              value: _dateString(_attendance!.summary.lastCheckIn),
            ),
          ],
          const SizedBox(height: 12),
          if (records.isEmpty && widget.initialRows.isEmpty)
            const _PlainEmpty(message: 'No attendance records.')
          else if (records.isNotEmpty)
            ...records.take(6).map(_AttendanceRecordTile.new)
          else
            ...widget.initialRows.take(5).map(_JsonTile.new),
        ],
      ),
    );
  }
}

class _AttendanceRecordTile extends StatelessWidget {
  const _AttendanceRecordTile(this.record);

  final MemberAttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      label: _dateString(record.checkInDate),
      value: record.status.isEmpty ? record.method : record.status,
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab({
    required this.groups,
    required this.onCreate,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TrainerGroup> groups;
  final VoidCallback onCreate;
  final Future<void> Function(TrainerGroup group) onOpen;
  final Future<void> Function(TrainerGroup group) onEdit;
  final Future<void> Function(TrainerGroup group) onDelete;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return EmptyState(
        icon: IconsaxPlusLinear.user_octagon,
        title: 'No groups',
        message: 'Create trainer groups for shared workouts and schedules.',
        actionText: 'Create Group',
        onActionPressed: onCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups
          .map(
            (group) => _GroupTile(
              group,
              onOpen: () => onOpen(group),
              onEdit: () => onEdit(group),
              onDelete: () => onDelete(group),
            ),
          )
          .toList(),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile(
    this.group, {
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final TrainerGroup group;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: InkWell(
        onTap: onOpen,
        borderRadius: DesignTokens.borderRadiusMedium,
        child: Row(
          children: [
            const AppAvatar(
              image: null,
              fallbackIcon: IconsaxPlusLinear.user_octagon,
              size: 46,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: AppTextStyles.h3),
                  Text(
                    [
                      if (group.trainingDays != null) group.trainingDays!,
                      if (group.trainingTime != null) group.trainingTime!,
                      if (group.memberCount != null)
                        '${group.memberCount} members',
                    ].join(' - '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(IconsaxPlusLinear.trash),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSheet extends StatefulWidget {
  const _GroupSheet({
    required this.api,
    required this.members,
    required this.onChanged,
    this.group,
  });

  final TrainerApi api;
  final List<TrainerMember> members;
  final TrainerGroup? group;
  final Future<void> Function() onChanged;

  @override
  State<_GroupSheet> createState() => _GroupSheetState();
}

class _GroupSheetState extends State<_GroupSheet> {
  late final _name = TextEditingController(text: widget.group?.name ?? '');
  late final _trainingDays = TextEditingController(
    text: widget.group?.trainingDays ?? '',
  );
  late final _trainingTime = TextEditingController(
    text: widget.group?.trainingTime ?? '',
  );
  String _status = 'ACTIVE';
  final Set<String> _memberIds = {};
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _status = widget.group?.status ?? _status;
  }

  @override
  void dispose() {
    _name.dispose();
    _trainingDays.dispose();
    _trainingTime.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _message = 'Group name is required');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final body = {
      'name': _name.text.trim(),
      if (_trainingDays.text.trim().isNotEmpty)
        'trainingDays': _trainingDays.text.trim(),
      if (_trainingTime.text.trim().isNotEmpty)
        'trainingTime': _trainingTime.text.trim(),
      'status': _status,
      if (widget.group == null) 'memberIds': _memberIds.toList(),
    };
    try {
      if (widget.group == null) {
        await widget.api.createGroup(body);
      } else {
        await widget.api.updateGroup(widget.group!.id, body);
      }
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
    return _SheetFrame(
      title: widget.group == null ? 'Create Group' : 'Edit Group',
      child: Column(
        children: [
          CustomTextField(controller: _name, labelText: 'Group name'),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _trainingDays,
            labelText: 'Training days',
            hintText: 'Monday, Wednesday, Friday',
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _trainingTime,
            labelText: 'Training time',
            hintText: '08:00',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
              DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
            ],
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          if (widget.group == null && widget.members.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Members', style: AppTextStyles.labelMedium),
            ),
            const SizedBox(height: 8),
            ...widget.members.map(
              (member) => CheckboxListTile(
                value: _memberIds.contains(member.id),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(member.fullName),
                subtitle: Text(member.phoneNumber ?? member.email ?? '-'),
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _memberIds.add(member.id);
                  } else {
                    _memberIds.remove(member.id);
                  }
                }),
              ),
            ),
          ],
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(text: 'Save Group', isLoading: _busy, onPressed: _save),
        ],
      ),
    );
  }
}

class _GroupDetailSheet extends StatefulWidget {
  const _GroupDetailSheet({
    required this.api,
    required this.group,
    required this.members,
    required this.onChanged,
  });

  final TrainerApi api;
  final TrainerGroup group;
  final List<TrainerMember> members;
  final Future<void> Function() onChanged;

  @override
  State<_GroupDetailSheet> createState() => _GroupDetailSheetState();
}

class _GroupDetailSheetState extends State<_GroupDetailSheet> {
  List<TrainerMember> _members = [];
  List<TrainingWorkout> _workouts = [];
  List<TrainingSchedule> _schedules = [];
  String? _memberToAdd;
  bool _loading = true;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        widget.api.groupMembers(widget.group.id),
        widget.api.groupWorkouts(widget.group.id),
        widget.api.groupSchedules(widget.group.id),
      ]);
      if (!mounted) return;
      setState(() {
        _members = results[0] as List<TrainerMember>;
        _workouts = results[1] as List<TrainingWorkout>;
        _schedules = results[2] as List<TrainingSchedule>;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _addMember() async {
    final memberId = _memberToAdd;
    if (memberId == null) return;
    setState(() => _busy = true);
    try {
      await widget.api.addGroupMembers(widget.group.id, [memberId]);
      await widget.onChanged();
      await _load();
      setState(() => _memberToAdd = null);
    } on ApiException catch (error) {
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeMember(TrainerMember member) async {
    setState(() => _busy = true);
    try {
      await widget.api.removeGroupMember(widget.group.id, member.id);
      await widget.onChanged();
      await _load();
    } on ApiException catch (error) {
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMembers = widget.members
        .where((member) => !_members.any((current) => current.id == member.id))
        .toList();

    return _SheetFrame(
      title: widget.group.name,
      child: _loading
          ? const Center(child: LoadingIndicator(size: 28))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Training days',
                  value: widget.group.trainingDays ?? '-',
                ),
                _InfoRow(
                  label: 'Training time',
                  value: widget.group.trainingTime ?? '-',
                ),
                _InfoRow(label: 'Status', value: widget.group.status ?? '-'),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Members'),
                if (availableMembers.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _memberToAdd,
                    decoration: const InputDecoration(labelText: 'Add member'),
                    items: availableMembers
                        .map(
                          (member) => DropdownMenuItem(
                            value: member.id,
                            child: Text(member.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _memberToAdd = value),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Add Member',
                    size: ButtonSize.small,
                    isLoading: _busy,
                    onPressed: _memberToAdd == null ? null : _addMember,
                  ),
                  const SizedBox(height: 10),
                ],
                if (_members.isEmpty)
                  const _PlainEmpty(message: 'No group members yet.')
                else
                  ..._members.map(
                    (member) => _AppCard(
                      child: Row(
                        children: [
                          AppAvatar(
                            image: member.profileImage,
                            fallbackIcon: IconsaxPlusLinear.profile,
                            size: 38,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(member.fullName)),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: _busy
                                ? null
                                : () => _removeMember(member),
                            icon: const Icon(IconsaxPlusLinear.trash),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Group Workouts'),
                if (_workouts.isEmpty)
                  const _PlainEmpty(message: 'No group workouts.')
                else
                  ..._workouts.take(4).map(_WorkoutTile.readOnly),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Group Schedules'),
                if (_schedules.isEmpty)
                  const _PlainEmpty(message: 'No group schedules.')
                else
                  ..._schedules.take(4).map(_ScheduleTile.new),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _TrainerProfileSheet extends StatefulWidget {
  const _TrainerProfileSheet({
    required this.api,
    required this.profile,
    required this.onChanged,
  });

  final TrainerApi api;
  final TrainerProfile profile;
  final Future<void> Function() onChanged;

  @override
  State<_TrainerProfileSheet> createState() => _TrainerProfileSheetState();
}

class _TrainerProfileSheetState extends State<_TrainerProfileSheet> {
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _phone = TextEditingController(
    text: widget.profile.phoneNumber ?? '',
  );
  late final _email = TextEditingController(text: widget.profile.email ?? '');
  late final _gender = TextEditingController(text: widget.profile.gender ?? '');
  late final _specialty = TextEditingController(
    text: widget.profile.specialty ?? '',
  );
  late final _availability = TextEditingController(
    text: widget.profile.availability ?? '',
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
    _specialty.dispose();
    _availability.dispose();
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
        TrainerProfile(
          id: widget.profile.id,
          fullName: _name.text.trim(),
          phoneNumber: _optionalText(_phone),
          email: _optionalText(_email),
          gender: _optionalText(_gender),
          specialty: _optionalText(_specialty),
          availability: _optionalText(_availability),
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
    return _SheetFrame(
      title: 'Edit Profile',
      child: Column(
        children: [
          AppAvatar(
            image: _profileImage.text,
            fallbackIcon: IconsaxPlusLinear.user_octagon,
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
          CustomTextField(controller: _specialty, labelText: 'Specialty'),
          const SizedBox(height: 12),
          CustomTextField(controller: _availability, labelText: 'Availability'),
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

class _WorkoutSheet extends StatefulWidget {
  const _WorkoutSheet({
    required this.api,
    required this.members,
    required this.groups,
    required this.onChanged,
    this.workout,
  });

  final TrainerApi api;
  final List<TrainerMember> members;
  final List<TrainerGroup> groups;
  final TrainingWorkout? workout;
  final Future<void> Function() onChanged;

  @override
  State<_WorkoutSheet> createState() => _WorkoutSheetState();
}

class _WorkoutSheetState extends State<_WorkoutSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _category = TextEditingController();
  final _sets = TextEditingController();
  final _reps = TextEditingController();
  final _duration = TextEditingController();
  String _difficulty = 'BEGINNER';
  String _status = 'ACTIVE';
  String? _memberId;
  String? _groupId;
  String? _imageUrl;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final workout = widget.workout;
    if (workout != null) {
      _title.text = workout.title;
      _description.text = workout.description ?? '';
      _category.text = workout.category ?? '';
      _sets.text = workout.sets?.toString() ?? '';
      _reps.text = workout.reps?.toString() ?? '';
      _duration.text = workout.durationMinutes?.toString() ?? '';
      _difficulty = workout.difficulty ?? _difficulty;
      _status = workout.status ?? _status;
      _imageUrl = workout.image;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _category.dispose();
    _sets.dispose();
    _reps.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final bytes = await image.readAsBytes();
      final upload = await widget.api.uploadImage(
        bytes: Uint8List.fromList(bytes),
        fileName: image.name,
      );
      setState(() {
        _imageUrl = upload.url;
        _message = 'Image uploaded';
      });
    } on ApiException catch (error) {
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _message = 'Workout title is required');
      return;
    }
    if (widget.workout == null && _memberId == null && _groupId == null) {
      setState(() => _message = 'Choose one member or group');
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final body = workoutPayload(
        memberId: widget.workout == null ? _memberId : null,
        groupId: widget.workout == null ? _groupId : null,
        title: _title.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        image: _imageUrl,
        sets: int.tryParse(_sets.text),
        reps: int.tryParse(_reps.text),
        durationMinutes: int.tryParse(_duration.text),
        difficulty: _difficulty,
        category: _category.text.trim().isEmpty ? null : _category.text.trim(),
        status: _status,
      );
      if (widget.workout == null) {
        await widget.api.createWorkout(body);
      } else {
        await widget.api.updateWorkout(widget.workout!.id, body);
      }
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
    return _SheetFrame(
      title: widget.workout == null ? 'Create Workout' : 'Edit Workout',
      child: Column(
        children: [
          if (widget.workout == null) ...[
            _TargetPickers(
              members: widget.members,
              groups: widget.groups,
              memberId: _memberId,
              groupId: _groupId,
              onMemberChanged: (value) => setState(() {
                _memberId = value;
                _groupId = null;
              }),
              onGroupChanged: (value) => setState(() {
                _groupId = value;
                _memberId = null;
              }),
            ),
            const SizedBox(height: 12),
          ],
          CustomTextField(controller: _title, labelText: 'Title'),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _description,
            labelText: 'Description',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          CustomTextField(controller: _category, labelText: 'Category'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(controller: _sets, labelText: 'Sets'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(controller: _reps, labelText: 'Reps'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(controller: _duration, labelText: 'Min'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _difficulty,
            decoration: const InputDecoration(labelText: 'Difficulty'),
            items: const [
              DropdownMenuItem(value: 'BEGINNER', child: Text('Beginner')),
              DropdownMenuItem(
                value: 'INTERMEDIATE',
                child: Text('Intermediate'),
              ),
              DropdownMenuItem(value: 'ADVANCED', child: Text('Advanced')),
            ],
            onChanged: (value) =>
                setState(() => _difficulty = value ?? _difficulty),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
              DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
            ],
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: _imageUrl == null ? 'Upload Image' : 'Replace Image',
            type: ButtonType.outline,
            isLoading: _busy,
            onPressed: _pickAndUpload,
          ),
          if (_imageUrl != null) ...[
            const SizedBox(height: 8),
            Text(_imageUrl!, style: AppTextStyles.bodySmall),
          ],
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: widget.workout == null ? 'Create Workout' : 'Save Workout',
            isLoading: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({
    required this.api,
    required this.members,
    required this.groups,
    required this.workouts,
    required this.onChanged,
    this.schedule,
  });

  final TrainerApi api;
  final List<TrainerMember> members;
  final List<TrainerGroup> groups;
  final List<TrainingWorkout> workouts;
  final TrainingSchedule? schedule;
  final Future<void> Function() onChanged;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  final _date = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _notes = TextEditingController();
  String? _workoutId;
  String? _memberId;
  String? _groupId;
  String _status = 'UPCOMING';
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    if (schedule != null) {
      _date.text = _dateString(schedule.date);
      _start.text = schedule.startTime ?? '';
      _end.text = schedule.endTime ?? '';
      _notes.text = schedule.notes ?? '';
      _workoutId = schedule.workout?.id;
      _status = schedule.status.isEmpty ? _status : schedule.status;
    }
  }

  @override
  void dispose() {
    _date.dispose();
    _start.dispose();
    _end.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_workoutId == null ||
        _date.text.isEmpty ||
        _start.text.isEmpty ||
        _end.text.isEmpty) {
      setState(() => _message = 'Workout, date, start, and end are required');
      return;
    }
    if (widget.schedule == null && _memberId == null && _groupId == null) {
      setState(() => _message = 'Choose one member or group');
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final body = schedulePayload(
        memberId: widget.schedule == null ? _memberId : null,
        groupId: widget.schedule == null ? _groupId : null,
        workoutId: _workoutId!,
        date: _date.text.trim(),
        startTime: _start.text.trim(),
        endTime: _end.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        status: _status,
      );
      if (widget.schedule == null) {
        await widget.api.createSchedule(body);
      } else {
        await widget.api.updateSchedule(widget.schedule!.id, body);
      }
      await widget.onChanged();
      if (mounted) Navigator.pop(context);
    } on ApiException catch (error) {
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(_date.text);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() => _date.text = _dateString(picked));
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(controller.text) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() => controller.text = _timeString(picked));
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: widget.schedule == null ? 'Create Schedule' : 'Edit Schedule',
      child: Column(
        children: [
          if (widget.schedule == null) ...[
            _TargetPickers(
              members: widget.members,
              groups: widget.groups,
              memberId: _memberId,
              groupId: _groupId,
              onMemberChanged: (value) => setState(() {
                _memberId = value;
                _groupId = null;
              }),
              onGroupChanged: (value) => setState(() {
                _groupId = value;
                _memberId = null;
              }),
            ),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<String>(
            initialValue: _workoutId,
            decoration: const InputDecoration(labelText: 'Workout'),
            items: widget.workouts
                .map(
                  (workout) => DropdownMenuItem(
                    value: workout.id,
                    child: Text(workout.title),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _workoutId = value),
          ),
          const SizedBox(height: 12),
          _PickerField(
            label: 'Date',
            value: _date.text.isEmpty ? 'Choose date' : _date.text,
            icon: IconsaxPlusLinear.calendar_1,
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PickerField(
                  label: 'Start',
                  value: _start.text.isEmpty ? 'Choose time' : _start.text,
                  icon: IconsaxPlusLinear.clock,
                  onTap: () => _pickTime(_start),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickerField(
                  label: 'End',
                  value: _end.text.isEmpty ? 'Choose time' : _end.text,
                  icon: IconsaxPlusLinear.clock,
                  onTap: () => _pickTime(_end),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(controller: _notes, labelText: 'Notes', maxLines: 3),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'UPCOMING', child: Text('Upcoming')),
              DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
              DropdownMenuItem(value: 'MISSED', child: Text('Missed')),
              DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
            ],
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: widget.schedule == null ? 'Create Schedule' : 'Save Schedule',
            isLoading: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _TargetPickers extends StatelessWidget {
  const _TargetPickers({
    required this.members,
    required this.groups,
    required this.memberId,
    required this.groupId,
    required this.onMemberChanged,
    required this.onGroupChanged,
  });

  final List<TrainerMember> members;
  final List<TrainerGroup> groups;
  final String? memberId;
  final String? groupId;
  final ValueChanged<String?> onMemberChanged;
  final ValueChanged<String?> onGroupChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: memberId,
          decoration: const InputDecoration(labelText: 'Assign to member'),
          items: members
              .map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Text(member.fullName),
                ),
              )
              .toList(),
          onChanged: onMemberChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: groupId,
          decoration: const InputDecoration(labelText: 'Or assign to group'),
          items: groups
              .map(
                (group) =>
                    DropdownMenuItem(value: group.id, child: Text(group.name)),
              )
              .toList(),
          onChanged: onGroupChanged,
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: children,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AppCard(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: DesignTokens.borderRadiusMedium,
            ),
            child: Icon(icon, color: tone),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: AppTextStyles.h2),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: AppTextStyles.h3.copyWith(color: color),
                  ),
                ),
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

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.profileImage,
    required this.stats,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? profileImage;
  final List<_HeroStat> stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.primaryBlue,
        borderRadius: DesignTokens.borderRadiusLarge,
        border: Border.all(
          color: isDark
              ? AppColors.primaryBlue.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
        boxShadow: AppShadows.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                image: profileImage,
                fallbackIcon: icon,
                size: 48,
                backgroundColor: AppColors.textWhite.withValues(alpha: 0.12),
                iconColor: AppColors.textWhite,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhiteTransparent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: stats
                .map(
                  (stat) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withValues(alpha: 0.10),
                        borderRadius: DesignTokens.borderRadiusMedium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.value,
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textWhite,
                            ),
                          ),
                          Text(
                            stat.label,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textWhiteTransparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HeroStat {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: DesignTokens.borderRadiusMedium,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(IconsaxPlusLinear.info_circle, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile(this.member, {this.onTap});
  const _MemberTile.readOnly(this.member) : onTap = null;

  final TrainerMember member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            AppAvatar(
              image: member.profileImage,
              fallbackIcon: IconsaxPlusLinear.profile,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.fullName, style: AppTextStyles.h3),
                  Text(member.phoneNumber ?? member.email ?? '-'),
                  if (member.status != null)
                    Text(
                      member.status!,
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
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile(this.workout, {this.onEdit, this.onDelete});
  const _WorkoutTile.readOnly(this.workout) : onEdit = null, onDelete = null;

  final TrainingWorkout workout;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (workout.targetName != null) workout.targetName!,
      if (workout.durationMinutes != null) '${workout.durationMinutes} min',
      if (workout.difficulty != null) workout.difficulty!,
      if (workout.status != null) workout.status!,
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
                if (workout.description != null) Text(workout.description!),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
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

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile(
    this.schedule, {
    this.onEdit,
    this.onDelete,
    this.onComplete,
    this.onCancel,
  });

  final TrainingSchedule schedule;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(
                      schedule.workout?.title ?? 'Training session',
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      '${_dateString(schedule.date)} ${schedule.startTime ?? ''}-${schedule.endTime ?? ''}',
                    ),
                    if (schedule.targetName != null) Text(schedule.targetName!),
                    Text(
                      schedule.status,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(IconsaxPlusLinear.trash),
                ),
            ],
          ),
          if (onComplete != null || onCancel != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onComplete != null)
                  Expanded(
                    child: CustomButton(
                      text: 'Complete',
                      size: ButtonSize.small,
                      onPressed: onComplete,
                    ),
                  ),
                if (onComplete != null && onCancel != null)
                  const SizedBox(width: 10),
                if (onCancel != null)
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      size: ButtonSize.small,
                      type: ButtonType.outline,
                      onPressed: onCancel,
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

class _JsonTile extends StatelessWidget {
  const _JsonTile(this.value);

  final Map<String, dynamic> value;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Text(
        value.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n'),
        style: AppTextStyles.bodySmall,
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final hintColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: textColor),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Material(
          color: isDark ? AppColors.darkSurface : AppColors.backgroundLight,
          borderRadius: DesignTokens.borderRadiusLarge,
          child: InkWell(
            onTap: onTap,
            borderRadius: DesignTokens.borderRadiusLarge,
            child: Container(
              height: DesignTokens.buttonHeightLarge,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing16,
              ),
              child: Row(
                children: [
                  Icon(icon, color: hintColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: value.startsWith('Choose')
                            ? hintColor
                            : textColor,
                      ),
                    ),
                  ),
                  Icon(IconsaxPlusLinear.arrow_down_1, color: hintColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: AppTextStyles.h2),
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
  const _AppCard({
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: margin,
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

String _dateString(DateTime? date) {
  if (date == null) return '';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

int _countSchedules(List<TrainingSchedule> schedules, String status) {
  return schedules
      .where((schedule) => schedule.status.toUpperCase() == status)
      .length;
}

int _countAttendance(List<Map<String, dynamic>> attendance) {
  return attendance.where((record) {
    final status = record['status']?.toString().toUpperCase();
    return status == null || status == 'PRESENT';
  }).length;
}

int _countAttendanceThisMonth(List<Map<String, dynamic>> attendance) {
  final now = DateTime.now();
  return attendance.where((record) {
    final date = _attendanceDate(record);
    if (date == null) return false;
    return date.year == now.year && date.month == now.month;
  }).length;
}

DateTime? _latestAttendanceDate(List<Map<String, dynamic>> attendance) {
  DateTime? latest;
  for (final record in attendance) {
    final date = _attendanceDate(record);
    if (date == null) continue;
    if (latest == null || date.isAfter(latest)) latest = date;
  }
  return latest;
}

DateTime? _attendanceDate(Map<String, dynamic> record) {
  final value =
      record['checkInDate'] ?? record['check_in_date'] ?? record['createdAt'];
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String? _latestSubscriptionStatus(List<Map<String, dynamic>> subscriptions) {
  if (subscriptions.isEmpty) return null;
  final active = subscriptions.firstWhere(
    (subscription) =>
        subscription['status']?.toString().toUpperCase() == 'ACTIVE',
    orElse: () => subscriptions.first,
  );
  return active['status']?.toString();
}

TimeOfDay? _parseTime(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _timeString(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

String? _optionalText(TextEditingController controller) {
  final value = controller.text.trim();
  return value.isEmpty ? null : value;
}
