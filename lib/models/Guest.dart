import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Ticket {
  final int ticketId;
  final int userId;
  final bool redeemed;
  final String redeemedAt;
  final String createdAt;

  Ticket(this.ticketId, this.userId, this.redeemed, this.redeemedAt, this.createdAt);

  factory Ticket.fromJson(dynamic json) {
    return Ticket(
      json['ticket_id'] as int,
      json['user_id'] as int,
      json['redeemed'] as bool,
      json['updated_at'] as String,
      json['created_at'] as String
    );
  }
}

class Guest {
  final int userId;
  final String name;
  final String email;
  final String phone;
  final List<Ticket> tickets;

  Guest(this.userId, this.name, this.email, this.phone, this.tickets);

  int numTickets() {
    return tickets.length;
  }

  Ticket getTicketByPosition(int index) {
    if (tickets.isNotEmpty) {
      return tickets[index];
    }
  }

  String firstName() {
    if (this.name != null) {
      return this.name.split(" ")[0];
    }
  }

  factory Guest.fromJson(dynamic json) {
    var _tickets = json['tickets'].map((dynamic ticketJson) => Ticket.fromJson(ticketJson)).toList() as List<dynamic>;
    List<Ticket> tickets = _tickets.cast<Ticket>().toList();


    return Guest(
        json['user_id'] as int,
        json['name'] as String,
        json['email'] as String,
        json['phone'] as String,
        tickets as List<Ticket>
    );
  }
}

class GuestModel with ChangeNotifier {
  List<Guest> _guests = [];
  List<Guest> _allGuests = [];

  notifyListeners();

  void setGuests(List<Guest> newGuests) {
    _guests = newGuests;
    notifyListeners();
  }

  GuestModel() {
    refreshAll();
  }

  Guest getByPosition(int index) {
    if (_guests.isNotEmpty) {
      return _guests[index];
    }
  }

  Guest getById(int id) {
    if (_guests.isNotEmpty) {
      var guest = _guests.firstWhere((guest) => guest.userId == id, orElse: () => null);
      return guest;
    }
  }

  Future<void> filterGuests(String search) async {
    search = search.toLowerCase();
    var guests = _allGuests.where((guest) {
      var guestString = "";
      if (guest.name != null) guestString += guest.name.toLowerCase();
      if (guest.email != null) guestString += guest.email.toLowerCase();
      if (guest.phone != null) guestString += guest.phone.toLowerCase();
      return guestString.contains(search);
    }).toList();
    setGuests(guests);
  }

  Future<List<Guest>> searchGuests(String search) async {
    if (search == "") return null;
    var lowerSearch = search.toLowerCase();
    var guests = _allGuests.where((guest) {
      var guestString = "";
      if (guest.name != null) guestString += guest.name.toLowerCase();
      return guestString.contains(lowerSearch);
    }).toList();
    return guests;
  }

  int size() {
    return _guests.length - 1;
  }

  Future<void> refreshAll() async {
    try {
      final response = await http.get('http://10.0.0.9:7777/users');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        var usersJson = jsonDecode(response.body) as List<dynamic>;
        List<Guest> guests = usersJson.map((dynamic userJson) =>
            Guest.fromJson(userJson)).toList();

        guests.sort((a, b) => a.name.compareTo(b.name));

        _allGuests = guests;

        setGuests(guests);
      } else {
        throw Exception('Failed to load guests');
      }
    }
    catch (e) {
      throw Exception("Failed to fetch guests ${e.toString()}");
    }
  }

  /// An unmodifiable view of the guests
  UnmodifiableListView<Guest> get guests => UnmodifiableListView(_guests);
}