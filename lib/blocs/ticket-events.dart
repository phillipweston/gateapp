import 'package:equatable/equatable.dart';
import 'package:fnf_guest_list/models/ticket.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/models/record.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();
}

class GetTickets extends TicketEvent {
  const GetTickets();
  @override
  List<Object> get props => [];
}

class FilterTickets extends TicketEvent {
  final String search;
  const FilterTickets(this.search);
  @override
  List<Object> get props => [search];
}

class FilterTicketsByName extends TicketEvent {
  final String search;
  const FilterTicketsByName(this.search);
  @override
  List<Object> get props => [search];
}

class GetTicket extends TicketEvent {
  final int ticketId;
  const GetTicket(this.ticketId);
  @override
  List<Object> get props => [ticketId];
}

class GetTicketLocal extends TicketEvent {
  final int userId;
  const GetTicketLocal(this.userId);
  @override
  List<Object> get props => [userId];
}

class CheckGuestTicketsAssigned extends TicketEvent {
  final Guest owner;
  const CheckGuestTicketsAssigned(this.owner);
  @override
  List<Object> get props => [owner];
}

class CheckGuestTicketAssigned extends TicketEvent {
  final Guest owner;
  final Record record;
  const CheckGuestTicketAssigned(this.owner, this.record);
  @override
  List<Object> get props => [owner];
}

class TransferTicket extends TicketEvent {
  final Guest owner;
  final Record record;
  const TransferTicket(this.owner, this.record);
  @override
  List<Object> get props => [owner, record];
}

class SignHealth extends TicketEvent {
  final Ticket ticket;
  final Guest owner;
  final bool redeem;
  const SignHealth(this.owner, this.ticket, this.redeem);
  @override
  List<Object> get props => [ticket, owner, redeem];
}

class GenerateGuestWaiver extends TicketEvent {
  final Ticket ticket;
  const GenerateGuestWaiver(this.ticket);
  @override
  List<Object> get props => [ticket];
}
