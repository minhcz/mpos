import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sale_controller.dart';
import '../../../models/draft_invoice_with_items.dart';

class DraftInvoicePopup extends StatefulWidget {
  const DraftInvoicePopup({super.key});

  @override
  State<DraftInvoicePopup> createState() => _DraftInvoicePopupState();
}

class _DraftInvoicePopupState extends State<DraftInvoicePopup> {
  bool showTodayOnly = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleController>(
      builder: (context, controller, _) {
        return FutureBuilder<List<DraftInvoiceWithItems>>(
          future: controller.getAllDrafts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            List<DraftInvoiceWithItems> drafts = snapshot.data!;

            // Sắp xếp mới nhất lên đầu
            drafts.sort((a, b) => b.draft.createdAt.compareTo(a.draft.createdAt));

            // Lọc nếu chỉ xem hóa đơn hôm nay
            if (showTodayOnly) {
              final now = DateTime.now();
              drafts = drafts.where((d) {
                final created = d.draft.createdAt;
                return created.year == now.year &&
                    created.month == now.month &&
                    created.day == now.day;
              }).toList();
            }

            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(child: Text("📂 Hóa đơn lưu tạm")),
                  const SizedBox(width: 8),
                  Switch(
                    value: showTodayOnly,
                    onChanged: (val) => setState(() => showTodayOnly = val),
                  ),
                  const Text("Hôm nay"),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: drafts.isEmpty
                    ? const Text("Không có hóa đơn tạm nào.")
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: drafts.length,
                        itemBuilder: (_, index) {
                          final draft = drafts[index];
                          final formattedName = draft.draft.name.isNotEmpty
                              ? draft.draft.name
                              : "DRAFT#${draft.draft.createdAt.toLocal().toString()}";
                          return ListTile(
                            title: Text(formattedName),
                            subtitle: Text("Tổng tiền: ${controller.formatCurrency(draft.total)}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await controller.deleteDraft(draft.draft.id);
                                if (context.mounted) setState(() {});
                              },
                            ),
                            onTap: () {
                              controller.loadDraftInvoice(draft);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
              actions: [
                if (drafts.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await controller.deleteAllDraftsInToday();
                      if (context.mounted) setState(() {});
                    },
                    child: const Text("🗑 Xóa hôm nay"),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đóng"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
