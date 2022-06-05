import 'package:equatable/equatable.dart';

import 'ticket.dart';
import 'contract.dart';
import 'record.dart';

class AuditGuest extends Equatable  {
  final int userId;
  final String name;
  final String email;
  final String phone;

  AuditGuest(this.userId, this.name, this.email, this.phone);

  @override
  List<Object> get props => [
    userId,
    name,
    email,
    phone,
  ];

  String firstName() {
    if (this.name != null) {
      return this.name.split(" ")[0];
    }
    return "";
  }

  String lastName() {
    if (this.name != null) {
      var names = this.name.split(" ");
      if (names.length > 1) {
        return names[names.length - 1];
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  factory AuditGuest.fromJson(dynamic json) {
    return AuditGuest(
        json['user_id'] as int,
        json['name'] as String,
        json['email'] as String,
        json['phone'] as String
    );
  }
}
