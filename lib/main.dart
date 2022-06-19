// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:fnf_guest_list/screens/audit-list.dart';
import 'package:fnf_guest_list/screens/guest-list.dart';
import 'package:battery/battery.dart';
import 'package:fnf_guest_list/blocs/guest.dart';
import 'package:fnf_guest_list/blocs/audit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fnf_guest_list/screens/ticket-list.dart';
import 'blocs/ticket-events.dart';
import 'blocs/ticket-list-bloc.dart';

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
  AuditRepository auditRepository;

  @override
  void initState() {
    this.guestRepository = GuestRepository();
    this.auditRepository = AuditRepository();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<GuestListBloc>(create: (context) {
            var guestBloc = GuestListBloc(this.guestRepository);
            // guestBloc.add(GetGuests());
            return guestBloc;
          }),
          BlocProvider<GuestDetailsBloc>(create: (context) {
            var guestBloc = GuestDetailsBloc(this.guestRepository);
            return guestBloc;
          }),
          BlocProvider<TicketListBloc>(create: (context) {
            var ticketBloc = TicketListBloc(this.guestRepository);
            ticketBloc.add(GetTickets());
            return ticketBloc;
          }),
          BlocProvider<AuditListBloc>(create: (context) {
            var auditBloc = AuditListBloc(this.auditRepository);
            auditBloc.add(GetAudits());
            return auditBloc;
          }),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            title: 'FnF Guest List',
            initialRoute: '/',
            routes: {
              '/': (context) => TicketList(),
              '/audit': (context) => AuditList()
            }));
  }
}
