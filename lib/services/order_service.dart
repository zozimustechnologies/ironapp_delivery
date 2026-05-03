import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import 'supabase_service.dart';

/// All Supabase interactions for orders.
/// Row-Level Security on the `orders` table is the primary data guard;
/// client-side filters here add an extra layer of defence.
class OrderService {
  OrderService._();

  static const _table = 'orders';

  static SupabaseClient get _client => SupabaseService.client;

  // ---------------------------------------------------------------------------
  // Realtime stream
  // ---------------------------------------------------------------------------

  /// Returns a live [Stream] of orders assigned to [riderId].
  ///
  /// Supabase Realtime pushes row-level changes so the list updates
  /// automatically when new orders are assigned or statuses change.
  /// Delivered orders are excluded — riders don't need to revisit them.
  static Stream<List<OrderModel>> watchRiderOrders(String riderId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('rider_id', riderId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .where((r) => r['status'] != 'delivered')
              .map(OrderModel.fromMap)
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Status mutations
  // ---------------------------------------------------------------------------

  /// Transitions an order from `ready` → `out_for_delivery`.
  /// The `.eq('status', 'ready')` guard prevents double-firing.
  static Future<void> startDelivery(String orderId) async {
    await _client
        .from(_table)
        .update({'status': 'out_for_delivery'})
        .eq('id', orderId)
        .eq('status', 'ready');
  }

  /// Transitions an order from `out_for_delivery` → `delivered`.
  /// The `.eq('status', 'out_for_delivery')` guard prevents double-firing.
  static Future<void> markDelivered(String orderId) async {
    await _client
        .from(_table)
        .update({'status': 'delivered'})
        .eq('id', orderId)
        .eq('status', 'out_for_delivery');
  }
}
