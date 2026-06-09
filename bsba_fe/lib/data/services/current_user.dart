import 'package:project/data/models/auth_session.dart';

/// The signed-in user, read across the app (chat, inbox, …) for the userId/role
/// that backend calls need. Populated on login from the returned [AuthUser].
///
/// Falls back to a seeded demo customer so the "test/test" bypass still works.
class CurrentUser {
  CurrentUser._();
  static final CurrentUser instance = CurrentUser._();

  String id = 'a0000000-0000-0000-0000-000000000002'; // demo customer fallback
  String role = 'CUSTOMER';

  void setFrom(AuthUser user) {
    id = user.id;
    role = (user.role == null || user.role!.isEmpty) ? 'CUSTOMER' : user.role!;
  }

  void clear() {
    id = 'a0000000-0000-0000-0000-000000000002';
    role = 'CUSTOMER';
  }
}
