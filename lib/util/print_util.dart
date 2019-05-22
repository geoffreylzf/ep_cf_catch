import 'package:ep_cf_catch/db/dao/branch_dao.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_dao.dart';
import 'package:ep_cf_catch/db/dao/cf_catch_detail_dao.dart';
import 'package:ep_cf_catch/module/shared_preferences_module.dart';

import 'date_time_util.dart';

const _lineLimit = 45;
const _halfLineLimit = 22;
const _halfLineSeparator = "----------------------|----------------------";
const _endLine = "--------------------END----------------------";

const _cageWithCoverWeight = 8;
const _cageWithoutCoverWeight = 7.6;

class PrintUtil {
  Future<String> generateCfCatchReceipt(int cfCatchId) async {
    var s = "";

    final cfCatch = await CfCatchDao().getById(cfCatchId);
    final company = await BranchDao().getCompanyById(cfCatch.companyId);
    final location = await BranchDao().getLocationById(cfCatch.locationId);
    final houseList = await CfCatchDetailDao().getHouseListByCfCatchId(cfCatchId);
    final user = await SharedPreferencesModule().getUser();

    s += _fmtLeftLine(company.branchName);
    s += _fmtLeftLine("Bill Timbangan Ayam");
    s += _fmtLeftLine("Location : " + location.branchName);
    s += _fmtLeftLine("Date             : " + cfCatch.recordDate);
    s += _fmtLeftLine("Document Number  : " + cfCatch.docNo);
    s += _fmtLeftLine("Truck Code       : " + cfCatch.truckNo);
    s += _fmtLeftLine("Reference Number : " + cfCatch.refNo);
    s += _fmtLeftLine("UUID : " + cfCatch.uuid);
    s += _fmtLeftLine();
    s += _fmtLeftLine("Umur : ");
    s += _fmtLeftLine("Ayam : ______________________");
    s += _fmtLeftLine();

    s += _fmtLeftLine(_halfLineSeparator);

    var ttlWeight = 0.00;
    var ttlQty = 0;
    var ttlCage = 0;
    var ttlCover = 0;

    await Future.forEach(houseList, (house) async {

      final ageList = await CfCatchDetailDao().getAgeListByCfCatchIdHouseNo(cfCatchId, house);

      s += _fmtLeftLine(" Kdg#: ${location.branchCode} $house (Age : ${ageList.map((i)=> i.toString()).join(",")})");
      s += _fmtLeftLine(_halfLineSeparator);
      s += _fmtLeftLine(_halfLine("  #    Weight  Qty  C ") + "|" + _halfLine("  #    Weight  Qty  C "));

      final detailList = await CfCatchDetailDao().getListByCfCatchIdHouseNo(cfCatchId, house);

      var ttlHouseWeight = 0.00;
      var ttlHouseQty = 0;
      final isOdd = detailList.length % 2 != 0;
      final rowNo = (detailList.length / 2).ceil();

      for (int i = 0; i < detailList.length; i++) {
        var leftLine = "";
        var rightLine = "";
        if (i < rowNo) {
          var no = (i + 1).toString().padLeft(3, "0");
          var weight = detailList[i].weight.toStringAsFixed(2).padLeft(9, " ");
          var qty = detailList[i].qty.toString().padLeft(5, " ");
          var cover = detailList[i].coverQty.toString().padLeft(3, " ");

          ttlHouseWeight += detailList[i].weight;
          ttlHouseQty += detailList[i].qty;
          ttlWeight += detailList[i].weight;
          ttlQty += detailList[i].qty;
          ttlCage += detailList[i].cageQty;
          ttlCover += detailList[i].coverQty;

          leftLine = " $no$weight$qty$cover";

          if (rowNo != (i + 1) || !isOdd) {
            var no2 = (i + 1 + rowNo).toString().padLeft(3, "0");
            var weight2 = detailList[i + rowNo].weight.toStringAsFixed(2).padLeft(9, " ");
            var qty2 = detailList[i + rowNo].qty.toString().padLeft(5, " ");
            var cover2 = detailList[i + rowNo].coverQty.toString().padLeft(3, " ");

            ttlHouseWeight += detailList[i + rowNo].weight;
            ttlHouseQty += detailList[i + rowNo].qty;
            ttlWeight += detailList[i + rowNo].weight;
            ttlQty += detailList[i + rowNo].qty;
            ttlCage += detailList[i + rowNo].cageQty;
            ttlCover += detailList[i + rowNo].coverQty;

            rightLine = " $no2$weight2$qty2$cover2";
          }

          s += _fmtLeftLine(_halfLine(leftLine) + "|" + _halfLine(rightLine));
        }
      }
      s += _fmtLeftLine(_halfLine() + "|" + _halfLine());
      s += _fmtLeftLine(_halfLine(" WGT: ${ttlHouseWeight.toStringAsFixed(2)} Kg") + "|" + _halfLine(" QTY: $ttlHouseQty heads"));
      s += _fmtLeftLine(_halfLineSeparator);
    });

    s += _fmtLeftLine();
    s += _fmtLeftLine("Jumlah Ayam:           " + _halfRightLine(ttlQty.toString() + " heads"));
    s += _fmtLeftLine("Jumlah Berat Kasar:    " + _halfRightLine(ttlWeight.toStringAsFixed(2) + " Kg   "));

    var ttlNoCover = ttlCage - ttlCover;
    var ttlCageWithCoverWeight = ttlCover * _cageWithCoverWeight;
    var ttlCageWithoutCoverWeight = ttlNoCover * _cageWithoutCoverWeight;
    var ttlCageWeight = ttlCageWithCoverWeight + ttlCageWithoutCoverWeight;

    s += _fmtLeftLine();
    s += _fmtLeftLine("Jumlah Kurungan:       " + _halfRightLine(ttlCage.toString() + " qty  "));
    s += _fmtLeftLine("Ada Tutupan:           " + _halfRightLine(ttlCageWithCoverWeight.toStringAsFixed(2) + " kg   "));
    s += _fmtLeftLine("Tanpa Tutupan:         " + _halfRightLine(ttlCageWithoutCoverWeight.toStringAsFixed(2) + " kg   "));
    s += _fmtLeftLine("Jumlah Berat Kurungan: " + _halfRightLine(ttlCageWeight.toStringAsFixed(2) + " kg   "));

    var netWeight = ttlWeight - ttlCageWeight;
    var avgWeight = netWeight / ttlQty;

    s += _fmtLeftLine();
    s += _fmtLeftLine("Jumlah Berat Bersih:   " + _halfRightLine(netWeight.toStringAsFixed(2) + " kg   "));
    s += _fmtLeftLine("Purata Seekor:         " + _halfRightLine(avgWeight.toStringAsFixed(2) + " kg   "));

    s += _fmtLeftLine();

     s += _fmtLeftLine("Printed by: " + user.username);

    s += _fmtLeftLine("Date: " + DateTimeUtil().getCurrentDate());
    s += _fmtLeftLine("Time: " + DateTimeUtil().getCurrentTime());
    s += _fmtLeftLine("-");
    s += _fmtLeftLine("-");
    s += _fmtLeftLine("-");
    s += _fmtLeftLine("-");
    s += _fmtLeftLine("  ---------------------       --------");
    s += _fmtLeftLine("    Mandor/Supervisor          Driver        ");
    s += _fmtLeftLine();
    s += _fmtLeftLine(_endLine);
    s += _fmtLeftLine();
    s += _fmtLeftLine();
    s += _fmtLeftLine();

    return s;
  }

  String _fmtLeftLine([String text = ""]) {
    if (text.length > _lineLimit) {
      String s = "";
      final count = (text.length / _lineLimit).ceil();

      for (int i = 0; i < count; i++) {
        int start = i * _lineLimit;
        int end = (i + 1) * _lineLimit;

        if (end > text.length) {
          end = text.length;
        }
        s += text.substring(start, end) + "\n";
      }
      return s;
    } else {
      return text.padRight(_lineLimit) + "\n";
    }
  }

  String _halfLine([String text = ""]) {
    if (text.length > _halfLineLimit) {
      return text.substring(0, _halfLineLimit);
    } else {
      return text.padRight(_halfLineLimit);
    }
  }

  String _halfRightLine([String text = ""]) {
    if (text.length > _halfLineLimit) {
      return text.substring(0, _halfLineLimit);
    } else {
      return text.padLeft(_halfLineLimit);
    }
  }
}
