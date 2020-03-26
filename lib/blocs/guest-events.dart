import 'package:equatable/equatable.dart';
import 'package:fnf_guest_list/models/guest.dart';

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

class TransferTickets extends GuestEvent {
  final Guest owner;
  const TransferTickets(this.owner);
  @override
  List<Object> get props => [owner];
}
