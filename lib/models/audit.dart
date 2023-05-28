import 'package:equatable/equatable.dart';

import 'audit-guest.dart';

class Audit extends Equatable {
  final int id;
  final String action;
  final AuditGuest to;
  final AuditGuest from;
  final String created_at;

  Audit(this.id, this.action, this.to, this.from, this.created_at);

  @override
  List<Object> get props => [
        id,
        action,
        to,
        from,
        // ticket,
        created_at
      ];

  factory Audit.fromJson(dynamic json) {
    var id = json['id'] as int;
    var action = json['action'] as String;
    var created_at = json['created_at'] as String;

    // Ticket ticket = Ticket.fromJson(json['ticket']) as Ticket;
    AuditGuest to = AuditGuest.fromJson(json['to']) as AuditGuest;
    AuditGuest from = AuditGuest.fromJson(json['from']) as AuditGuest;

    return Audit(
        id,
        action,
        to,
        from,
        // ticket,
        created_at);
  }
}
