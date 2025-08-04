import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/app_database.dart';
import '../../database/daos/user_dao.dart';

class UserDialog extends StatefulWidget {
  final UserDao dao;
  final User? initialUser;

  const UserDialog({super.key, required this.dao, this.initialUser});

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  String _selectedRole = 'staff';
  bool _isActive = true;

  final List<String> _roles = ['admin', 'staff'];

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.initialUser?.username ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.initialUser?.role ?? 'staff';
    _isActive = widget.initialUser?.isActive ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty ||
        _selectedRole.isEmpty ||
        (widget.initialUser == null && password.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin.')),
      );
      return;
    }

    // ✅ Kiểm tra trùng tên đăng nhập
    final existingUser = await widget.dao.getUserByUsername(username);
    final isEditing = widget.initialUser != null;

    if (existingUser != null &&
        (!isEditing || existingUser.id != widget.initialUser!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên đăng nhập đã tồn tại.')),
      );
      return;
    }

    final hashedPassword = password.isNotEmpty
        ? widget.dao.hashPassword(password)
        : widget.initialUser?.password ?? '';

    if (!isEditing) {
      await widget.dao.insertUser(
        UsersCompanion(
          username: drift.Value(username),
          password: drift.Value(hashedPassword),
          role: drift.Value(_selectedRole),
          isActive: drift.Value(_isActive),
        ),
      );
    } else {
      await widget.dao.updateUser(
        UsersCompanion(
          id: drift.Value(widget.initialUser!.id),
          username: drift.Value(username),
          password: drift.Value(hashedPassword),
          role: drift.Value(_selectedRole),
          isActive: drift.Value(_isActive),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _deleteUser() async {
    if (widget.initialUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa người dùng này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      await widget.dao.deleteUser(widget.initialUser!.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialUser == null ? 'Thêm người dùng' : 'Sửa người dùng',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.initialUser == null
                      ? 'Mật khẩu'
                      : 'Mật khẩu mới (để trống nếu không đổi)',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
                decoration: const InputDecoration(labelText: 'Vai trò'),
              ),
              SwitchListTile(
                title: const Text('Kích hoạt'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.initialUser != null)
          TextButton(
            onPressed: _deleteUser,
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _saveUser,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}