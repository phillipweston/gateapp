import 'package:equatable/equatable.dart';
import 'package:fnf_guest_list/models/ticket.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/models/record.dart';
abstract class GuestEvent extends Equatable {
  const GuestEvent();
}

class GetGuests extends GuestEvent {
  const GetGuests();
  @override
  List<Object> get props => [];
}

class FilterGuests extends GuestEvent {
  final String search;
  const FilterGuests(this.search);
  @override
  List<Object> get props => [search];
}

class FilterGuestsByName extends GuestEvent {
  final String search;
  const FilterGuestsByName(this.search);
  @override
  List<Object> get props => [search];
}

class GetGuest extends GuestEvent {
  final int userId;
  const GetGuest(this.userId);
  @override
  List<Object> get props => [userId];
}

class GetGuestLocal extends GuestEvent {
  final int userId;
  const GetGuestLocal(this.userId);
  @override
  List<Object> get props => [userId];
}

class CheckGuestTicketsAssigned extends GuestEvent {
  final Guest owner;
  const CheckGuestTicketsAssigned(this.owner);
  @override
  List<Object> get props => [owner];
}

class CheckGuestTicketAssigned extends GuestEvent {
  final Guest owner;
  final Record record;
  const CheckGuestTicketAssigned(this.owner, this.record);
  @override
  List<Object> get props => [owner];
}

class TransferTicket extends GuestEvent {
  final Guest owner;
  final Record record;
  const TransferTicket(this.owner, this.record);
  @override
  List<Object> get props => [owner, record];
}

class PrepareToRedeem extends GuestEvent {
  final Ticket ticket;
  final Guest owner;
  final bool redeem;
  const PrepareToRedeem(this.owner, this.ticket, this.redeem);
  @override
  List<Object> get props => [ticket, owner, redeem];
}

class RedeemTicket extends GuestEvent {
  final Ticket ticket;
  const RedeemTicket(this.ticket);
  @override
  List<Object> get props => [ticket];
}

class RedeemTickets extends GuestEvent {
  final Guest owner;
  const RedeemTickets(this.owner);
  @override
  List<Object> get props => [owner];
}

