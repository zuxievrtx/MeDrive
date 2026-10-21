import 'package:freezed_annotation/freezed_annotation.dart';

import 'common.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required int id,
    required String name,
    String? initials,
    required String phone,
    required String email,
    required LabeledValue role,
    LabeledValue? accountStatus,
    @Default(false) bool mustChangePassword,
    DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  bool get isReporter => role.value == 'pelapor';

  String get displayInitials {
    if (initials != null && initials!.isNotEmpty) {
      return initials!;
    }
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2);
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

/// Respons login/register: token Sanctum + profil.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String token,
    @Default(false) bool mustChangePassword,
    required AppUser user,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) => _$AuthSessionFromJson(json);
}
