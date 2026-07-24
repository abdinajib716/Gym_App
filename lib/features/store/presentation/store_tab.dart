import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/core.dart';
import '../../../core/utils/mobile_phone.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/store_models.dart';

class StoreTab extends StatefulWidget {
  const StoreTab({
    super.key,
    required this.products,
    required this.orders,
    required this.productDetail,
    required this.orderDetail,
    required this.purchase,
    required this.defaultPhone,
  });

  final Future<List<StoreProduct>> Function() products;
  final Future<List<StoreOrder>> Function() orders;
  final Future<StoreProduct> Function(String productId) productDetail;
  final Future<StoreOrder> Function(String orderId) orderDetail;
  final Future<StorePurchaseResult> Function({
    required String productId,
    required int quantity,
    required String phoneNumber,
    required String provider,
    required String currency,
  })
  purchase;
  final String? defaultPhone;

  @override
  State<StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  bool _loading = true;
  bool _showOrders = false;
  String? _error;
  List<StoreProduct> _products = [];
  List<StoreOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        widget.products(),
        widget.orders(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<StoreProduct>;
        _orders = results[1] as List<StoreOrder>;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _openProduct(StoreProduct product) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _StorePurchaseSheet(
        product: product,
        defaultPhone: widget.defaultPhone,
        productDetail: widget.productDetail,
        purchase: widget.purchase,
        onChanged: _load,
      ),
    );
  }

  Future<void> _openOrder(StoreOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _StoreOrderSheet(order: order, orderDetail: widget.orderDetail),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: LoadingIndicator(size: 36));
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.storefront),
                label: Text('Products'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(IconsaxPlusLinear.receipt_1),
                label: Text('Orders'),
              ),
            ],
            selected: {_showOrders},
            onSelectionChanged: (value) =>
                setState(() => _showOrders = value.single),
          ),
          const SizedBox(height: 14),
          if (_showOrders)
            _orders.isEmpty
                ? const EmptyState(
                    icon: IconsaxPlusLinear.receipt_1,
                    title: 'No store orders',
                    message: 'Your store purchases will appear here.',
                  )
                : Column(
                    children: _orders
                        .map(
                          (order) => _StoreOrderTile(
                            order,
                            onTap: () => _openOrder(order),
                          ),
                        )
                        .toList(),
                  )
          else
            _products.isEmpty
                ? const EmptyState(
                    icon: Icons.storefront,
                    title: 'No products',
                    message: 'Published store products will appear here.',
                  )
                : Column(
                    children: _products
                        .map(
                          (product) => _StoreProductTile(
                            product,
                            onTap: () => _openProduct(product),
                          ),
                        )
                        .toList(),
                  ),
        ],
      ),
    );
  }
}

class _StoreProductTile extends StatelessWidget {
  const _StoreProductTile(this.product, {required this.onTap});

