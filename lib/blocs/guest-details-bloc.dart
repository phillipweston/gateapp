import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fnf_guest_list/models/guest.dart';
import './guest.dart';

class GuestDetailsBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository guestRepository;

  GuestDetailsBloc(this.guestRepository);

  @override
  GuestState get initialState => GuestInitial();

  @override
  Stream<GuestState> mapEventToState(GuestEvent event) async* {
    yield GuestLoading();
    print("event $event");

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

    else if (event is CheckGuestTicketsAssigned) {
      try {
        Guest guest = event.owner; //
        var valid = guest.contract.valid();
        // updates record and saves it locally

        if (valid) { // validates whether contract is valid, all fields have two words at least
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