import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/app_database.dart';
import '../../database/daos/user_dao.dart';
import 'user_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late final UserDao dao;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dao = Provider.of<AppDatabase>(context, listen: false).userDao;
  }

  void _openUserDialog([User? user]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => UserDialog(dao: dao, initialUser: user),
    );
    if (result == true) {
      setState(() {}); // Refresh lại danh sách khi có thay đổi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openUserDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: dao.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!;
          if (users.isEmpty) return const Center(child: Text('Chưa có người dùng nào.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                title: Text(u.username),
                subtitle: Text('Vai trò: ${u.role} • Kích hoạt: ${u.isActive ? 'Có' : 'Không'}'),
                trailing: const Icon(Icons.edit),
                onTap: () => _openUserDialog(u),
              );
            },
          );
        },
      ),
    );
  }
}