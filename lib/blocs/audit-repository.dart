// ignore_for_file: missing_return, unnecessary_statements

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/audit.dart';

abstract class AuditRepositoryInterface {
  Future<List<Audit>> refreshAll();
}

class AuditRepository implements AuditRepositoryInterface {
  List<Audit> audits = [];
  List<Audit> _all = [];

  @override
  Future<List<Audit>> refreshAll() async {
    try {
      print("in refreshAll events");
      final response = await http.get("http://localhost:7777/audit", headers: { 'Content-Type' : 'application/json' });

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var auditsJson = jsonDecode(response.body) as List<dynamic>;
        audits = auditsJson.map((dynamic guestJson) =>
            Audit.fromJson(guestJson)).toList();

        print(audits);
        _all = audits;
        return audits;
      } else {
        throw Exception('Failed to load audit log');
      }
    }
    catch (e) {
      throw Exception("Failed to fetch events ${e.toString()}");
    }
  }


  Future<List<Audit>> filterAudits(String search) async {
    search = search.toLowerCase();
    var _audits = _all.where((audit) {
      var auditString = "";
      if (audit.action != null) auditString += audit.action.toLowerCase();
//      if (guest.email != null) guestString += guest.email.toLowerCase();
//      if (guest.phone != null) guestString += guest.phone.toLowerCase();
      return auditString.contains(search);
    }).toList();
    _audits.sort((a, b) {
      var aYes = a.to.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.to.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    _audits.sort((a, b) {
      var aYes = a.to.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.to.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    return _audits;
  }

  Future<List<Audit>> filterAuditsByName (String search) async {
    search = search.toLowerCase();
    var _audits = _all.where((audit) {
      var auditString = "";
      if (audit.to.name != null) auditString += audit.to.name.toLowerCase();
      return auditString.contains(search);
    }).toList();
    _audits.sort((a, b) {
      var aYes = a.to.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.to.lastName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    _audits.sort((a, b) {
      var aYes = a.to.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      var bYes = b.to.firstName().toLowerCase().startsWith(search) ? 1 : 0;
      return bYes - aYes;
    });
    return _audits;
  }

}


class NetworkError extends Error {}