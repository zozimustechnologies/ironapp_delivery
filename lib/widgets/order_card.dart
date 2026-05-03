import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/order_model.dart';
import 'status_badge.dart';

/// Card shown in the dashboard order list.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 10),

              // Address row
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.textMedium,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Item count + chevron
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_rounded,
                    size: 16,
                    color: AppColors.textMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
