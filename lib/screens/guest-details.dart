// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/record-contract.dart';

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

          var GUEST_NAME = guest.name != null ? guest.name : "";



          var isConfirmed = false;

          return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Center(
                              child: Text(GUEST_NAME, style: Theme.of(context).textTheme.title)
                            )
                        ]
                      )
                    ]),
                    floating: true,
                    actions: [
                      IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => guests.refreshAll()
                      )
                    ],
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverAnimatedList(
                      itemBuilder: (context, index, animation) {
                        if (index > guest.numTickets()) return null;
                        return Container(
                          child: Column(
                            children: <Widget>[
                              TicketListRow(guest.getTicketRecordByPosition(index), index),
                              Divider()
                            ]
                          )
                        );
                      },
                      initialItemCount: guest.numTickets()
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 2)),
                  SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        child: ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: <Widget>[
//                              RaisedButton(
//                                  padding: const EdgeInsets.symmetric(
//                                      horizontal: 20, vertical: 10),
//                                  onPressed: () {},
//                                  color: appTheme.primaryColor,
//                                  textColor: Colors.white,
//                                  child: Text('Confirm Ticket Assignments')
//                              ),
                              RaisedButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 30),
                                onPressed: isConfirmed ? () {} : null,
                                color: appTheme.primaryColor,
                                textColor: Colors.white,
                                child: Text('Confirm Ticket Assignments'),
                                disabledColor: Colors.black12,
                                disabledTextColor: Colors.white,
                              )
                            ]
                        ),
                      )
                  )
                ],
              )
          );
        })
      );
  }
}



class TicketListRow extends StatelessWidget {
  final Record record;
  final int index;

  TicketListRow(this.record, this.index, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var nameFieldController = new TextEditingController();


    if (index == 0) {
      if (record.name != null) nameFieldController.text = record.name;
    }

    return ChangeNotifierProvider<GuestModel>(
      create: (context) => GuestModel(),
      child: Consumer<GuestModel>(
        builder: (context, guests, child) {
          var owner = guests.getById(record.ticket.userId);

          _setGuestName() {
            record.setName(nameFieldController.text);
            guests.triggerNotifiers();
            print("valid: ${owner.contract.valid()}");
          }

          if (owner != null) {
            nameFieldController.addListener(_setGuestName);
          }

          var ticketLabel = "";
          if (owner != null) {
            switch (index) {
              case 0:
                ticketLabel = "${owner.firstName()}'s ticket";
                break;
              case 1:
                ticketLabel = "${owner.firstName()}'s 1st Guest";
                break;
              case 2:
                ticketLabel = "${owner.firstName()}'s 2nd Guest";
                break;
              case 3:
                ticketLabel = "${owner.firstName()}'s 3rd Guest";
                break;
              case 4:
              case 5:
              case 6:
              case 7:
              case 8:
              case 9:
              case 10:
              case 11:
              case 12:
                ticketLabel = "${owner.firstName()}'s ${index}th Guest";
                break;
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
                child: LimitedBox(
                    maxHeight: 60,
                    maxWidth: 1000,
                    child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
//                                ListTile(

//                                    leading:
                                    SvgPicture.asset(
                                        'assets/gearhead-pink.svg',
                                        height: 40,
                                        width: 40,
                                        semanticsLabel: 'An FnF Ticket'
                                    ),
//                                    title:
                                    Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                        child: Container(
                                            width: 300,
                                            height: 45,
                                            child: TypeAheadField(
                                              hideOnEmpty: true,
                                              textFieldConfiguration: TextFieldConfiguration<Guest>(
                                                  autofocus: this.index == 1,
                                                  controller: nameFieldController,
                                                  style: appTheme.textTheme.display2,
                                                  textCapitalization: TextCapitalization.words,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    labelText: ticketLabel,
                                                  )
                                              ),
                                              suggestionsCallback: (pattern) async {
                                                return guests.searchGuests(pattern);
                                              },
                                              itemBuilder: (context, Guest guest) {
                                                return ListTile(
                                                    title: Text(guest.name, style: appTheme.textTheme.display2)
                                                );
                                              },
                                              onSuggestionSelected: (Guest guest) {
                                                nameFieldController.text = guest.name;
                                              },
                                            )
                                        )
                                    ),
//                                )


//                                Padding(
//                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
//                                  child: Switch(
//                                    value: isSwitched,
//                                    onChanged: (value) {
//                                      isSwitched = value;
//                                    },
//                                    activeTrackColor: Colors.black12,
//                                    activeColor: appTheme.primaryColor,
//
//                                    )
//                                  )
                            ]
                          )
                        ]
                    )
                  )
                )
            );

        }
      )
    );
    }
}

