import 'package:equatable/equatable.dart';

class AssignedTicket {
  final int ticketId;
  final int userId;
  final bool redeemed;
  final String updatedAt;
  final String createdAt;
  final AssignedGuest owner;

  AssignedTicket(this.ticketId, this.userId, this.redeemed, this.updatedAt,
      this.createdAt, this.owner);

  factory AssignedTicket.fromJson(dynamic json) {
    var owner = AssignedGuest.fromJson(json['owner']);

    return AssignedTicket(
        json['ticket_id'] as int,
        json['user_id'] as int,
        json['redeemed'] as bool,
        json['updated_at'] as String,
        json['created_at'] as String,
        owner);
  }
}

class AssignedGuest extends Equatable {
  final int userId;
  final String name;
  final String email;

  AssignedGuest(this.userId, this.name, this.email);

  @override
  List<Object> get props => [
        userId,
        name,
        email,
      ];

  factory AssignedGuest.fromJson(dynamic json) {
    return AssignedGuest(json['user_id'] as int, json['name'] as String,
        json['email'] as String);
  }
}
