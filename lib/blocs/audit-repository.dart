// ignore_for_file: missing_return, unnecessary_statements

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/audit.dart';

abstract class AuditRepositoryInterface {
  Future<List<Audit>> refreshAll();
  late List<Audit> _all;
  late List<Audit> audits;
}

class AuditRepository implements AuditRepositoryInterface {
  List<Audit> audits = [];
  List<Audit> _all = [];

  @override
  Future<List<Audit>> refreshAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? host = await prefs.getString('host');
      final response = await http.get(Uri.parse("$host/audit"),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200 && response.body.isNotEmpty == true) {
        var auditsJson = jsonDecode(response.body) as List<dynamic>;
        audits = auditsJson
            .map((dynamic auditJson) => Audit.fromJson(auditJson))
            .toList();

        _all = audits;
        return audits;
      } else {
        throw Exception('Failed to load audit log');
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Audit>> filterAudits(String search) async {
    search = search.toLowerCase();
    var _audits = _all.where((audit) {
      var auditString = "";
      if (audit.action != null) auditString += audit.action.toLowerCase();
      if (audit.to != null) auditString += audit.to.name.toLowerCase();
      if (audit.from != null) auditString += audit.from.name.toLowerCase();
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

  Future<List<Audit>> filterAuditsByName(String search) async {
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
