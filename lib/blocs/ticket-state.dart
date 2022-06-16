import 'package:equatable/equatable.dart';
import '../models/guest.dart';
import '../models/ticket.dart';

abstract class TicketState extends Equatable {
  const TicketState();
}

class TicketsInitial extends TicketState {
  const TicketsInitial();
  @override
  List<Object> get props => [];
}

class TicketInitial extends TicketState {
  const TicketInitial();
  @override
  List<Object> get props => [];
}

class TicketsLoading extends TicketState {
  const TicketsLoading();
  @override
  List<Object> get props => [];
}

class TicketLoading extends TicketState {
  const TicketLoading();
  @override
  List<Object> get props => [];
}

class TicketsLoaded extends TicketState {
  final List<Ticket> tickets;
  const TicketsLoaded(this.tickets);
  @override
  List<Object> get props => [tickets];
}

class NoTicketsMatchSearch extends TicketState {
  const NoTicketsMatchSearch();
  @override
  List<Object> get props => [];
}

class TicketsError extends TicketState {
  final String message;
  const TicketsError(this.message);
  @override
  List<Object> get props => [message];
}

class TicketLoaded extends TicketState {
  final Ticket ticket;
  const TicketLoaded(this.ticket);
  @override
  List<Object> get props => [ticket];
}

class TicketReadyToRedeem extends TicketState {
  final Guest guest;
  final Ticket ticket;
  const TicketReadyToRedeem(this.guest, this.ticket);
  @override
  List<Object> get props => [ticket, ticket];
}

class TicketRedeemed extends TicketState {
  final Ticket ticket;
  const TicketRedeemed(this.ticket);
  @override
  List<Object> get props => [ticket];
}

class TransferSuccessful extends TicketState {
  final Guest guest;
  final Ticket ticket;
  final Ticket owner;
  const TransferSuccessful(this.ticket, this.guest, this.owner);
  @override
  List<Object> get props => [ticket, ticket, owner];
}

class WaiverSigned extends TicketState {
  final Ticket ticket;
  const WaiverSigned(this.ticket);
  @override
  List<Object> get props => [ticket];
}
