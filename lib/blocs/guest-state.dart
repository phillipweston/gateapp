import 'package:equatable/equatable.dart';
import 'package:fnf_guest_list/models/ticket.dart';
import '../models/guest.dart';

abstract class GuestState extends Equatable {
  const GuestState();
}

class GuestsInitial extends GuestState {
  const GuestsInitial();
  @override
  List<Object> get props => [];
}

class GuestInitial extends GuestState {
  const GuestInitial();
  @override
  List<Object> get props => [];
}

class GuestsLoading extends GuestState {
  const GuestsLoading();
  @override
  List<Object> get props => [];
}

class GuestLoading extends GuestState {
  const GuestLoading();
  @override
  List<Object> get props => [];
}

class GuestsLoaded extends GuestState {
  final List<Guest> guests;
  const GuestsLoaded(this.guests);
  @override
  List<Object> get props => [guests];
}

class NoGuestsMatchSearch extends GuestState {
  const NoGuestsMatchSearch();
  @override
  List<Object> get props => [];
}

class GuestsError extends GuestState {
  final String message;
  const GuestsError(this.message);
  @override
  List<Object> get props => [message];
}

class GuestLoaded extends GuestState {
  final Guest guest;
  const GuestLoaded(this.guest);
  @override
  List<Object> get props => [guest];
}

class GuestTicketsAssigned extends GuestState {
  final Guest guest;
  const GuestTicketsAssigned(this.guest);
  @override
  List<Object> get props => [guest];
}

class TransferSuccessful extends GuestState {
  final List<Ticket> tickets;
  const TransferSuccessful(this.tickets);
  @override
  List<Object> get props => [tickets];
}
