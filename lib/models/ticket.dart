import 'guest.dart';

class Ticket {
  final int ticketId;
  final int userId;
  final bool redeemed;
  final String updatedAt;
  final String createdAt;
  final Guest owner;
  final Guest originalOwner;

  Ticket(this.ticketId, this.userId, this.redeemed, this.updatedAt, this.createdAt, this.owner, this.originalOwner);

  factory Ticket.fromJson(dynamic json) {
    return Ticket(
        json['ticket_id'] as int,
        json['user_id'] as int,
        json['redeemed'] as bool,
        json['updated_at'] as String,
        json['created_at'] as String,
        null,
        null,
    );
  }


  factory Ticket.fromFullJson(dynamic json) {
    Guest originalOwner = Guest.fromJson(json['originalOwner']);
    Guest owner = Guest.fromJson(json['owner']);

    return Ticket(
        json['ticket_id'] as int,
        json['user_id'] as int,
        json['redeemed'] as bool,
        json['updated_at'] as String,
        json['created_at'] as String,
        owner,
        originalOwner
    );
  }

}
