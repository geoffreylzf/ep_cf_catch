import 'package:ep_cf_catch/model/auth.dart';
import 'package:ep_cf_catch/model/table/branch.dart';
import 'package:ep_cf_catch/model/table/person_staff.dart';
import 'package:ep_cf_catch/model/upload_result.dart';

class ApiResponse<T> {
  final int cod;
  final T result;

  ApiResponse({this.cod, this.result});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var result;

    if (T == Auth) {
      result = Auth.fromJson(json['result']);
    } else if (T == UploadResult) {
      result = UploadResult.fromJson(json['result']);
    } else if (T.toString() == "List<Branch>") {
      result = List<Branch>.from(json["result"].map((x) => Branch.fromJson(x)));
    } else if (T.toString() == "List<PersonStaff>") {
      result = List<PersonStaff>.from(json["result"].map((x) => PersonStaff.fromJson(x)));
    }

    return ApiResponse(cod: json['cod'], result: result);
  }
}
