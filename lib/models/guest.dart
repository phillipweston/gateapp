import 'package:equatable/equatable.dart';

import 'ticket.dart';
import 'contract.dart';
import 'record.dart';

class Guest extends Equatable {
  final int userId;
  final String name;
  final String email;
  final String? phone;
  final List<Ticket> tickets;
  final Contract contract;
  final String? waiver;
  final String? health;
  // ignore: non_constant_identifier_names
  final String? license_plate;
  // ignore: non_constant_identifier_names
  final bool? early_arrival;
  // ignore: non_constant_identifier_names
  final String? early_arrival_role;
  final String? reason;

  Guest(
      this.userId,
      this.name,
      this.email,
      this.phone,
      this.tickets,
      this.contract,
      this.waiver,
      this.health,
      this.license_plate,
      this.early_arrival,
      this.early_arrival_role,
      this.reason);

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        tickets,
        contract,
        waiver,
        health,
        license_plate,
        early_arrival,
        early_arrival_role,
        reason
      ];

  int numTickets() {
    return tickets.length;
  }

  Record? getTicketRecordByPosition(int index) {
    if (tickets.isNotEmpty) {
      return this.contract.records[index];
    }
    return null;
  }

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "user_id": userId,
      "name": name,
      "email": email,
      "phone": phone,
      "waiver": waiver,
      "health": health,
      "license_plate": license_plate,
      "early_arrival": early_arrival,
      "early_arrival_role": early_arrival_role,
      "reason": reason
    };
  }

  factory Guest.fromJson(dynamic json) {
    var name = json['name'] as String;

    List<dynamic> _tickets = json['tickets'] != null
        ? json['tickets']
            .map((dynamic ticketJson) => Ticket.fromJson(ticketJson))
            .toList() as List<dynamic>
        : <dynamic>[];

    List<Ticket> tickets = _tickets.cast<Ticket>().toList();

    var records = _tickets
        .map<Record>((dynamic ticket) =>
            Record(ticket as Ticket, ticket.owner.name, false))
        .toList();
    var contract = Contract(records);

    if (contract.records.isNotEmpty) {
      contract.records.elementAt(0).setName(name);
    }

    return Guest(
        json['user_id'] as int,
        name,
        json['email'] as String,
        json['phone'] as String?,
        tickets,
        contract,
        json['waiver'] as String?,
        json['health'] as String?,
        json['license_plate'] as String?,
        json['early_arrival'] as bool?,
        json['early_arrival_role'] as String?,
        json['reason'] as String?);
  }
}
