import 'package:fnf_guest_list/models/record-contract.dart';
import 'package:fnf_guest_list/models/ticket.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/guest.dart';

abstract class GuestRepositoryInterface {
  Future<List<Guest>> refreshAll();
  Future<Guest> getById(int id);
  Guest getByIdLocal(int id);
  Future<List<Guest>> filterGuests(String search);
  Future<List<Ticket>> transferTickets(Guest owner);
}

class GuestRepository implements GuestRepositoryInterface {
  List<Guest> guests;
  List<Guest> _all;

  @override
  Guest getByIdLocal(int id)  {
    try {
      return _all.firstWhere((guest) { guest.userId == id; });
    }
    catch (e) {
      throw Exception("Failed to lookup local guest $id ${e.toString()}");
    }
  }

  @override
  Future<Guest> getById(int id) async {
    try {
      final response = await http.get("http://10.0.0.155:7777/users/$id");

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var guestJson = jsonDecode(response.body) as Map<String, dynamic>;
        var guest = Guest.fromJson(guestJson);
        return guest;
      }
    }
    catch (e) {
      throw Exception("Failed to fetch guests ${e.toString()}");
    }
  }

  Future<List<Guest>> filterGuests(String search) async {
    search = search.toLowerCase();
    var guests = _all.where((guest) {
      var guestString = "";
      if (guest.name != null) guestString += guest.name.toLowerCase();
//      if (guest.email != null) guestString += guest.email.toLowerCase();
//      if (guest.phone != null) guestString += guest.phone.toLowerCase();
      return guestString.contains(search);
    }).toList();
    guests.sort((Guest a, Guest b) {
      var aYes = a.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    guests.sort((Guest a, Guest b) {
      var aYes = a.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    return guests;
  }

  Future<List<Guest>> filterGuestsByName (String search) async {
    search = search.toLowerCase();
    var guests = _all.where((guest) {
      var guestString = "";
      if (guest.name != null) guestString += guest.name.toLowerCase();
      return guestString.contains(search);
    }).toList();
    guests.sort((Guest a, Guest b) {
      var aYes = a.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    guests.sort((Guest a, Guest b) {
      var aYes = a.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    return guests;
  }

  @override
  Future<List<Guest>> refreshAll() async {
    try {
      print("in refreshAll");
      final response = await http.get('http://10.0.0.155:7777/users', headers: { 'Content-Type' : 'application/json' });

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var guestsJson = jsonDecode(response.body) as List<dynamic>;
        guests = guestsJson.map((dynamic guestJson) =>
            Guest.fromJson(guestJson)).toList();

        guests.sort((a, b) => a.name.compareTo(b.name));

        _all = guests;
        print(guests);
        return guests;
      } else {
        throw Exception('Failed to load guests');
      }
    }
    catch (e) {
      throw Exception("Failed to fetch guests ${e.toString()}");
    }
  }

  @override
  Future<List<Ticket>> transferTickets(Guest owner) async {
    try {
      print("in transferTickets ${owner.contract.records.toString()}");
      var body = jsonEncode(owner.contract);
      var response = await http.post('http://10.0.0.155:7777/tickets/transfer',
          headers: { 'Content-Type' : 'application/json' },
          body: body
      );


      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var ticketsJson = jsonDecode(response.body) as List<dynamic>;
        var tickets = ticketsJson.map((dynamic ticketJson) => Ticket.fromJson(ticketJson)).toList();
        print(tickets);
        return tickets;
      } else {
        throw Exception('Failed to transfer tickets');
      }
    }
    catch (e) {
      throw Exception("Failed to transfer tickets ${e.toString()}");
    }
  }
}


class NetworkError extends Error {}