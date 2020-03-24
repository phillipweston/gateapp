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
        final guest = guestRepository.getByIdLocal(event.userId as int);
        // if validate function
        var valid = true;
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