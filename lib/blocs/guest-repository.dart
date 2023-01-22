// ignore_for_file: missing_return, unnecessary_statements

import 'package:fnf_guest_list/models/assigned-ticket.dart';
import 'package:fnf_guest_list/models/record.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guest.dart';
import '../models/ticket.dart';
import '../models/contract.dart';

abstract class GuestRepositoryInterface {
  Future<List<Guest>> refreshAll();
  Future<List<Ticket>> getTickets();
  Future<Guest> getById(int id);
  Future<Ticket> getTicketById(int id);
  Guest getByIdLocal(int id);
  Future<List<Guest>> filterGuests(String search);
  Future<List<Ticket>> transferTickets(Guest owner);
  Future<Ticket> transferTicket(Record record);
  Future<Ticket> redeemTicket(Ticket ticket);
  Future<Guest> signWaiver(Guest owner);
  Future<String> setHost(String host);
}

class GuestRepository implements GuestRepositoryInterface {
  List<Guest> guests;
  List<Guest> _all;
  List<Ticket> _tickets;
  List<Ticket> tickets;

  @override
  Future<String> setHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('host', host);
    return host;
  }

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
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      final response = await http.get("$host/users/$id");

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

  @override
  Future<Ticket> getTicketById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      final response = await http.get("$host/tickets/$id");

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var ticketJson = jsonDecode(response.body) as Map<String, dynamic>;
        var ticket = Ticket.fromJson(ticketJson);
        return ticket;
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
      return guestString.contains(search);
    }).toList();
    guests.sort((a, b) {
      var aYes = a.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    guests.sort((a, b) {
      var aYes = a.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    return guests;
  }

  Future<List<Ticket>> filterTickets(String search) async {
    search = search.toLowerCase();
    var tickets = _tickets.where((ticket) {
      var ticketString = "";
      if (ticket.owner.name != null) ticketString += ticket.owner.name.toLowerCase();
      if (ticket.originalOwner.name != null) ticketString += ticket.originalOwner.name.toLowerCase();
      if (ticket.owner.license_plate != null) ticketString += ticket.owner.license_plate.toLowerCase();
      if (ticket.owner.license_plate != null) ticketString += ticket.owner.license_plate;
      return ticketString.contains(search);
    }).toList();

    tickets.sort((a, b) {
      var aYes = a.owner.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.owner.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    tickets.sort((a, b) {
      var aYes = a.owner.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.owner.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });

    return tickets;
  }

  Future<List<Guest>> filterGuestsByName (String search) async {
    search = search.toLowerCase();
    var guests = _all.where((guest) {
      var guestString = "";
      if (guest.name != null) guestString += guest.name.toLowerCase();
      return guestString.contains(search);
    }).toList();
    guests.sort((a, b) {
      var aYes = a.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    guests.sort((a, b) {
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
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      final response = await http.get("$host/users", headers: { 'Content-Type' : 'application/json' });

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var guestsJson = jsonDecode(response.body) as List<dynamic>;
        guests = guestsJson.map((dynamic guestJson) =>
            Guest.fromJson(guestJson)).toList();

        guests.sort((a, b) => a.name.compareTo(b.name));

        _all = guests;
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
  Future<List<Ticket>> getTickets() async {
    try {
      print("in getTickets");
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      final response = await http.get("$host/tickets", headers: { 'Content-Type' : 'application/json' });

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var ticketsJson = jsonDecode(response.body) as List<dynamic>;
        tickets = ticketsJson.map((dynamic ticketJson) =>
            Ticket.fromFullJson(ticketJson)).toList();

        //
        // tickets.sort((a, b) {
        //   var aYes = a.redeemed ? 1 : 0;
        //   var bYes = b.redeemed ? 1 : 0;
        //   return aYes - bYes;
        // });


        tickets.sort((a, b) => a.owner.name.compareTo(b.owner.name));



        _tickets = tickets;
        return tickets;
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
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      print("in transferTickets ${owner.contract.records.toString()}");
      var body = jsonEncode(owner.contract);
      var response = await http.post("$host/tickets/transfer",
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

    @override
  Future<Ticket> transferTicket(Record record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      print("in transferTickets ${record.toString()}");
      Contract contract = Contract(<Record>[record]);
      var body = jsonEncode(contract);
      var response = await http.post("$host/tickets/transfer",
          headers: { 'Content-Type' : 'application/json' },
          body: body
      );

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var ticketsJson = jsonDecode(response.body) as List<dynamic>;
        var tickets = ticketsJson.map((dynamic ticketJson) => Ticket.fromJson(ticketJson)).toList();
        return tickets[0];
      } else {
        throw Exception('Failed to transfer tickets');
      }
    }
    catch (e) {
      throw Exception("Failed to transfer tickets ${e.toString()}");
    }
  }

        @override
  Future<Ticket> redeemTicket(Ticket ticket) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      final int id = ticket.ticketId;
      final response = await http.get("$host/tickets/redeem/$id");

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var ticketJson = jsonDecode(response.body) as Map<String, dynamic>;
        var ticket = Ticket.fromJson(ticketJson);
        return ticket;
      }
    }
    catch (e) {
      throw Exception("Failed to transfer tickets ${e.toString()}");
    }
  }

  @override
  Future<Guest> signWaiver(Guest owner) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String host = await prefs.getString('host');
      var body = jsonEncode(owner.toJson());
      final response = await http.post("$host/users/waiver",
          headers: { 'Content-Type' : 'application/json' },
          body: body
      );
      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var guestJson = jsonDecode(response.body) as Map<String, dynamic>;
        var guest = Guest.fromJson(guestJson);
        return guest;
      }
    }
    catch (e) {
      throw Exception("Failed to sign waiver ${e.toString()}");
    }
  }


}


class NetworkError extends Error {}