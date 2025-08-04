// lib/ui/screens/salescreen/sale_category_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sale_controller.dart';
import '../../../database/app_database.dart';

class SaleCategoryBar extends StatelessWidget {
  final List<Category> categories;
  const SaleCategoryBar({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SaleController>(context);

    return SizedBox(
      width: 160,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final cat = categories[index];
          final isSelected = controller.selectedCategoryId == cat.id;

          final buttonColor = cat.buttonColor != null
              ? Color(int.tryParse(cat.buttonColor!.replaceFirst('#', '0xFF')) ?? 0xFFE3F2FD)
              : const Color(0xFFE3F2FD);

          final displayColor = isSelected
              ? buttonColor.withAlpha((0.7 * 255).round())
              : buttonColor;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: GestureDetector(
              onTap: () => controller.selectCategory(isSelected ? null : cat.id),
              child: Container(
                height: 72, // 🟢 tăng chiều cao nút
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: displayColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 3,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}