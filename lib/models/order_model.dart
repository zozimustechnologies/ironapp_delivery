/// Represents a single delivery order assigned to the current rider.
///
/// Maps directly to columns in the `orders` table in Supabase.
/// Only rider-relevant fields are exposed; internal batch/bundle data
/// is intentionally excluded.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.itemCount,
    required this.status,
    required this.riderId,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String address;
  final int itemCount;
  final String status;
  final String riderId;
  final double? latitude;
  final double? longitude;

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerName: map['customer_name'] as String? ?? '',
      customerPhone: map['customer_phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      itemCount: map['item_count'] as int? ?? 0,
      status: map['status'] as String? ?? 'ready',
      riderId: map['rider_id'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  bool get isReady => status == 'ready';
  bool get isOutForDelivery => status == 'out_for_delivery';
  bool get isDelivered => status == 'delivered';
}