  final StoreProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _StoreCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.borderRadiusMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppRemoteImage(image: product.image, height: 120),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(product.name, style: AppTextStyles.h3)),
                Text(
                  _money(product.price, product.currency),
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            if (product.category != null && product.category!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                product.category!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _StoreBadge(
                  label: product.isOutOfStock
                      ? 'Out of stock'
                      : '${product.availableQuantity} available',
                  color: product.isOutOfStock
                      ? AppColors.error
                      : AppColors.success,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: product.isOutOfStock ? null : onTap,
                  icon: const Icon(IconsaxPlusLinear.card_send),
                  label: const Text('Buy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreOrderTile extends StatelessWidget {
  const _StoreOrderTile(this.order, {required this.onTap});

  final StoreOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _StoreCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.borderRadiusMedium,
        child: Row(
          children: [
            AppAvatar(
              image: order.product?.image,
              fallbackIcon: Icons.storefront,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.product?.name ?? order.orderNumber,
                    style: AppTextStyles.h3,
                  ),
                  Text(
                    '${order.quantity} x ${_money(order.unitPrice, order.currency)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_money(order.totalAmount, order.currency)),
                _StoreBadge(
                  label: order.paymentStatus,
                  color: order.paymentStatus == 'PAID'
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePurchaseSheet extends StatefulWidget {
  const _StorePurchaseSheet({
    required this.product,
    required this.defaultPhone,
    required this.productDetail,
    required this.purchase,
    required this.onChanged,
  });

  final StoreProduct product;
  final String? defaultPhone;
  final Future<StoreProduct> Function(String productId) productDetail;
  final Future<StorePurchaseResult> Function({
    required String productId,
    required int quantity,
    required String phoneNumber,
    required String provider,
    required String currency,
  })
  purchase;
  final Future<void> Function() onChanged;

  @override
  State<_StorePurchaseSheet> createState() => _StorePurchaseSheetState();
}

class _StorePurchaseSheetState extends State<_StorePurchaseSheet> {
  late StoreProduct _product = widget.product;
  final _phone = TextEditingController();
  int _quantity = 1;
  String _provider = 'EVC_PLUS';
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _phone.text = widget.defaultPhone ?? '';
    _loadDetail();
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final product = await widget.productDetail(widget.product.id);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      AppSnackBar.error(context, error.message);
    }
  }

  void _setQuantity(int value) {
    setState(() {
      _quantity = value.clamp(1, _product.availableQuantity);
    });
  }

  Future<void> _buy() async {
    if (_product.isOutOfStock) return;
    if (_quantity > _product.availableQuantity) {
      AppSnackBar.error(context, 'Quantity cannot exceed available stock.');
      return;
    }
    final phone = normalizeSomaliaPhone(_phone.text);
    if (!_isSomaliaMobilePhone(phone)) {
      AppSnackBar.error(
        context,
        'Enter a valid Somalia phone number, for example 252612345678.',
      );
      return;
    }

    setState(() {
      _busy = true;
    });
    debugPrint(
      'Store purchase tap: product=${_product.id}, quantity=$_quantity, phone=$phone, provider=$_provider, currency=${_product.currency}',
    );
    AppSnackBar.info(
      context,
      'Sending Waafi prompt to $phone. Confirm it on your phone to create the order.',
    );
    try {
      final result = await widget.purchase(
        productId: _product.id,
        quantity: _quantity,
        phoneNumber: phone,
        provider: _provider,
        currency: _product.currency,
      );
      if (!mounted) return;
      debugPrint(
        'Store purchase response: status=${result.paymentStatus}, order=${result.order?.id ?? 'none'}, message=${result.displayMessage}',
      );
      final message = _purchaseMessage(result, phone);
      if (result.hasCreatedOrder) {
        AppSnackBar.success(context, message);
      } else if (result.isPending) {
        AppSnackBar.info(context, message);
      } else {
        AppSnackBar.error(context, message);
      }
      await widget.onChanged();
      if (!mounted) return;
      if (result.hasCreatedOrder) {
        Navigator.pop(context);
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      debugPrint(
        'Store purchase failed: status=${error.statusCode}, type=${error.type}, message=${error.message}',
      );
      AppSnackBar.error(context, _serverPaymentMessage(error, phone));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _product.price * _quantity;
    return _StoreSheet(
      title: _product.name,
      child: _loading
          ? const Center(child: LoadingIndicator(size: 28))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppRemoteImage(image: _product.image, height: 180),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _money(_product.price, _product.currency),
                        style: AppTextStyles.h2,
                      ),
                    ),
                    _StoreBadge(
                      label: _product.isOutOfStock
                          ? 'Out of stock'
                          : '${_product.availableQuantity} available',
                      color: _product.isOutOfStock
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ],
                ),
                if (_product.description != null &&
                    _product.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_product.description!),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton.outlined(
                      tooltip: 'Decrease quantity',
                      onPressed: _product.isOutOfStock || _quantity <= 1
                          ? null
                          : () => _setQuantity(_quantity - 1),
                      icon: const Icon(Icons.remove),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('$_quantity', style: AppTextStyles.h2),
                      ),
                    ),
                    IconButton.outlined(
                      tooltip: 'Increase quantity',
                      onPressed:
                          _product.isOutOfStock ||
                              _quantity >= _product.availableQuantity
                          ? null
                          : () => _setQuantity(_quantity + 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _phone,
                  labelText: 'Payment phone',
                  hintText: '252612345678',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _provider,
                  decoration: const InputDecoration(labelText: 'Provider'),
                  items: const [
                    DropdownMenuItem(
                      value: 'EVC_PLUS',
                      child: Text('EVC Plus'),
                    ),
                    DropdownMenuItem(value: 'JEEB', child: Text('Jeeb')),
                    DropdownMenuItem(value: 'ZAAD', child: Text('Zaad')),
                    DropdownMenuItem(value: 'SAHAL', child: Text('Sahal')),
                  ],
                  onChanged: (value) =>
                      setState(() => _provider = value ?? _provider),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Total',
                  value: _money(total, _product.currency),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: _product.isOutOfStock
                      ? 'Out of Stock'
                      : _busy
                      ? 'Sending Prompt'
                      : 'Pay with Waafi',
                  icon: IconsaxPlusLinear.card_send,
                  isLoading: _busy,
                  onPressed: _product.isOutOfStock ? null : _buy,
                ),
              ],
            ),
    );
  }
}

class _StoreOrderSheet extends StatelessWidget {
  const _StoreOrderSheet({required this.order, required this.orderDetail});

  final StoreOrder order;
  final Future<StoreOrder> Function(String orderId) orderDetail;

  @override
  Widget build(BuildContext context) {
    return _StoreSheet(
      title: order.orderNumber,
      child: FutureBuilder<StoreOrder>(
        future: orderDetail(order.id),
        initialData: order,
        builder: (context, snapshot) {
          final value = snapshot.data ?? order;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppRemoteImage(image: value.product?.image, height: 160),
              const SizedBox(height: 12),
              Text(
                value.product?.name ?? 'Store order',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 10),
              _InfoRow(label: 'Quantity', value: '${value.quantity}'),
              _InfoRow(
                label: 'Total',
                value: _money(value.totalAmount, value.currency),
              ),
              _InfoRow(label: 'Payment', value: value.paymentStatus),
              _InfoRow(label: 'Order', value: value.orderStatus),
              _InfoRow(label: 'Phone', value: value.buyerPhoneNumber),
              _InfoRow(label: 'Date', value: _date(value.orderDate)),
              if (value.evcTransactionReference != null)
                _InfoRow(
                  label: 'Reference',
                  value: value.evcTransactionReference!,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StoreSheet extends StatelessWidget {
  const _StoreSheet({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: EdgeInsets.only(
            left: DesignTokens.screenPadding,
            right: DesignTokens.screenPadding,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: 16),
            child,
          ],
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.backgroundWhite,
        borderRadius: DesignTokens.borderRadiusMedium,
        boxShadow: AppShadows.cardShadows,
      ),
      child: child,
    );
  }
}

class _StoreBadge extends StatelessWidget {
  const _StoreBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

String _money(double amount, String currency) {
  final clean = amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);
  return '$clean $currency';
}

String _date(DateTime? date) {
  if (date == null) return '-';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

bool _isSomaliaMobilePhone(String phone) {
  return RegExp(r'^2526[123]\d{7}$').hasMatch(phone);
}

String _purchaseMessage(StorePurchaseResult result, String phone) {
  if (result.hasCreatedOrder) {
    final order = result.order!;
    final orderLabel = order.orderNumber.isNotEmpty
        ? order.orderNumber
        : order.id;
    return 'Payment approved. Order $orderLabel created.';
  }
  final message = result.displayMessage;
  if (message == 'Payment was not completed' && result.isPending) {
    return 'Payment is pending. Confirm the Waafi prompt on $phone.';
  }
  return message;
}

String _serverPaymentMessage(ApiException error, String phone) {
  if (error.statusCode != null && error.statusCode! >= 500) {
    return 'Store payment reached the server but failed there. No order was created. Phone: $phone';
  }
  return error.message;
}
