class PersonStaff {
  int id;
  String personCode, personName;

  PersonStaff({
    this.id,
    this.personCode,
    this.personName,
  });

  factory PersonStaff.fromJson(Map<String, dynamic> json) => PersonStaff(
        id: json["id"],
        personCode: json["person_code"],
        personName: json["person_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "person_code": personCode,
        "person_name": personName,
      };
}
