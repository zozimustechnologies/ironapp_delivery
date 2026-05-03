import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../widgets/status_badge.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loading = false;

  // ---------------------------------------------------------------------------
  // External launchers
  // ---------------------------------------------------------------------------

  Future<void> _openMaps() async {
    final order = widget.order;
    final Uri uri;

    if (order.latitude != null && order.longitude != null) {
      // Prefer precise coordinates
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${order.latitude},${order.longitude}'
        '&travelmode=driving',
      );
    } else {
      // Fall back to address string
      final encoded = Uri.encodeComponent(order.address);
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$encoded'
        '&travelmode=driving',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open Maps', isError: true);
    }
  }

  Future<void> _callCustomer() async {
    final uri = Uri.parse('tel:${widget.order.customerPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar('Could not place call', isError: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Status mutations
  // ---------------------------------------------------------------------------

  Future<void> _startDelivery() async {
    setState(() => _loading = true);
    try {
      await OrderService.startDelivery(widget.order.id);
      if (!mounted) return;
      _showSnackBar('Delivery started!');
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Failed to update status. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markDelivered() async {
    final confirmed = await _confirmDelivery();
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      await OrderService.markDelivered(widget.order.id);
      if (!mounted) return;
      _showSnackBar('Order delivered!');
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Failed to update. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _confirmDelivery() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delivery'),
        content: Text(
          'Mark delivery to ${widget.order.customerName} as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Delivered'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.success,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Center(child: StatusBadge(status: order.status, large: true)),
            const SizedBox(height: 20),

            // Customer info card
            _InfoCard(
              children: [
                _InfoRow(
                  icon: Icons.person_rounded,
                  label: 'Customer',
                  value: order.customerName,
                ),
                const _Divider(),
                _InfoRow(
                  icon: Icons.inventory_2_rounded,
                  label: 'Items',
                  value: '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contact & address card
            _InfoCard(
              children: [
                _InfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: order.customerPhone,
                ),
                const _Divider(),
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Address',
                  value: order.address,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick-action buttons: Call + Navigate
            Row(
              children: [
                Expanded(
                  child: _QuickButton(
                    icon: Icons.phone_rounded,
                    label: 'Call',
                    color: Colors.green,
                    onTap: _callCustomer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickButton(
                    icon: Icons.map_rounded,
                    label: 'Navigate',
                    color: Colors.blue,
                    onTap: _openMaps,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Primary delivery action
            if (order.isReady)
              _ActionButton(
                label: 'Start Delivery',
                icon: Icons.local_shipping_rounded,
                color: AppColors.warning,
                loading: _loading,
                onTap: _startDelivery,
              ),
            if (order.isOutForDelivery)
              _ActionButton(
                label: 'Mark Delivered',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                loading: _loading,
                onTap: _markDelivered,
              ),
            if (order.isDelivered)
              const Center(
                child: Text(
                  'This order has been delivered.',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 15),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable sub-widgets (private to this file)
// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 24, color: Color(0xFFEEEEEE));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onTap,
        icon: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, size: 26),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
