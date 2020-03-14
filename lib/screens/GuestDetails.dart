// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnf_guest_list/models/Guest.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GuestDetails extends StatelessWidget {
  final Guest guest;

  // In the constructor, require a Guest.
  GuestDetails({Key key, @required this.guest}) : super(key: key);

  @override
    Widget build(BuildContext context) {
    return ChangeNotifierProvider<GuestModel>(
      create: (context) => GuestModel(),
      child: Consumer<GuestModel>(
        builder: (context, guests, child) {
          var name = guest.name != null ? guest.name : "";
          var email = guest.email != null ? guest.email : "";
          var phone = guest.phone != null ? guest.phone : "";
          return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Center(
                      child: RefreshIndicator(
                        onRefresh: () => guests.refreshAll(),
                        child: Row(
                          children: <Widget>[
//                            SvgPicture.asset(
//                                'assets/gearhead-heart.svg',
//                                color: Colors.white,
//                                height: 60,
//                                width: 60,
//                                semanticsLabel: 'A heart with gearheads'
//                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              child: Text(name, style: Theme.of(context).textTheme.title)
                            )
                          ]
                        )
                      )
                    ),
                    floating: true,
                    actions: [
                      IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => guests.refreshAll()
                      )
                    ],
                  ),
                  SliverAppBar(
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                    elevation: 0.0,
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: false,
                    title: Text(name),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index > guest.numTickets()) return null;
                          return TicketListRow(guest.getTicketByPosition(index));
                        }
                    )
                  )
                    ])
                    );
              }));
//          ),
//        )
//    );
  }
}



class TicketListRow extends StatelessWidget {
  final Ticket ticket;

  TicketListRow(this.ticket, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme.title;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
//            onTap: () => Navigator.push(
//              context,
//              MaterialPageRoute<void>(
//                builder: (context) => GuestDetails(guest: guest),
//              ),
//            ),
            child: LimitedBox(
                maxHeight: 48,
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        //                color: guest.color,
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Text(ticket.ticketId.toString(), style: Theme.of(context).textTheme.display2),
                    ),
                    SizedBox(width: 24),
                  ],
                )
            )
        )
    );
  }
}
