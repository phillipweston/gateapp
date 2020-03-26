// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/blocs/guest.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fnf_guest_list/models/ticket.dart';
import '../models/record-contract.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void _fetchGuest (BuildContext context, int userId) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  _bloc.add(GetGuest(userId));
}

void _validateGuestTickets (BuildContext context, Guest owner) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  _bloc.add(CheckGuestTicketsAssigned(owner));
  // unfocus textbox to remove keyboard and show CONFIRM TICKETS button
  FocusScope.of(context).unfocus();
}

Future<List<Guest>> _filterGuestsByName (BuildContext context, String search) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  return _bloc.guestRepository.filterGuestsByName(search);
}

void _transferTickets (BuildContext context, Guest guest) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  _bloc.add(TransferTickets(guest));
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
    if (guest.contract.valid()) {
      _validateGuestTickets(context, guest);
    }
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
                    SliverToBoxAdapter(
                        child: Container(
                          height: 80,
                          width: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                      child: Text("Assign all tickets and the CONFIRM TICKETS button below will become active.", style: appTheme.textTheme.display1))
                                ]
                              )
                            ]
                          )
                        )
                    ),
                    BlocBuilder<GuestDetailsBloc, GuestState>(
                      builder: (context, state) {
                        if (state is GuestLoaded) {
                          return buildGuestTickets(context, state.guest);
                        }
                        else if (state is GuestTicketsAssigned) {
                          return buildGuestTickets(context, state.guest);
                        }
                        else if (state is TransferSuccessful) {
                          return buildTransferSuccess(context, state.tickets);
                        }
                        else if (state is GuestsError) {
                          return buildError();
                        }
                        else {
                          return buildLoading();
                        }
                      },
                    ),
                  ]
                ),
                bottomNavigationBar: BlocBuilder<GuestDetailsBloc, GuestState>(
                  builder: (context, state) {
                    if (state is GuestTicketsAssigned) {
                      return buildTransferTicketsButton(context, state.guest);
                    }
                    else if (state is TransferSuccessful) {
                      return buildCheckInButton();
                    }
                    else {
                      return buildDisabledButton();
                    }
                  }
                )
              );
          }
        );
  }
}


MaterialButton buildDisabledButton () {
  return MaterialButton(
          onPressed: null,
          height: 80,
          disabledColor: Colors.black12,
          textColor: Colors.white,
          child: Text('Confirm Tickets', style: appTheme.textTheme.button)
  );
}


MaterialButton buildTransferTicketsButton (BuildContext context, Guest guest) {
  return MaterialButton(
    onPressed: () => _transferTickets(context, guest),
    height: 80,
    color: superPink,
    disabledColor: Colors.black12,
    textColor: Colors.white,
    child: Text('Confirm Tickets', style: appTheme.textTheme.button)
  );
}

MaterialButton buildCheckInButton () {
  return MaterialButton(
      onPressed: () {},
      height: 80,
      color: superPink,
      disabledColor: Colors.black12,
      textColor: Colors.white,
      child: Text('Check in now!', style: appTheme.textTheme.button)
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
                  TicketListRow(guest, index),
                  Divider()
                ]));
      })
  );
}

SliverToBoxAdapter buildTransferSuccess (BuildContext context, List<Ticket> tickets) {
  return SliverToBoxAdapter(
    child: Container(
      height: 200,
      child: Text("Successfully transferred tickets!")
    )
  );
}


class TicketListRow extends StatelessWidget {
  final Guest owner;
  final int index;

  TicketListRow(this.owner, this.index, {Key key}) : super(key: key);

  var textFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
      Record record = owner.contract.records.elementAt(index);

      if (record.name != null) {
        textFieldController.text = record.name;
      }

      var ticketLabel = "";
      if (owner != null) {
        switch (index) {
          case 0:
            ticketLabel = "${owner.firstName()}'s ticket"; break;
          case 1:
            ticketLabel = "${owner.firstName()}'s 1st guest"; break;
          case 2:
            ticketLabel = "${owner.firstName()}'s 2nd guest"; break;
          case 3:
            ticketLabel = "${owner.firstName()}'s 3rd guest"; break;
          case 4: case 5: case 6: case 7: case 8:case 9: case 10: case 11: case 12:
          ticketLabel = "${owner.firstName()}'s ${index}th guest"; break;
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
                                  textFieldConfiguration: TextFieldConfiguration<Guest>(
//                                                autofocus: this.index == 1,
                                      controller: textFieldController,
                                      onChanged: (dynamic value) {
                                        record.setName(value.toString());
                                      },
                                      onSubmitted: (dynamic value) {
                                        _validateGuestTickets(context, owner);
                                      },
                                      onEditingComplete: () {
                                        _validateGuestTickets(context, owner);
                                      },
                                      style: appTheme.textTheme.display2,
                                      textCapitalization: TextCapitalization.words,
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
                                  onSuggestionSelected: (Guest guest) {
                                      record.setName(guest.name);
                                      textFieldController.text = guest.name;
                                      if (owner.contract.valid()) {
                                        _validateGuestTickets(context, owner);
                                      }
                                  },
                                )
                            )
                        ),
                      ]
                  )
                ]
            );
          }
      );
  }
}

