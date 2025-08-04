import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../ui/widgets/color_picker_dialog.dart';
import '../../../database/app_database.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  final List<Category> categories;
  final List<VatRate> vatRates;

  const ProductDialog({
    super.key,
    this.product,
    required this.categories,
    required this.vatRates,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _purchasePriceController;

  DateTime? _expiryDate;
  String? _imagePath;
  Color _buttonColor = Colors.blue;
  int? _selectedCategoryId;
  double? _selectedVat;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _priceController = TextEditingController(text: p?.price1.toString() ?? '');
    _stockController = TextEditingController(text: p?.stockQuantity.toString() ?? '');
    _purchasePriceController = TextEditingController(text: p?.purchasePrice?.toString() ?? '');
    _expiryDate = p?.expiryDate;
    _imagePath = p?.imagePath;
    _selectedCategoryId = p?.categoryId;
    _selectedVat = p?.vat ?? (widget.vatRates.isNotEmpty ? widget.vatRates.first.rate : 0.0);

    if (p?.buttonColor != null) {
      try {
        _buttonColor = _colorFromHex(p!.buttonColor!);
      } catch (_) {
        _buttonColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final productDao = Provider.of<AppDatabase>(context, listen: false).productDao;

    final price1 = double.tryParse(_priceController.text) ?? 0.0;
    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
    final stockQuantity = int.tryParse(_stockController.text) ?? 0;

    final productCompanion = ProductsCompanion(
      name: drift.Value(_nameController.text.trim()),
      barcode: drift.Value(_barcodeController.text.trim()),
      price1: drift.Value(price1),
      stockQuantity: drift.Value(stockQuantity),
      vat: drift.Value(_selectedVat ?? 0.0),
      purchasePrice: drift.Value(purchasePrice),
      expiryDate: _expiryDate != null ? drift.Value(_expiryDate!) : const drift.Value.absent(),
      imagePath: _imagePath != null ? drift.Value(_imagePath!) : const drift.Value.absent(),
      categoryId: _selectedCategoryId != null ? drift.Value(_selectedCategoryId!) : const drift.Value.absent(),
      buttonColor: drift.Value(_colorToHex(_buttonColor)),
      price2: const drift.Value.absent(),
    );

    if (widget.product == null) {
      await productDao.insertProduct(productCompanion);
    } else {
      await productDao.update(productDao.products).replace(productCompanion);
    }

    if (context.mounted) Navigator.of(context).pop(true);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final selectedPath = result.files.single.path!;

      try {
        final appDir = await getApplicationSupportDirectory();
        final imagesDir = Directory(p.join(appDir.path, 'images'));

        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        String fileName = p.basename(selectedPath);
        String newPath = p.join(imagesDir.path, fileName);
        int copyIndex = 1;

        while (await File(newPath).exists()) {
          final nameWithoutExt = p.basenameWithoutExtension(fileName);
          final extension = p.extension(fileName);
          fileName = '$nameWithoutExt($copyIndex)$extension';
          newPath = p.join(imagesDir.path, fileName);
          copyIndex++;
        }

        await File(selectedPath).copy(newPath);
        setState(() => _imagePath = newPath);
      } catch (e) {
        debugPrint('Lỗi khi copy ảnh: $e');
        setState(() => _imagePath = selectedPath);
      }
    }
  }

  Future<void> _pickColor() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (_) => ColorPickerDialog(initialColor: _buttonColor),
    );
    if (selectedColor != null) setState(() => _buttonColor = selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(labelText: 'Mã vạch (EAN)'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá bán'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(labelText: 'Giá nhập'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Tồn kho'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: widget.categories
                          .map((cat) => DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<double>(
                      value: _selectedVat,
                      decoration: const InputDecoration(labelText: 'VAT (%)'),
                      items: widget.vatRates
                          .map((vat) => DropdownMenuItem<double>(
                                value: vat.rate,
                                child: Text('${vat.rate.toStringAsFixed(0)}%'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedVat = v ?? 21),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickColor,
                    style: ElevatedButton.styleFrom(backgroundColor: _buttonColor),
                    child: const Text('Chọn màu'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Chọn ảnh'),
                  ),
                ],
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 10),
                ExtendedImage.file(File(_imagePath!), height: 100),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
        ElevatedButton(onPressed: _saveProduct, child: const Text('Lưu')),
      ],
    );
  }
}