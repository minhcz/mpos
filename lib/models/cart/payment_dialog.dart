import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final double total;
  const PaymentDialog({super.key, required this.total});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String? _selectedMethod;
  final List<String> _methods = ['Tiền mặt', 'Chuyển khoản', 'Thẻ'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn phương thức thanh toán'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tổng: ${widget.total.toStringAsFixed(0)} Kč'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedMethod,
            items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => _selectedMethod = val),
            decoration: const InputDecoration(labelText: 'Phương thức'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _selectedMethod != null ? () => Navigator.pop(context, _selectedMethod) : null,
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
