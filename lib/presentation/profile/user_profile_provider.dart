import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_providers.dart';

class UserProfileState {
  final String fullName;
  final String phone;
  final String? avatarUrl;

  const UserProfileState({
    this.fullName = 'juanma',
    this.phone = '+57 312 345 6789',
    this.avatarUrl,
  });

  UserProfileState copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) {
    return UserProfileState(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class UserProfileNotifier extends Notifier<UserProfileState> {
  static const String _avatarKey = 'user_persisted_avatar_url';
  static const String _nameKey = 'user_persisted_full_name';
  static const String _phoneKey = 'user_persisted_phone';

  // In-memory static cache so values survive logouts and test environments without SharedPreferences channels
  static String? _cachedAvatar;
  static String? _cachedName;
  static String? _cachedPhone;

  @override
  UserProfileState build() {
    _initFromStorage();
    return UserProfileState(
      fullName: _cachedName ?? 'juanma',
      phone: _cachedPhone ?? '+57 312 345 6789',
      avatarUrl: _cachedAvatar,
    );
  }

  Future<void> _initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final av = prefs.getString(_avatarKey);
      final name = prefs.getString(_nameKey);
      final ph = prefs.getString(_phoneKey);

      if (av != null) _cachedAvatar = av;
      if (name != null) _cachedName = name;
      if (ph != null) _cachedPhone = ph;

      state = state.copyWith(
        avatarUrl: _cachedAvatar,
        fullName: _cachedName,
        phone: _cachedPhone,
      );
    } catch (e) {
      debugPrint('SharedPreferences init fallback: $e');
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (avatarUrl != null) _cachedAvatar = avatarUrl;
    if (fullName != null) _cachedName = fullName;
    if (phone != null) _cachedPhone = phone;

    state = state.copyWith(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      if (avatarUrl != null) await prefs.setString(_avatarKey, avatarUrl);
      if (fullName != null) await prefs.setString(_nameKey, fullName);
      if (phone != null) await prefs.setString(_phoneKey, phone);
    } catch (_) {}

    // Optionally update Supabase if user is logged in
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final updates = <String, dynamic>{};
        if (fullName != null) updates['full_name'] = fullName;
        if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
        if (phone != null) updates['phone'] = phone;

        if (updates.isNotEmpty) {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(data: updates),
          );
          await Supabase.instance.client
              .from('profiles')
              .update(updates)
              .eq('id', user.id);
        }
      }
    } catch (_) {}
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
  UserProfileNotifier.new,
);
