import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

import '../../database/app_database.dart';
import '../../utils/color_utils.dart';
import '../../ui/widgets/color_picker_dialog.dart';

class CategoryDialog extends StatefulWidget {
  final Category? category;

  const CategoryDialog({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int? _parentId;
  int _vat = 21;
  late Color _buttonColor;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _parentId = widget.category?.parentId;
    _vat = widget.category?.vat ?? 21;

    if (widget.category?.buttonColor != null && widget.category!.buttonColor!.isNotEmpty) {
      _buttonColor = ColorUtils.fromHex(widget.category!.buttonColor!);
    } else {
      _buttonColor = Colors.blue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectColor() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(initialColor: _buttonColor),
    );

    if (selectedColor != null) {
      setState(() {
        _buttonColor = selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final categoryDao = db.categoryDao;

    return AlertDialog(
      title: Text(widget.category == null ? 'Thêm Danh mục' : 'Sửa Danh mục'),
      content: SingleChildScrollView(
        child: FutureBuilder<List<Category>>(
          future: categoryDao.getAllCategories(),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];
            final parentOptions = categories.where((c) => c.id != widget.category?.id).toList();

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên danh mục'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int?>(
                    value: _parentId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Danh mục cha'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Không có')),
                      ...parentOptions.map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _parentId = value),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: _vat,
                    decoration: const InputDecoration(labelText: 'DPH (%)'),
                    items: [0, 10, 12, 15, 21]
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text('$v %'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _vat = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _selectColor,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _buttonColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Chọn màu nút',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final companion = CategoriesCompanion(
                name: drift.Value(_nameController.text.trim()),
                parentId: drift.Value(_parentId),
                vat: drift.Value(_vat),
                buttonColor: drift.Value(ColorUtils.toHex(_buttonColor)),
              );

              try {
                if (widget.category == null) {
                  await categoryDao.insertCategory(companion);
                } else {
                  await categoryDao.updateCategory(widget.category!.id, companion);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi lưu danh mục: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}