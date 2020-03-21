import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/guest.dart';

abstract class GuestRepositoryInterface {
  Future<List<Guest>> refreshAll();
  Future<Guest> getById(int id);
  Future<List<Guest>> filterGuests(String search);
}

class GuestRepository implements GuestRepositoryInterface {
  List<Guest> guests;
  List<Guest> _all;

  @override
  Future<Guest> getById(int id) async {
    try {
      final response = await http.get("http://10.0.0.9:7777/users/$id");

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
    return _all.where((guest) {
      var guestString = "";
      if (guest.name != null) guestString += guest.name.toLowerCase();
      if (guest.email != null) guestString += guest.email.toLowerCase();
      if (guest.phone != null) guestString += guest.phone.toLowerCase();
      return guestString.contains(search);
    }).toList();
  }

  @override
  Future<List<Guest>> refreshAll() async {
    try {
      print("in refreshAll");
      final response = await http.get('http://10.0.0.9:7777/users');

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
}

class NetworkError extends Error {}