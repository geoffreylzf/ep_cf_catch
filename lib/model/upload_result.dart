class UploadResult {
  final List<int> cfCatchIdList;

  UploadResult({this.cfCatchIdList});

  factory UploadResult.fromJson(Map<String, dynamic> json) => UploadResult(
    cfCatchIdList: List<int>.from(json["cf_catch_id_list"].map((x) => x)),
  );
}
