import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fnf_guest_list/models/guest.dart';
import './guest.dart';

class GuestListBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository guestRepository;

  GuestListBloc(this.guestRepository);

  @override
  GuestState get initialState => GuestsInitial();

  @override
  Stream<GuestState> mapEventToState(GuestEvent event) async* {
    yield GuestsLoading();

    print("event $event");
    // NO SUPPORT FOR A SWITCH STATEMENT ON TYPES IN DART
    if (event is GetGuest) {
      try {
        final guest = await guestRepository.getById(event.userId);
        yield GuestLoaded(guest);
      } on NetworkError {
        yield GuestsError("Couldn't fetch guest. Is the device online?");
      }
    }

    else if (event is GetGuestLocal) {
      try {
        final guest = guestRepository.getByIdLocal(event.userId);
        yield GuestLoaded(guest);
      } on NetworkError {
        yield GuestsError("Couldn't fetch guest. Is the device online?");
      }
    }
    else if (event is GetGuests) {
      try {
        final guests = await guestRepository.refreshAll();
        yield GuestsLoaded(guests);
      } on NetworkError {
        yield GuestsError("Couldn't fetch guests. Is the device online?");
      }
    }

    else if (event is FilterGuests) {
      try {
        print("attempting to filter guests");
        List<Guest> guests = await guestRepository.filterGuests(event.search);
        if (guests.isNotEmpty) {
          yield GuestsLoaded(guests);
        }
        else {
          yield NoGuestsMatchSearch();
        }
      } on NetworkError {
        yield GuestsError("Couldn't fetch guests. Is the device online?");
      }
    }

    else if (event is FilterGuestsByName) {
      try {
        print("attempting to filter guests");
        List<Guest> guests = await guestRepository.filterGuestsByName(
            event.search);
        if (guests.isNotEmpty) {
          yield GuestsLoaded(guests);
        }
        else {
          yield NoGuestsMatchSearch();
        }
      } on NetworkError {
        yield GuestsError("Couldn't fetch guests. Is the device online?");
      }
    }



    else if (event is CheckGuestTicketsAssigned) {
      try {
        final guest = event.owner;
        var valid = guest.contract.valid();
        if (valid) {
          yield GuestTicketsAssigned(guest);
        }
        else {
          yield GuestLoaded(guest);
        }
      } on NetworkError {
        yield GuestsError("Couldn't fetch guest. Is the device online?");
      }
    }
  }
}