import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/currency_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../i18n/strings.g.dart';
import '../../items/data/items_providers.dart';
import '../../items/presentation/variant_picker_dialog.dart';
import '../../items/presentation/modifier_picker_dialog.dart';
import '../data/cart_state.dart';
import '../data/sales_providers.dart';
import 'payment_dialog.dart';
import 'customer_assign_dialog.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= AppConstants.tabletBreakpoint;
    final cart = ref.watch(cartProvider);

    if (isWide) {
      return Row(
        children: [
          Expanded(flex: 3, child: _buildItemsPanel()),
          SizedBox(
            width: 360,
            child: _buildCartPanel(cart),
          ),
        ],
      );
    }

    // Mobile: show items, cart accessible via bottom sheet
    return Stack(
      children: [
        _buildItemsPanel(),
        if (cart.items.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildMobileCartBar(cart),
          ),
      ],
    );
  }

  Widget _buildItemsPanel() {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final itemsAsync = ref.watch(itemsStreamProvider(_selectedCategoryId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search (name, SKU, barcode)
          SizedBox(
            width: 280,
            child: TextField(
              placeholder: Text(t.common.search),
              onChanged: (v) => setState(() => _searchQuery = v),
              onSubmitted: (v) => _searchBarcode(v.trim()),
            ),
          ),
          const SizedBox(height: 12),

          // Category chips
          categoriesAsync.when(
            data: (categories) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _catChip(null, t.common.all),
                  ...categories.map((c) => _catChip(c.id, c.name)),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 32),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 12),

          // Items grid
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _searchQuery.isEmpty
                    ? items
                    : items
                        .where((i) {
                          final q = _searchQuery.toLowerCase();
                          return i.name.toLowerCase().contains(q) ||
                              (i.sku?.toLowerCase().contains(q) ?? false) ||
                              (i.barcode?.toLowerCase().contains(q) ?? false);
                        })
                        .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(t.items.noItems,
                        style: TextStyle(
                            color: theme.colorScheme.mutedForeground)),
                  );
                }
                return _buildGrid(filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catChip(String? id, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Button(
        style: _selectedCategoryId == id
            ? const ButtonStyle.primary(density: ButtonDensity.compact)
            : const ButtonStyle.outline(density: ButtonDensity.compact),
        onPressed: () => setState(() => _selectedCategoryId = id),
        child: Text(label),
      ),
    );
  }

  Widget _buildGrid(List<Item> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 500
                ? 3
                : 2;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _PosItemCard(
              item: item,
              onTap: () => _handleItemTap(item),
            );
          },
        );
      },
    );
  }

  Future<void> _handleItemTap(Item item) async {
    // Check if item has variants
    final variantGroups =
        await ref.read(variantRepositoryProvider).getGroups(item.id);
    if (variantGroups.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (_) => VariantPickerDialog(
          item: item,
          onSelected: (variant) {
            _handleModifiersForItem(item, variant: variant);
          },
        ),
      );
      return;
    }
    // Check if item has modifiers
    await _handleModifiersForItem(item);
  }

  Future<void> _handleModifiersForItem(Item item, {Variant? variant}) async {
    final modGroups =
        await ref.read(modifierRepositoryProvider).getGroupsForItem(item.id);
    if (modGroups.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (_) => ModifierPickerDialog(
          item: item,
          onConfirmed: (modifiers) {
            ref.read(cartProvider.notifier).addItem(
                  item,
                  variant: variant,
                  modifiers: modifiers,
                );
          },
        ),
      );
      return;
    }
    ref.read(cartProvider.notifier).addItem(item, variant: variant);
  }

  /// Barcode/SKU scan — lookup item and add to cart directly
  Future<void> _searchBarcode(String code) async {
    if (code.isEmpty) return;
    final auth = ref.read(authProvider);
    final storeId = auth.currentStoreId ?? '';
    final repo = ref.read(itemRepositoryProvider);

    // Try barcode first
    var item = await repo.getByBarcode(code, storeId);
    if (item == null) {
      // Try variant barcode
      final variant =
          await ref.read(variantRepositoryProvider).findVariantByBarcode(code);
      if (variant != null) {
        final parentItem = await repo.getById(variant.itemId);
        if (parentItem != null) {
          ref.read(cartProvider.notifier).addItem(parentItem, variant: variant);
          return;
        }
      }
    }
    if (item != null) {
      _handleItemTap(item);
    }
  }

  // ── Cart panel (desktop/tablet right side) ──
  Widget _buildCartPanel(CartState cart) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(t.sales.newSale,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Button(
                  style: const ButtonStyle.ghost(density: ButtonDensity.compact),
                  onPressed: () => context.push('/sales/receipts'),
                  child: const Icon(RadixIcons.reader, size: 18),
                ),
                if (cart.items.isNotEmpty)
                  Button(
                    style: const ButtonStyle.ghost(density: ButtonDensity.compact),
                    onPressed: () => ref.read(cartProvider.notifier).clear(),
                    child: Text(t.sales.clearCart,
                        style: TextStyle(
                            color: theme.colorScheme.destructive, fontSize: 12)),
                  ),
              ],
            ),
          ),
          // Customer assign
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CustomerBadge(
              customerId: cart.customerId,
              onAssign: () => _showCustomerAssign(context),
              onClear: () => ref.read(cartProvider.notifier).setCustomer(null),
            ),
          ),
          const Divider(),

          // Cart items
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Text(t.sales.noItemsInCart,
                        style: TextStyle(
                            color: theme.colorScheme.mutedForeground)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final ci = cart.items[index];
                      return _CartItemRow(
                        cartItem: ci,
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .incrementQuantity(ci.cartKey),
                        onDecrement: () => ref
                            .read(cartProvider.notifier)
                            .decrementQuantity(ci.cartKey),
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .removeItem(ci.cartKey),
                      );
                    },
                  ),
          ),
          const Divider(),

          // Totals
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _totalRow(t.common.subtotal, CurrencyService.format(cart.subtotal, cart.currencyCode)),
                if (cart.taxAmount > 0)
                  _totalRow(t.common.tax, CurrencyService.format(cart.taxAmount, cart.currencyCode)),
                if (cart.orderDiscount > 0)
                  _totalRow(t.common.discount, '-${CurrencyService.format(cart.orderDiscount, cart.currencyCode)}'),
                const SizedBox(height: 4),
                _totalRow(t.common.total, CurrencyService.format(cart.total, cart.currencyCode),
                    bold: true, large: true),
              ],
            ),
          ),

          // Dining option selector (2.9)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _diningChip(OrderType.dineIn, t.sales.dineIn, cart.orderType),
                const SizedBox(width: 6),
                _diningChip(
                    OrderType.takeaway, t.sales.takeaway, cart.orderType),
                const SizedBox(width: 6),
                _diningChip(
                    OrderType.delivery, t.sales.delivery, cart.orderType),
              ],
            ),
          ),

          // Pay button + Hold
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    style: const ButtonStyle.primary(size: ButtonSize.large),
                    onPressed: cart.isEmpty ? null : () => _showPaymentDialog(),
                    child: Text(
                      '${t.sales.charge}  ${CurrencyService.format(cart.total, cart.currencyCode)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (cart.items.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      style: const ButtonStyle.outline(),
                      onPressed: () => _holdTicket(cart),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(RadixIcons.timer, size: 14),
                          const SizedBox(width: 6),
                          const Text('Hold Ticket'),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value,
      {bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: large ? 18 : 14)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: large ? 18 : 14)),
        ],
      ),
    );
  }

  // ── Mobile cart bar ──
  Widget _buildMobileCartBar(CartState cart) {
    final t = Translations.of(context);
    return Button(
      style: const ButtonStyle.primary(size: ButtonSize.large),
      onPressed: () => _showPaymentDialog(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${cart.itemCount} ${t.items.allItems}'),
          Text('₭${cart.total.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    final auth = ref.read(authProvider);
    if (auth.currentStoreId == null) return;
    showDialog(
      context: context,
      builder: (_) => PaymentDialog(
        storeId: auth.currentStoreId!,
        employeeId: auth.currentEmployee?.id ?? '',
      ),
    );
  }

  void _showCustomerAssign(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomerAssignDialog(
        onSelected: (customerId) {
          ref.read(cartProvider.notifier).setCustomer(customerId);
        },
      ),
    );
  }

  Widget _diningChip(OrderType type, String label, OrderType current) {
    return Expanded(
      child: Button(
        style: current == type
            ? const ButtonStyle.primary(density: ButtonDensity.compact)
            : const ButtonStyle.outline(density: ButtonDensity.compact),
        onPressed: () => ref.read(cartProvider.notifier).setOrderType(type),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  // Hold ticket — stores cart state for later retrieval
  static final List<CartState> _heldTickets = [];

  void _holdTicket(CartState cart) {
    _heldTickets.add(cart);
    ref.read(cartProvider.notifier).clear();
    showToast(
      context: context,
      builder: (_, overlay) => SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Basic(
            title: const Text('Ticket held'),
            subtitle: Text('${_heldTickets.length} ticket(s) on hold'),
          ),
        ),
      ),
    );
  }
}

// ── Customer Badge ──
class _CustomerBadge extends ConsumerWidget {
  final String? customerId;
  final VoidCallback onAssign;
  final VoidCallback onClear;

  const _CustomerBadge({
    this.customerId,
    required this.onAssign,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    if (customerId == null) {
      return GestureDetector(
        onTap: onAssign,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(RadixIcons.person,
                  size: 14, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 6),
              Text(t.customers.assignCustomer,
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground)),
            ],
          ),
        ),
      );
    }

    // Show customer name
    final db = ref.watch(databaseProvider);
    return FutureBuilder(
      future: (db.select(db.customers)
            ..where((t) => t.id.equals(customerId!)))
          .getSingleOrNull(),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? '...';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(RadixIcons.person, size: 14, color: Colors.green),
              const SizedBox(width: 6),
              Text(name,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: onClear,
                child: Icon(RadixIcons.cross2,
                    size: 12, color: theme.colorScheme.mutedForeground),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── POS Item Card ──
class _PosItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const _PosItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(RadixIcons.cube, size: 28,
                  color: theme.colorScheme.mutedForeground),
              const SizedBox(height: 6),
              Text(item.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('₭${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cart Item Row ──
class _CartItemRow extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.item.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (cartItem.variant != null)
                  Text(cartItem.variant!.name,
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary)),
                if (cartItem.modifiers.isNotEmpty)
                  Text(
                    cartItem.modifiers.map((m) => m.name).join(', '),
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.mutedForeground),
                  ),
                Text('₭${cartItem.unitPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground)),
              ],
            ),
          ),
          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.outline(
                icon: const Icon(RadixIcons.minus, size: 14),
                onPressed: onDecrement,
                variance: ButtonVariance.outline,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${cartItem.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              IconButton.outline(
                icon: const Icon(RadixIcons.plus, size: 14),
                onPressed: onIncrement,
                variance: ButtonVariance.outline,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text('₭${cartItem.lineTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
