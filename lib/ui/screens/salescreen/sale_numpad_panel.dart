import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sale_controller.dart';
import '../draft_invoice_popup.dart';

class SaleNumpadPanel extends StatefulWidget {
  final FocusNode barcodeFocusNode;
  const SaleNumpadPanel({super.key, required this.barcodeFocusNode});

  @override
  State<SaleNumpadPanel> createState() => _SaleNumpadPanelState();
}

class _SaleNumpadPanelState extends State<SaleNumpadPanel> {
  final TextEditingController barcodeController = TextEditingController();
  String _currentNumpadInput = ''; // Lưu trữ input từ numpad

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.barcodeFocusNode.requestFocus();
    });
    barcodeController.addListener(_onBarcodeControllerChanged);
  }

  void _onBarcodeControllerChanged() {
    if (_currentNumpadInput != barcodeController.text) {
      _currentNumpadInput = barcodeController.text;
    }
  }

  void _onNumpadInput(String value) {
    setState(() {
      if (value == '.' && _currentNumpadInput.contains('.')) {
        return;
      }
      _currentNumpadInput += value;
      barcodeController.text = _currentNumpadInput;
      barcodeController.selection = TextSelection.fromPosition(
        TextPosition(offset: barcodeController.text.length),
      );
    });
    widget.barcodeFocusNode.requestFocus();
  }

  void _onBackspace() {
    setState(() {
      if (_currentNumpadInput.isNotEmpty) {
        _currentNumpadInput = _currentNumpadInput.substring(
          0,
          _currentNumpadInput.length - 1,
        );
        barcodeController.text = _currentNumpadInput;
        barcodeController.selection = TextSelection.fromPosition(
          TextPosition(offset: barcodeController.text.length),
        );
      }
    });
    widget.barcodeFocusNode.requestFocus();
  }

  void _resetNumpadState() {
    setState(() {
      _currentNumpadInput = '';
      barcodeController.clear();
    });
    widget.barcodeFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SaleController>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Chiều cao cố định cho hàng input và nút bên cạnh
        const double inputRowHeight = 70.0;

        // Tổng chiều cao còn lại cho khu vực numpad
        final double remainingHeightForNumpad = constraints.maxHeight - inputRowHeight - 4;

        const int numberOfNumpadRows = 5;
        const int numberOfRowSpacers = numberOfNumpadRows - 1;
        // Đã giảm khoảng cách giữa các hàng từ 4.0 xuống 2.0
        const double spacerHeight = 2.0;

        // Tính toán chiều cao cho MỖI cell numpad
        // Khi spacerHeight giảm, cellHeight sẽ tăng
        final double cellHeight = (remainingHeightForNumpad - (numberOfRowSpacers * spacerHeight)) / numberOfNumpadRows;


        Widget buildCell(String label, VoidCallback? onPressed,
            {Color? color, Color textColor = Colors.black, int flex = 1}) {
          return Expanded(
            flex: flex,
            child: SizedBox(
              height: cellHeight > 0 ? cellHeight : 0,
              child: Padding(
                padding: const EdgeInsets.all(2), // Padding này cũng ảnh hưởng đến kích thước nút
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color ?? Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: textColor)),
                ),
              ),
            ),
          );
        }

        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              // Hàng input và 2 nút bên cạnh
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _resetNumpadState,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.clear, color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: barcodeController,
                        focusNode: widget.barcodeFocusNode,
                        textInputAction: TextInputAction.done,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Mã sản phẩm...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (_) async {
                          final code = barcodeController.text.trim();
                          if (code.isNotEmpty) {
                            await controller.processBarcodeInput(context, code);
                            _resetNumpadState();
                          }
                        },
                        onTap: () {
                          _currentNumpadInput = barcodeController.text;
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () async {
                          final code = barcodeController.text.trim();
                          if (code.isNotEmpty) {
                            await controller.processBarcodeInput(context, code);
                            _resetNumpadState();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.check, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              Expanded(
                child: Column(
                  children: [
                    Row(children: [
                      buildCell('Số lượng', () {
                        if (controller.selectedCartProduct == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng chọn sản phẩm trước!')),
                          );
                          return;
                        }

                        if (_currentNumpadInput.isNotEmpty) {
                          final double? parsedQuantity = double.tryParse(_currentNumpadInput);
                          if (parsedQuantity != null && parsedQuantity > 0) {
                            controller.updateSelectedProductQuantity(parsedQuantity);
                            _resetNumpadState();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Số lượng không hợp lệ')),
                            );
                            _resetNumpadState();
                          }
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập số lượng trước!')),
                          );
                        }
                      }, color: Colors.orange.shade100),
                      buildCell('1', () => _onNumpadInput('1')),
                      buildCell('2', () => _onNumpadInput('2')),
                      buildCell('3', () => _onNumpadInput('3')),
                    ]),
                    const SizedBox(height: spacerHeight),
                    Row(children: [
                      buildCell('Xóa', () {
                        controller.removeSelectedProduct();
                        _resetNumpadState();
                      }, color: Colors.red.shade200),
                      buildCell('4', () => _onNumpadInput('4')),
                      buildCell('5', () => _onNumpadInput('5')),
                      buildCell('6', () => _onNumpadInput('6')),
                    ]),
                    const SizedBox(height: spacerHeight),
                    Row(children: [
                      buildCell('Hạ giá', () {
                        controller.startDiscount();
                        _resetNumpadState();
                      }, color: Colors.purple.shade100),
                      buildCell('7', () => _onNumpadInput('7')),
                      buildCell('8', () => _onNumpadInput('8')),
                      buildCell('9', () => _onNumpadInput('9')),
                    ]),
                    const SizedBox(height: spacerHeight),
                    Row(children: [
                      buildCell('Hủy', () {
                        controller.cancelCurrentSale();
                        _resetNumpadState();
                      }, color: Colors.grey.shade400),
                      buildCell('.', () => _onNumpadInput('.')),
                      buildCell('0', () => _onNumpadInput('0')),
                      buildCell('⌫', () => _onBackspace()),
                    ]),
                    const SizedBox(height: spacerHeight),
                    Row(children: [
                      buildCell('Lưu tạm', () async {
                        if (controller.cart.isNotEmpty) {
                          await controller.saveDraftInvoice();
                        } else {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => ChangeNotifierProvider.value(
                                value: controller,
                                child: const DraftInvoicePopup(),
                              ),
                            );
                          }
                        }
                        _resetNumpadState();
                      }, color: Colors.blue.shade100),
                      buildCell('Mở két', () => controller.openCashDrawer(),
                          color: Colors.blue.shade200),
                      buildCell('Thanh toán', () async {
                        await controller.checkout(context);
                        _resetNumpadState();
                      },
                          color: Colors.green.shade400,
                          textColor: Colors.white,
                          flex: 2),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}