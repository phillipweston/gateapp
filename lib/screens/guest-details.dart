// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/blocs/guest.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/record-contract.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fnf_guest_list/blocs/navigator.dart';

void _fetchGuest (BuildContext context, int userId) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  _bloc.add(GetGuest(userId));
}

void _validateGuestTickets (BuildContext context, int userId) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  _bloc.add(CheckGuestTicketsAssigned(userId));
}

Future<List<Guest>> _filterGuestsByName (BuildContext context, String search) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  return _bloc.guestRepository.filterGuestsByName(search);
}


class GuestDetails extends StatefulWidget {
  final Guest guest;

  GuestDetails({Key key,  @required this.guest }) : super(key: key);

  @override
  _GuestDetailsState createState() => _GuestDetailsState(guest);
}

class _GuestDetailsState extends State<GuestDetails> {
  GuestRepository guestRepository;
  final Guest guest;

  _GuestDetailsState(this.guest);

  @override
  void didChangeDependencies() {
    final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
    _bloc.add(GetGuest(guest.userId));
    super.didChangeDependencies();
  }

  @override
    Widget build(BuildContext context) {
        return BlocBuilder<GuestDetailsBloc, GuestState>(
          builder: (context, state) {
            var GUEST_NAME = guest.name != null ? guest.name : "";
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    child: Text(GUEST_NAME, style: Theme.of(context).textTheme.title)
                                  )
                                ),
                                SvgPicture.asset('assets/gearhead-heart.svg',
                                    color: Colors.white,
                                    height: 60,
                                    width: 60,
                                    semanticsLabel: 'A heart with gearheads')
                            ]
                          )
                        ]
                      ),
                      floating: true,
                      actions: [
                        IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () => _fetchGuest(context, guest.userId)
                        )
                      ],
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 20)),
                    BlocListener<GuestDetailsBloc, GuestState>(
                      listener: (context, state) {
                        print("state in guest-detail listener is $state");
                        if (state is GuestInitial) {
                          _fetchGuest(context, guest.userId);
                        }
                      },
                      child: SliverToBoxAdapter(child: SizedBox(height: 0))
                    ),
                    BlocBuilder<GuestDetailsBloc, GuestState>(

                      builder: (context, state) {
                        if (state is GuestLoaded) {
                          return buildGuestTickets(context, state.guest);
                        }
                        else if (state is GuestTicketsAssigned) {
                          return buildGuestTickets(context, state.guest);
                        }
                        else if (state is GuestsError) {
                          return buildError();
                        }
                        else {
                          return buildLoading();
                        }
                      },
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 2)),
                    BlocBuilder<GuestListBloc, GuestState>(
                      builder: (context, state) {
                        if (state is GuestTicketsAssigned) {
                          return buildTransferTicketsButton();
                        }
                        else {
                          return buildDisabledButton();
                        }
                      },
                    ),
                  ],
                )
            );
          });
  }
}


SliverToBoxAdapter buildDisabledButton () {
  return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 25, vertical: 10),
        child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: const EdgeInsets.symmetric(
                    horizontal: 100, vertical: 30),
                onPressed: null,
                textColor: Colors.white,
                child: Text('Confirm Ticket Assignments'),
                disabledColor: Colors.black12,
                disabledTextColor: Colors.white,
              )
            ]
        ),
      )
  );
}

SliverToBoxAdapter buildTransferTicketsButton () {
  return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 25, vertical: 10),
        child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                padding: const EdgeInsets.symmetric(
                    horizontal: 100, vertical: 30),
                onPressed: () => null,
                color: appTheme.primaryColor,
                textColor: Colors.white,
                child: Text('Confirm Ticket Assignments'),
              )
            ]
        ),
      )
  );
}

SliverToBoxAdapter buildInitial() {
  return SliverToBoxAdapter(
      child: Center(
        child: Text("buildInitial state"),
      ));
}

SliverToBoxAdapter buildLoading() {
  return SliverToBoxAdapter(
      child: Center(
        child: CircularProgressIndicator(),
      ));
}

SliverToBoxAdapter buildError() {
  return SliverToBoxAdapter(
      child: Center(
        child: Text("Error in Guest bloc"),
      ));
}

SliverFixedExtentList buildGuestTickets (BuildContext context, Guest guest) {
  return SliverFixedExtentList(
      itemExtent: 80.0,
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {

        if (index > guest.tickets.length - 1) return SizedBox(height: 0);
        return Container(
            alignment: Alignment.center,
            child: Column(
                children: <Widget>[
                  TicketListRow(guest.contract.records[index], index, guest),
                  Divider()
                ]));
      })
  );
}


class TicketListRow extends StatelessWidget {
  final Record record;
  final int index;
  final Guest owner;

  TicketListRow(this.record, this.index, this.owner, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textFieldController = new TextEditingController();

    if (index == 0) {
      if (record.name != null) textFieldController.text = record.name;
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
        case 4: case 5: case 6: case 7: case 8:case 9: case 10: case 11: case 12:
        ticketLabel = "${owner.firstName()}'s ${index}th Guest";
        break;
      }
    }

    return BlocBuilder<GuestDetailsBloc, GuestState>(
        builder: (context, state) {
          return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                      'assets/gearhead-pink.svg',
                                      height: 40,
                                      width: 40,
                                      semanticsLabel: 'An FnF Ticket'
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 5),
                                      child: Container(
                                          width: 300,
                                          height: 45,
                                          child: TypeAheadField(
                                            hideOnEmpty: true,
                                            textFieldConfiguration: TextFieldConfiguration<
                                                Guest>(
                                                autofocus: this.index == 1,
                                                controller: textFieldController,
                                                style: appTheme.textTheme
                                                    .display2,
                                                textCapitalization: TextCapitalization
                                                    .words,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: ticketLabel,
                                                )
                                            ),
                                            suggestionsCallback: (search) async {
                                              return _filterGuestsByName(context, search);
                                            },
                                            itemBuilder: (context,
                                                Guest guest) {
                                              return ListTile(
                                                  title: Text(guest.name,
                                                      style: appTheme.textTheme
                                                          .display2)
                                              );
                                            },
                                            onSuggestionSelected: (
                                                Guest guest) {
                                              textFieldController.text =
                                                  guest.name;
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
//              )
          );
        }

    );
  }
}

