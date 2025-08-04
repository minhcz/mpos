import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final double total;

  const PaymentScreen({Key? key, this.total = 0.0}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController cashController = TextEditingController();

  @override
  void dispose() {
    cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng cộng: ${widget.total.toStringAsFixed(0)} đ',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tiền mặt khách đưa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final cash = double.tryParse(cashController.text) ?? 0.0;
                final change = cash - widget.total;

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Hoàn tất'),
                    content: Text(
                      change >= 0
                          ? 'Trả lại: ${change.toStringAsFixed(0)} đ'
                          : 'Chưa đủ tiền!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Đóng dialog
                          if (change >= 0) {
                            Navigator.pop(context, true); // Trả kết quả thành công
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Xác nhận thanh toán'),
            ),
          ],
        ),
      ),
    );
  }
}