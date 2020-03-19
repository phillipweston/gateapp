// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:fnf_guest_list/models/Guest.dart';
import 'package:fnf_guest_list/screens/GuestList.dart';
import 'package:battery/battery.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => GuestModel()),
      ],
      child: MaterialApp(
        title: 'FNF GATE',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => GuestList(),
        }
      ),
    );
  }
}
