import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.token,
  });

  // Empty user
  factory User.empty() => const User(
        id: '',
        name: '',
        email: '',
      );

  // Copy with
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, token];
}
