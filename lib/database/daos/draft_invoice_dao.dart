import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/draft_invoices.dart';
import '../tables/draft_invoice_items.dart';
import '../../models/draft_invoice_with_items.dart';

part 'draft_invoice_dao.g.dart';

@DriftAccessor(tables: [DraftInvoices, DraftInvoiceItems])
class DraftInvoiceDao extends DatabaseAccessor<AppDatabase>
    with _$DraftInvoiceDaoMixin {
  DraftInvoiceDao(AppDatabase db) : super(db);

  // -----------------------------
  // CREATE
  // -----------------------------

  Future<int> insertDraftInvoice(DraftInvoicesCompanion entry) =>
      into(draftInvoices).insert(entry);

  Future<int> insertDraftItem(DraftInvoiceItemsCompanion entry) =>
      into(draftInvoiceItems).insert(entry);

  Future<void> insertMultipleDraftItems(
      List<DraftInvoiceItemsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(draftInvoiceItems, items);
    });
  }

  // -----------------------------
  // READ
  // -----------------------------

  /// Lấy toàn bộ hóa đơn tạm (không kèm item)
  Future<List<DraftInvoice>> getAllDrafts() => select(draftInvoices).get();

  /// Theo dõi thay đổi của danh sách hóa đơn tạm
  Stream<List<DraftInvoice>> watchAllDrafts() => select(draftInvoices).watch();

  /// Lấy danh sách sản phẩm của 1 hóa đơn tạm
  Future<List<DraftInvoiceItem>> getItemsByDraftId(int draftId) {
    return (select(draftInvoiceItems)
          ..where((t) => t.draftInvoiceId.equals(draftId)))
        .get();
  }

  /// Lấy tất cả hóa đơn tạm và sản phẩm liên quan
  Future<List<DraftInvoiceWithItems>> getAllDraftsWithItems() async {
    final drafts = await (select(draftInvoices)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    final result = <DraftInvoiceWithItems>[];

    for (final draft in drafts) {
      final items = await getItemsByDraftId(draft.id);
      result.add(DraftInvoiceWithItems(draft: draft, items: items));
    }

    return result;
  }

  // -----------------------------
  // UPDATE
  // -----------------------------

  /// Cập nhật tên hóa đơn tạm sau khi có ID
  Future<void> updateDraftName(int draftId, String name) async {
    await (update(draftInvoices)..where((t) => t.id.equals(draftId)))
        .write(DraftInvoicesCompanion(name: Value(name)));
  }

  // -----------------------------
  // DELETE
  // -----------------------------

  /// Xóa cả hóa đơn tạm và các item con
  Future<void> deleteDraft(int draftId) async {
    await transaction(() async {
      await (delete(draftInvoiceItems)
            ..where((t) => t.draftInvoiceId.equals(draftId)))
          .go();
      await (delete(draftInvoices)..where((t) => t.id.equals(draftId))).go();
    });
  }

  /// Alias cho deleteDraft
  Future<void> deleteDraftById(int draftId) => deleteDraft(draftId);

  /// ✅ Xóa tất cả draft trong khoảng thời gian
  Future<int> deleteDraftsBetween(DateTime from, DateTime to) async {
    final toDelete = await (select(draftInvoices)
          ..where((tbl) =>
              tbl.createdAt.isBiggerOrEqualValue(from) &
              tbl.createdAt.isSmallerOrEqualValue(to)))
        .get();

    if (toDelete.isEmpty) return 0;

    final ids = toDelete.map((e) => e.id).toList();

    await batch((batch) {
      batch.deleteWhere(draftInvoiceItems, (tbl) => tbl.draftInvoiceId.isIn(ids));
      batch.deleteWhere(draftInvoices, (tbl) => tbl.id.isIn(ids));
    });

    return ids.length;
  }
}