// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

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
    else {
      return null;
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get('http://192.168.0.196:7777/users');

      if (response.statusCode == 200) {
        var usersJson = jsonDecode(response.body) as List<dynamic>;
        List<User> users = usersJson.map((dynamic userJson) =>
            User.fromJson(userJson)).toList();

        users.sort((a, b) => a.name.compareTo(b.name));

        this.setUsers(users);
        return users;
      } else {
        throw Exception('Failed to load users');
      }
    }
    catch (e) {
      throw Exception("Failed to fetch users ${e.toString()}");
    }
  }
  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<User> get users => UnmodifiableListView(_users);

//  /// Adds [item] to cart. This is the only way to modify the cart from outside.
//  void select(User user) {
//    selectedUser.add(item);
//    // This call tells the widgets that are listening to this model to rebuild.
//    notifyListeners();
//  }
}