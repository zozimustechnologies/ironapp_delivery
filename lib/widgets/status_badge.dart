import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Pill badge that visualises an order's delivery status.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.large = false});

  final String status;

  /// When [large] is true the badge is rendered at a larger size
  /// (e.g. on the order detail screen).
  final bool large;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: large ? 15 : 12,
        ),
      ),
    );
  }

  static (String, Color) _resolve(String status) => switch (status) {
        'ready' => ('Ready', AppColors.ready),
        'out_for_delivery' => ('Out for Delivery', AppColors.outForDelivery),
        'delivered' => ('Delivered', AppColors.delivered),
        _ => (status, Colors.grey),
      };
}
