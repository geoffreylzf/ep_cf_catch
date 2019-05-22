class TempCfCatchDetail {
  int id, houseNo, age, qty, cageQty, coverQty, isBt;
  double weight;

  TempCfCatchDetail({
    this.id,
    this.houseNo,
    this.age,
    this.qty,
    this.weight,
    this.cageQty,
    this.coverQty,
    this.isBt,
  });

  factory TempCfCatchDetail.fromJson(Map<String, dynamic> json) =>
      TempCfCatchDetail(
        id: json["id"],
        houseNo: json["house_no"],
        age: json["age"],
        qty: json["qty"],
        weight: json["weight"],
        cageQty: json["cage_qty"],
        coverQty: json["cover_qty"],
        isBt: json["is_bt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "house_no": houseNo,
        "age": age,
        "qty": qty,
        "weight": weight,
        "cage_qty": cageQty,
        "cover_qty": coverQty,
        "is_bt": isBt,
      };
}
