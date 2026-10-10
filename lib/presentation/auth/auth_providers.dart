import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_role.dart';

// STUB: Change this value to test different roles
final currentUserRoleProvider = Provider<UserRole>((ref) {
  return UserRole.vehicleOwner; 
});
