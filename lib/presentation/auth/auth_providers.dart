import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_role.dart';

class UserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.vehicleOwner;

  void setRole(UserRole role) {
    state = role;
  }
}

final userRoleStateProvider = NotifierProvider<UserRoleNotifier, UserRole>(
  UserRoleNotifier.new,
);

final currentUserRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(userRoleStateProvider);
});
