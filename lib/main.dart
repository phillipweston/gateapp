// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:fnf_guest_list/screens/guest-list.dart';
import 'package:battery/battery.dart';
import 'package:fnf_guest_list/blocs/guest.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GuestRepository guestRepository;

  @override
  void initState() {
    this.guestRepository = GuestRepository();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GuestListBloc>(
          create: (BuildContext context) {
            var guestBloc = GuestListBloc(this.guestRepository);
            guestBloc.add(GetGuests());
            return guestBloc;
          }
        ),
        BlocProvider<GuestDetailsBloc>(
          create: (BuildContext context) {
            var guestBloc = GuestDetailsBloc(this.guestRepository);
            return guestBloc;
          }
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        title: 'FnF Guest List',
        initialRoute: '/',
        routes: {
          '/': (context) => GuestList(),
        }
      )
    );
  }
}
