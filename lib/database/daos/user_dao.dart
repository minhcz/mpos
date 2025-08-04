import '../../database/tables.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../database/app_database.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  Stream<List<User>> watchAllUsers() => select(users).watch();

  Future<List<User>> getAllUsers() => select(users).get();

  Future<User?> getUserByUsername(String username) {
    return (select(users)..where((tbl) => tbl.username.equals(username)))
        .getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateUser(UsersCompanion user) =>
      update(users).replace(user);

  Future<int> deleteUser(int id) {
    return (delete(users)..where((tbl) => tbl.id.equals(id))).go();
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> login(String username, String password) {
    final hashedPassword = hashPassword(password);
    return (select(users)
          ..where((tbl) => tbl.username.equals(username))
          ..where((tbl) => tbl.password.equals(hashedPassword))
          ..where((tbl) => tbl.isActive.equals(true)))
        .getSingleOrNull();
  }

  Future<void> ensureAdminUserExists() async {
    final existingAdmin = await getUserByUsername('admin');
    if (existingAdmin == null) {
      final hashedPassword = hashPassword('1234');
      await insertUser(
        UsersCompanion(
          username: Value('admin'),
          password: Value(hashedPassword),
          role: Value('admin'),
          isActive: Value(true),
        ),
      );
      print('✅ Admin user created with username: admin and password: 1234 (hashed)');
    } else {
      print('ℹ️ Admin user already exists.');
    }
  }
}