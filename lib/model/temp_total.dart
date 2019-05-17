class TempTotal {
  final int ttlQty, ttlCage, ttlCover;
  final double ttlWeight;

  TempTotal({
    this.ttlQty,
    this.ttlCage,
    this.ttlCover,
    this.ttlWeight,
  });

  factory TempTotal.fromJson(Map<String, dynamic> json) => TempTotal(
    ttlQty: json["ttl_qty"],
    ttlWeight: json["ttl_weight"],
    ttlCage: json["ttl_cage"],
    ttlCover: json["ttl_cover"],
  );
}
