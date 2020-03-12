import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  final int userId;
  final String name;
  final String email;
  final String phone;

  User(this.userId, this.name, this.email, this.phone);

  factory User.fromJson(dynamic json) {
    return User(
        json['user_id'] as int,
        json['name'] as String,
        json['email'] as String,
        json['phone'] as String
    );
  }
}

class UserModel with ChangeNotifier {
  List<User> _users = [];
  List<User> _allUsers = [];

  notifyListeners();

  void setUsers(List<User> newUsers) {
    _users = newUsers;
    notifyListeners();
  }

  UserModel() {
    fetchUsers();
  }

  User getByPosition(int index) {
    if (_users.isNotEmpty) {
      return _users[index];
    }
  }

  Future<void> filterUsers(String search) async {
    search = search.toLowerCase();
    var users = _allUsers.where((user) {
      var userString = "";
      if (user.name != null) userString += user.name.toLowerCase();
      if (user.email != null) userString += user.email.toLowerCase();
      if (user.phone != null) userString += user.phone.toLowerCase();
      return userString.contains(search);
    }).toList();
    setUsers(users);
  }

  int size() {
    return _users.length - 1;
  }

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get('http://192.168.0.196:7777/users');

      if (response.statusCode == 200) {
        var usersJson = jsonDecode(response.body) as List<dynamic>;
        List<User> users = usersJson.map((dynamic userJson) =>
            User.fromJson(userJson)).toList();

        users.sort((a, b) => a.name.compareTo(b.name));

        _allUsers = users;

        setUsers(users);
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    }
    catch (e) {
      throw Exception("Failed to fetch users ${e.toString()}");
    }
  }

  /// An unmodifiable view of the users
  UnmodifiableListView<User> get users => UnmodifiableListView(_users);
}