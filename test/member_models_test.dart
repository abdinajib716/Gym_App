import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/member/data/member_models.dart';
import 'package:gym_app/features/shared/models/mobile_user.dart';
import 'package:gym_app/features/store/data/store_models.dart';
import 'package:gym_app/features/trainer/data/trainer_models.dart';
import 'package:gym_app/features/training/data/training_models.dart';

void main() {
  test('MobileUser parses member login response safely', () {
    final user = MobileUser.fromJson({
      'id': 'member-id',
      'accountId': 'account-id',
      'role': 'MEMBER',
      'name': 'Mobile Member',
      'email': null,
      'phone': '0612345678',
      'profileImage': '/uploads/access-control/member.webp',
      'accountStatus': 'ACTIVE',
      'mustChangePassword': true,
    });

    expect(user.id, 'member-id');
    expect(user.role, MobileRole.member);
    expect(user.profileImage, '/uploads/access-control/member.webp');
    expect(user.mustChangePassword, isTrue);
  });

  test('MemberDashboard parses smoke response shape', () {
    final dashboard = MemberDashboard.fromJson({
      'member': {
        'id': 'member-id',
        'fullName': 'Mobile Member',
        'phoneNumber': '0612345678',
        'email': null,
        'status': 'ACTIVE',
      },
      'account': {'accountId': 'account-id', 'mustChangePassword': true},
      'summary': {
        'hasActiveSubscription': true,
        'paymentCount': 2,
        'unreadNotifications': 1,
      },
      'currentSubscription': {
        'id': 'subscription-id',
        'status': 'ACTIVE',
        'paymentStatus': 'PAID',
      },
      'recentPayments': [
        {
          'id': 'payment-id',
          'amount': 25,
          'method': 'WAAFI_PAY',
          'status': 'PENDING',
          'requestId': 'REQ-1',
          'invoiceId': 'INV-1',
        },
      ],
      'latestNotifications': [
        {
          'id': 'notification-id',
          'title': 'Smoke notification',
          'message': 'Hello',
          'type': 'GENERAL_MESSAGE',
          'readStatus': 'UNREAD',
        },
      ],
    });

    expect(dashboard.member.fullName, 'Mobile Member');
    expect(dashboard.summary.hasActiveSubscription, isTrue);
    expect(dashboard.currentSubscription?.status, 'ACTIVE');
    expect(dashboard.recentPayments.single.method, 'WAAFI_PAY');
    expect(dashboard.latestNotifications.single.readStatus, 'UNREAD');
  });

  test('MobileUser parses trainer login response safely', () {
    final user = MobileUser.trainerFromJson({
      'id': 'trainer-id',
      'fullName': 'Trainer Name',
      'phoneNumber': '0612345678',
      'email': 'trainer@example.com',
      'specialty': 'Strength Training',
      'profileImage': '/uploads/access-control/trainer.webp',
    });

    expect(user.id, 'trainer-id');
    expect(user.role, MobileRole.trainer);
    expect(user.name, 'Trainer Name');
    expect(user.profileImage, '/uploads/access-control/trainer.webp');
    expect(user.accountStatus, 'ACTIVE');
  });

  test('TrainerDashboard parses KPI contract shape', () {
    final dashboard = TrainerDashboard.fromJson({
      'welcome': 'Welcome Trainer Name',
      'trainer': {
        'id': 'trainer-id',
        'name': 'Trainer Name',
        'specialty': 'Strength Training',
      },
      'kpis': {
        'total_members': 12,
        'total_groups': 2,
        'today_sessions': 3,
        'upcoming_sessions': 10,
        'completed_sessions': 22,
        'missed_sessions': 1,
      },
      'recent_members': [
        {'id': 'member-id', 'fullName': 'Member Name'},
      ],
      'today_schedule': [
        {'id': 'schedule-id', 'status': 'UPCOMING'},
      ],
    });

    expect(dashboard.kpis.totalMembers, 12);
    expect(dashboard.kpis.todaySessions, 3);
    expect(dashboard.recentMembers.single.fullName, 'Member Name');
    expect(dashboard.todaySchedule.single.status, 'UPCOMING');
  });

  test('Training workout parses today card with schedule and trainer', () {
    final workout = TrainingWorkout.fromJson({
      'id': 'workout-id',
      'title': 'Chest Day',
      'sets': 3,
      'reps': 12,
      'durationMinutes': 45,
      'schedule': {
        'id': 'schedule-id',
        'date': '2026-07-01T00:00:00.000Z',
        'startTime': '09:00',
        'endTime': '10:00',
        'status': 'UPCOMING',
      },
      'trainer': {'id': 'trainer-id', 'fullName': 'Trainer Name'},
    });

    expect(workout.title, 'Chest Day');
    expect(workout.durationMinutes, 45);
    expect(workout.schedule?.status, 'UPCOMING');
    expect(workout.trainer?.fullName, 'Trainer Name');
  });

  test('Training schedule parses status and snake case aliases', () {
    final schedule = TrainingSchedule.fromJson({
      'id': 'schedule-id',
      'date': '2026-07-01',
      'start_time': '18:00',
      'end_time': '19:00',
      'status': 'CANCELLED',
      'workout': {'id': 'workout-id', 'title': 'Group Cardio'},
    });

    expect(schedule.startTime, '18:00');
    expect(schedule.endTime, '19:00');
    expect(schedule.status, 'CANCELLED');
    expect(schedule.workout?.title, 'Group Cardio');
  });

  test('MemberAttendance parses summary and records', () {
    final attendance = MemberAttendance.fromJson({
      'summary': {
        'total': 8,
        'present': 7,
        'cancelled': 1,
        'lastCheckIn': '2026-07-07T06:30:00.000Z',
      },
      'attendance': [
        {
          'id': 'attendance-id',
          'memberId': 'member-id',
          'checkInDate': '2026-07-07T06:30:00.000Z',
          'method': 'MANUAL',
          'status': 'PRESENT',
          'createdAt': '2026-07-07T06:30:00.000Z',
        },
      ],
    });

    expect(attendance.summary.total, 8);
    expect(attendance.summary.present, 7);
    expect(attendance.records.single.status, 'PRESENT');
    expect(attendance.records.single.method, 'MANUAL');
  });

  test('MemberProgress parses attendance and training summary', () {
    final progress = MemberProgress.fromJson({
      'progress': {
        'subscription': {
          'id': 'subscription-id',
          'status': 'ACTIVE',
          'paymentStatus': 'PAID',
          'plan': {'id': 'plan-id', 'name': 'Monthly', 'price': 30},
        },
        'attendance': {
          'totalPresent': 30,
          'presentInRange': 8,
          'presentThisMonth': 8,
          'rangeDays': 30,
          'lastCheckIn': {
            'id': 'attendance-id',
            'memberId': 'member-id',
            'checkInDate': '2026-07-07T06:30:00.000Z',
            'method': 'MANUAL',
            'status': 'PRESENT',
          },
        },
        'training': {
          'activeWorkouts': 4,
          'totalSchedules': 10,
          'completedSchedules': 6,
          'upcomingSchedules': 3,
          'missedSchedules': 1,
          'cancelledSchedules': 0,
          'completionRate': 60,
          'recentCompletedSchedules': [
            {
              'id': 'schedule-id',
              'status': 'COMPLETED',
              'workout': {'id': 'workout-id', 'title': 'Chest Day'},
            },
          ],
        },
      },
    });

    expect(progress.subscription?.plan?.name, 'Monthly');
    expect(progress.attendance.presentThisMonth, 8);
    expect(progress.attendance.lastCheckIn?.status, 'PRESENT');
    expect(progress.training.completionRate, 60);
    expect(
      progress.training.recentCompletedSchedules.single.status,
      'COMPLETED',
    );
  });

  test('TrainerMemberDetail parses member progress when provided', () {
    final detail = TrainerMemberDetail.fromJson({
      'member': {'id': 'member-id', 'fullName': 'Member Name'},
      'progress': {
        'attendance': {
          'totalPresent': 12,
          'presentInRange': 5,
          'presentThisMonth': 5,
          'rangeDays': 30,
        },
        'training': {
          'activeWorkouts': 3,
          'totalSchedules': 8,
          'completedSchedules': 6,
          'upcomingSchedules': 1,
          'missedSchedules': 1,
          'cancelledSchedules': 0,
          'completionRate': 75,
        },
      },
    });

    expect(detail.progress?.attendance.presentInRange, 5);
    expect(detail.progress?.training.completionRate, 75);
  });

  test('Trainer upload parses contract response', () {
    final upload = TrainerUpload.fromJson({
      'url': '/uploads/workouts/filename.webp',
      'fileName': 'filename.webp',
    });

    expect(upload.url, '/uploads/workouts/filename.webp');
    expect(upload.fileName, 'filename.webp');
  });

  test('Store models parse product purchase and order contracts', () {
    final product = StoreProduct.fromJson({
      'id': 'product-id',
      'name': 'Protein Powder',
      'category': 'Supplements',
      'image': '/uploads/store/product.webp',
      'price': 25,
      'currency': 'USD',
      'availableQuantity': 10,
      'isOutOfStock': false,
      'status': 'PUBLISHED',
    });

    final result = StorePurchaseResult.fromJson({
      'paymentStatus': 'PAID',
      'message': 'Payment confirmed and order created successfully',
      'order': {
        'id': 'order-id',
        'orderNumber': 'ORD-1',
        'buyerName': 'Member Name',
        'buyerType': 'MEMBER',
        'buyerPhoneNumber': '252612345678',
        'product': {'id': 'product-id', 'name': 'Protein Powder'},
        'quantity': 2,
        'unitPrice': 25,
        'totalAmount': 50,
        'currency': 'USD',
        'paymentMethod': 'WAAFI_PAY',
        'paymentStatus': 'PAID',
        'orderStatus': 'PROCESSING',
      },
    });

    expect(product.image, '/uploads/store/product.webp');
    expect(product.isOutOfStock, isFalse);
    expect(result.order?.totalAmount, 50);
    expect(result.paymentStatus, 'PAID');
  });

  test('Store purchase handles 200 non-paid response as payment outcome', () {
    final result = StorePurchaseResult.fromJson({
      'paymentStatus': 'FAILED',
      'message':
          'Payment was not completed. Customer rejected payment | RCS_USER_REJECTED | Code: 5310',
      'order': null,
      'transaction': {'failedReason': 'User cancelled the Waafi prompt'},
    });

    expect(result.hasCreatedOrder, isFalse);
    expect(result.isFailedOrCancelled, isTrue);
    expect(
      result.displayMessage,
      'Payment was not completed. Customer rejected payment | RCS_USER_REJECTED | Code: 5310',
    );
  });
}
