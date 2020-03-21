import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fnf_guest_list/models/guest.dart';
import './guest.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository guestRepository;

  GuestBloc(this.guestRepository);

//  factory GuestBloc.add() => GuestBloc(GuestRepository())..add(GetGuests());

  @override
  GuestState get initialState => GuestsInitial();

//  void add (GuestEvent event) {
//    print("dispatch of event");
//    mapEventToState(event);
//  }

  @override
  Stream<GuestState> mapEventToState(GuestEvent event) async* {
    yield GuestsLoading();
    if (event is GetGuests) {
      try {
        final guests = await guestRepository.refreshAll();
        yield GuestsLoaded(guests);
      } on NetworkError {
        yield GuestsError("Couldn't fetch guests. Is the device online?");
      }
    } else if (event is FilterGuests) {
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
    } else if (event is GetGuest) {
      try {
        final guest = await guestRepository.getById(event.userId);
        yield GuestLoaded(guest);
      } on NetworkError {
        yield GuestsError("Couldn't fetch guest. Is the device online?");
      }
    }
  }

}