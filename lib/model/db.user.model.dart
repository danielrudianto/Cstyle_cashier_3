class SQLUserModel {
  int? id;
  String userID;
  String employeeCode;

  SQLUserModel({
    this.id,
    required this.userID,
    required this.employeeCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userID': userID,
      'employeeCode': employeeCode,
    };
  }

  factory SQLUserModel.fromMap(Map<String, dynamic> map) {
    return SQLUserModel(
      id: map['id'],
      userID: map['userID'],
      employeeCode: map['employeeCode'],
    );
  }
}
