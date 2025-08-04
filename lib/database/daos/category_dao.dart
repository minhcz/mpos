// lib/database/daos/category_dao.dart

import '../../database/tables.dart';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../tables/categories.dart';


part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  /// Lấy tất cả danh mục
  Future<List<Category>> getAllCategories() => select(categories).get();

  /// Lắng nghe danh mục thay đổi
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  /// Thêm danh mục mới
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  /// Cập nhật danh mục theo ID
  Future<bool> updateCategory(int id, CategoriesCompanion updatedData) async {
    final query = update(categories)..where((tbl) => tbl.id.equals(id));
    final rowsAffected = await query.write(updatedData);
    return rowsAffected > 0;
  }

  /// Xóa danh mục theo ID
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();

  /// Kiểm tra tên danh mục đã tồn tại chưa (dùng để validate)
  Future<bool> isCategoryNameTaken(String name, [int? excludeId]) async {
    final query = select(categories)..where((tbl) => tbl.name.equals(name));
    if (excludeId != null) {
      // Sửa lỗi .isNotEqual -> dùng .equals(...).not()
      query.where((tbl) => tbl.id.equals(excludeId).not());
    }
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// (Tùy chọn) Lấy 1 danh mục theo ID
  Future<Category?> getCategoryById(int id) async {
    return (select(categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}