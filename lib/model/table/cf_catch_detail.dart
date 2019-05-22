import 'package:ep_cf_catch/model/table/temp_cf_catch_detail.dart';

class CfCatchDetail {
  int id, cfCatchId, houseNo, age, qty, cageQty, coverQty, isBt;
  double weight;

  CfCatchDetail({
    this.id,
    this.cfCatchId,
    this.houseNo,
    this.age,
    this.qty,
    this.cageQty,
    this.coverQty,
    this.isBt,
    this.weight,
  });

  CfCatchDetail.db({
    this.cfCatchId,
    this.houseNo,
    this.age,
    this.qty,
    this.cageQty,
    this.coverQty,
    this.isBt,
    this.weight,
  });

  factory CfCatchDetail.fromJson(Map<String, dynamic> json) => CfCatchDetail(
        id: json["id"],
        cfCatchId: json["cf_catch_id"],
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
        "cf_catch_id": cfCatchId,
        "house_no": houseNo,
        "age": age,
        "qty": qty,
        "weight": weight,
        "cage_qty": cageQty,
        "cover_qty": coverQty,
        "is_bt": isBt,
      };

  static List<CfCatchDetail> fromTempWithCfCatchId(
      int cfCatchId, List<TempCfCatchDetail> tempList) {
    final List<CfCatchDetail> detailList = [];

    tempList.forEach((temp) {
      detailList.add(CfCatchDetail.db(
          cfCatchId: cfCatchId,
          houseNo: temp.houseNo,
          age: temp.age,
          qty: temp.qty,
          cageQty: temp.cageQty,
          coverQty: temp.coverQty,
          weight: temp.weight,
          isBt: temp.isBt));
    });

    return detailList;
  }
}
