enum UserRole {
  guest,
  vehicleOwner,
  parkingOwner,
  admin;

  static UserRole fromString(String? role) {
    switch (role) {
      case 'parking_owner':
        return UserRole.parkingOwner;
      case 'admin':
        return UserRole.admin;
      case 'vehicle_owner':
        return UserRole.vehicleOwner;
      default:
        return UserRole.guest;
    }
  }

  String toDbValue() {
    switch (this) {
      case UserRole.parkingOwner:
        return 'parking_owner';
      case UserRole.admin:
        return 'admin';
      case UserRole.vehicleOwner:
        return 'vehicle_owner';
      case UserRole.guest:
        return 'guest';
    }
  }
}
