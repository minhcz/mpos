// lib/screens/category/category_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/app_database.dart';
import 'category_dialog.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final dao = db.categoryDao;

    // Style giống với product_management_screen
    final headerTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm danh mục',
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => const CategoryDialog(),
              );
              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm danh mục thành công')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: dao.watchAllCategories(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(child: Text('Chưa có danh mục nào.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowHeight: 48,
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 56,
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFE3F2FD)),
                      columns: [
                        DataColumn(
                          label: Text('ID', style: headerTextStyle),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Tên danh mục', style: headerTextStyle),
                        ),
                        DataColumn(
                          label: Text('VAT (%)', style: headerTextStyle),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Màu nút', style: headerTextStyle),
                        ),
                        DataColumn(
                          label: Text('Hành động', style: headerTextStyle),
                        ),
                      ],
                      rows: categories.map((cat) {
                        return DataRow(
                          cells: [
                            DataCell(Text(cat.id.toString())),
                            DataCell(Text(cat.name)),
                            DataCell(Text(cat.vat.toString())),
                            DataCell(Text(cat.buttonColor ?? '')),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Sửa',
                                  onPressed: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => CategoryDialog(category: cat),
                                    );
                                    if (result == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Cập nhật thành công')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Xóa',
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Xác nhận'),
                                        content: Text('Bạn có chắc muốn xóa "${cat.name}" không?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(false),
                                            child: const Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(true),
                                            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await dao.deleteCategory(cat.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã xóa danh mục')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}