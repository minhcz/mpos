import 'package:flutter/material.dart';
import 'setting_general_tab.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1, // Tăng số lượng tab nếu cần mở rộng
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cài đặt'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chung'),
              // Ví dụ mở rộng:
              // Tab(text: 'Hệ thống'),
              // Tab(text: 'Tùy chỉnh'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              SettingGeneralTab(),
              // Thêm các widget tương ứng với tab ở đây nếu có
            ],
          ),
        ),
      ),
    );
  }
}