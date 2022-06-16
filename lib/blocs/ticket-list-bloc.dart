import 'dart:async';
import 'package:bloc/bloc.dart';
import '../models/ticket.dart';
import './ticket.dart';
import './guest.dart';

class TicketListBloc extends Bloc<TicketEvent, TicketState> {
  final GuestRepository guestRepository;

  TicketListBloc(this.guestRepository);

  @override
  TicketState get initialState => TicketsInitial();

  @override
  Stream<TicketState> mapEventToState(TicketEvent event) async* {
    yield TicketsLoading();

    print("event $event");
    // NO SUPPORT FOR A SWITCH STATEMENT ON TYPES IN DART
    if (event is GetTicket) {
      try {
        Ticket ticket = await guestRepository.getTicketById(event.ticketId);
        yield TicketLoaded(ticket);
      } on NetworkError {
        yield TicketsError("Couldn't fetch tickets. Is the device online?");
      }
    }
    else if (event is GetTickets) {
      try {
        final tickets = await guestRepository.getTickets();
        yield TicketsLoaded(tickets);
      } on NetworkError {
        yield TicketsError("Couldn't fetch tickets. Is the device online?");
      }
    }

    else if (event is FilterTickets) {
      try {
        print("attempting to filter guests");
        List<Ticket> tickets = await guestRepository.filterTickets(event.search);
        if (tickets.isNotEmpty) {
          yield TicketsLoaded(tickets);
        }
        else {
          yield NoTicketsMatchSearch();
        }
      } on NetworkError {
        yield TicketsError("Couldn't fetch tickets. Is the device online?");
      }
    }
  }
}