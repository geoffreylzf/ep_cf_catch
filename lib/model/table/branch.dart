class Branch {
  int id, companyId;
  String branchCode, branchName;

  Branch({
    this.id,
    this.companyId,
    this.branchCode,
    this.branchName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["id"],
        branchCode: json["branch_code"],
        branchName: json["branch_name"],
        companyId: json["company_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "branch_code": branchCode,
        "branch_name": branchName,
        "company_id": companyId,
      };
}
