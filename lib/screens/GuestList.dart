// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnf_guest_list/models/Guest.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fnf_guest_list/screens/GuestDetails.dart';

var searchController = new TextEditingController();

class GuestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GuestModel>(
      create: (context) => GuestModel(),
      child: Consumer<GuestModel>(
        builder: (context, guests, child) {
          return Scaffold(
              body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                        title: Center(
                            child: RefreshIndicator(
                                onRefresh: () => guests.refreshAll(),
                                child: GestureDetector(
                                    onTap: () {
                                      searchController.value =
                                          TextEditingValue(text: "");
                                      guests.refreshAll();
                                    },
                                    child: Row(
                                        children: <Widget>[
                                          SvgPicture.asset(
                                              'assets/gearhead-heart.svg',
                                              color: Colors.white,
                                              height: 60,
                                              width: 60,
                                              semanticsLabel: 'A heart with gearheads'
                                          ),
                                          Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 12, vertical: 0),
                                              child: Text(
                                                  'FnF Guest List', style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .title)
                                          )
                                        ]
                                    )
                                )
                            )
                        ),
                        floating: true,
                        actions: [
                          IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () => guests.refreshAll()
                          )
                        ]
                    ),
          

                    SliverAppBar(
                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                      elevation: 0.0,
                      automaticallyImplyLeading: false,
                      pinned: true,
                      floating: false,
                      title: TextField(
                        onChanged: (value) => guests.filterGuests(value),
                        controller: searchController,
                        style: Theme.of(context).textTheme.caption,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          suffixIcon: Icon(Icons.search),
                          hintText: 'Search by name, email, or phone (possibly)',
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (guests.size() == -1 && index == 0) return Center(child: CircularProgressIndicator());
                        if (index > guests.size()) return null;
                        return Container(
                            child: Column(
                                children: <Widget>[
                                  GuestListRow(guests.getByPosition(index)),
                                  Divider()
                                ]
                            )
                        );
                      }
                    )
                  ),
                ],
              ),
            );
          }
      )
    );
  }
}

class GuestListRow extends StatelessWidget {
  final Guest guest;

  GuestListRow(this.guest, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme.title;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => GuestDetails(guest: guest),
            ),
          ),
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
                      child: Text(guest.name, style: Theme.of(context).textTheme.display2),
                    ),
                    SizedBox(width: 24),
                    Row(children: guest.tickets.map((ticket) =>
                        new Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: SvgPicture.asset(
                            'assets/gearhead-pink.svg',
                            height: 40,
                            width: 40,
                            semanticsLabel: 'An FnF Ticket'
                        ))).toList()
                        )
                      ],
                )
          )
        )
    );
  }
}
