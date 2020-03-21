class Ticket {
  final int ticketId;
  final int userId;
  final bool redeemed;
  final String redeemedAt;
  final String createdAt;

  Ticket(this.ticketId, this.userId, this.redeemed, this.redeemedAt, this.createdAt);

  factory Ticket.fromJson(dynamic json) {
    return Ticket(
        json['ticket_id'] as int,
        json['user_id'] as int,
        json['redeemed'] as bool,
        json['updated_at'] as String,
        json['created_at'] as String
    );
  }
}
