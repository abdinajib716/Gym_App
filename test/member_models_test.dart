import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/member/data/member_models.dart';
import 'package:gym_app/features/shared/models/mobile_user.dart';

void main() {
  test('MobileUser parses member login response safely', () {
    final user = MobileUser.fromJson({
      'id': 'member-id',
      'accountId': 'account-id',
      'role': 'MEMBER',
      'name': 'Mobile Member',
      'email': null,
      'phone': '0612345678',
      'accountStatus': 'ACTIVE',
      'mustChangePassword': true,
    });

    expect(user.id, 'member-id');
    expect(user.role, MobileRole.member);
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
}
