import 'package:equatable/equatable.dart';

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

class GetGuest extends GuestEvent {
  final int userId;
  const GetGuest(this.userId);
  @override
  List<Object> get props => [userId];
}
