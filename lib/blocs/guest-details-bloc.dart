import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fnf_guest_list/blocs/ticket-events.dart' as TicketEvents;
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/models/ticket.dart';
import './guest.dart';

class GuestDetailsBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository guestRepository;

  GuestDetailsBloc(this.guestRepository) : super(GuestInitial());

  @override
  GuestState get initialState => GuestInitial();

  @override
  Stream<GuestState> mapEventToState(GuestEvent event) async* {
    if (event is GetGuest) {
      try {
        final guest = await guestRepository.getById(event.userId);
        yield GuestLoaded(guest);
      } on NetworkError {
        yield GuestsError("Couldn't fetch guest. Is the device online?");
      }
    } else if (event is GetGuestLocal) {
      try {
        final guest = guestRepository.getByIdLocal(event.userId);
        yield GuestLoaded(guest);
      } on NetworkError {
        yield GuestsError("Couldn't fetch guest. Is the device online?");
      }
    } else if (event is TransferTicket) {
      try {
        var ticket = await guestRepository.transferTicket(event.record);
        if (ticket != null) {
          final Guest guest = await guestRepository.getById(ticket.userId);
          // load guest info for newly assigned ticket
          // yield GuestLoaded(guest);
          yield TransferSuccessful(ticket, guest, event.owner);
        } else {
          yield GuestLoaded(event.owner);
        }
      } on NetworkError {
        yield GuestsError("Couldn't transfer tickets.");
      }
    } else if (event is PrepareToRedeem) {
      try {
        Ticket ticket = Ticket(
            event.ticket.ticketId,
            event.ticket.userId,
            event.redeem,
            event.ticket.updatedAt,
            event.ticket.createdAt,
            event.owner,
            event.originalOwner);
        event.owner.contract.records.forEach((element) {
          if (element.ticket == event.ticket) {
            element.setShouldRedeem(event.redeem);
          } else {
            // ensure that only one ticket can be redeemed at a time
            element.setShouldRedeem(false);
          }
        });
        final Guest guest = Guest(
            event.owner.userId,
            event.owner.name,
            event.owner.email,
            event.owner.phone,
            event.owner.tickets,
            event.owner.contract,
            event.owner.waiver,
            event.owner.health,
            event.owner.license_plate,
            event.owner.early_arrival,
            event.owner.early_arrival_role);
        if (event.redeem) {
          yield TicketReadyToRedeem(guest, ticket);
        } else {
          yield GuestLoaded(guest);
        }
      } catch (e) {
        throw Exception("Couldn't prepare to redeem ticket: ${e.toString()}");
      }
    } else if (event is RedeemTicket) {
      try {
        Ticket updatedTicket = await guestRepository.redeemTicket(event.ticket);
        if (updatedTicket != null && updatedTicket.redeemed) {
          yield TicketRedeemed(updatedTicket);
        } else {
          Guest guest = await guestRepository.getById(event.ticket.userId);
          yield GuestLoaded(guest);
        }
      } on NetworkError {
        yield GuestsError("Couldn't transfer tickets.");
      }
    } else if (event is SignWaiver) {
      try {
        final Guest guestWithLicense = Guest(
            event.owner.userId,
            event.owner.name,
            event.owner.email,
            event.owner.phone,
            event.owner.tickets,
            event.owner.contract,
            event.owner.waiver,
            event.owner.health,
            event.license,
            event.owner.early_arrival,
            event.owner.early_arrival_role);
        Guest guest = await guestRepository.signWaiver(guestWithLicense);
        if (guest != null && guest.waiver != null) {
          Ticket updatedTicket =
              await guestRepository.redeemTicket(event.ticket);
          if (updatedTicket != null && updatedTicket.redeemed) {
            yield TicketRedeemed(updatedTicket);
          } else {
            Guest guest = await guestRepository.getById(event.ticket.userId);
            yield GuestLoaded(guest);
          }
        } else {
          Guest guest = await guestRepository.getById(event.ticket.userId);
          yield GuestLoaded(guest);
        }
      } on NetworkError {
        yield GuestsError("Couldn't transfer tickets.");
      }
    }
  }
}
