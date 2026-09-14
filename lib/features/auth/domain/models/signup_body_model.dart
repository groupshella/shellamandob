import 'package:sixam_mart/common/utils/json_parser.dart';

class SignUpBodyModel {
  String? name;
  String? phone;
  String? password;
  String? refCode;

  SignUpBodyModel({
    this.name,
    this.phone,
    this.password,
    this.refCode,
  });

  SignUpBodyModel.fromJson(Map<String, dynamic> json) {
    name = json.parseString('name');
    phone = json.parseString('phone');
    password = json.parseString('password');
    refCode = json.parseString('ref_code');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone'] = phone;
    data['password'] = password;
    if (refCode != null && refCode!.isNotEmpty) {
      data['ref_code'] = refCode;
    }
    return data;
  }
}
