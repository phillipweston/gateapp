// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:fnf_guest_list/blocs/navigator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/models/record.dart';
import 'package:fnf_guest_list/screens/guest-details.dart';
import 'package:fnf_guest_list/blocs/guest.dart' as guest;
import 'package:fnf_guest_list/blocs/ticket.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../common/theme.dart';
import '../models/ticket.dart';

var searchController = new TextEditingController();

void _fetchTickets(BuildContext context) async {
  final ticketBloc = BlocProvider.of<TicketListBloc>(context);
  ticketBloc.add(GetTickets());
}

void _filterTickets(BuildContext context, String search) {
  final ticketBloc = BlocProvider.of<TicketListBloc>(context);
  ticketBloc.add(FilterTickets(search));
}

var guestRepository = guest.GuestRepository();

class TicketList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<guest.GuestDetailsBloc, guest.GuestState>(
    builder: (context, state) {
      if(state is guest.TicketRedeemed || state is guest.TransferSuccessful || state is TicketRedeemed || state is TransferSuccessful) {
        final _ticketBloc = BlocProvider.of<TicketListBloc>(context);
        _ticketBloc.add(GetTickets());
        // searchController.value =
        //     TextEditingValue(text: "");
        _filterTickets(context, searchController.text);
        FocusManager.instance.primaryFocus?.unfocus();
      }
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
                              child: GestureDetector(
                                  onTap: () {
                                    searchController.value =
                                        TextEditingValue(text: "");
                                    _fetchTickets(context);
                                  },
                                  child: Row(children: <Widget>[
                                    SvgPicture.asset(
                                        'assets/gearhead-heart.svg',
                                        color: Colors.white,
                                        height: 60,
                                        width: 60,
                                        semanticsLabel:
                                            'A heart with gearheads'),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 0),
                                        child: Text('FnF Guest List',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6))
                                  ]))),
                          IconButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            onPressed: () {
                              // Navigate to the second screen using a named route.
                              Navigator.pushNamed(context, '/audit');
                            },
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 30.0,
                              semanticLabel: 'Look at the audit list',
                            ),
                          ),
                        ],
                      )
                    ]),
                floating: true,
                actions: [
                  IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        searchController.value = TextEditingValue(text: "");
                        _fetchTickets(context);
                      },
                      color: Colors.white)
                ]),
            SliverAppBar(
                backgroundColor: Theme.of(context).dialogBackgroundColor,
                elevation: 0.0,
                automaticallyImplyLeading: false,
                pinned: true,
                floating: false,
                title: SizedBox(height: 80, child: SearchInputField()),
                actions: [Text("hi")]),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            BlocBuilder<TicketListBloc, TicketState>(
              builder: (context, state) {
                if (state is TicketsInitial) {
                  return buildLoading();
                } else if (state is TicketsLoading) {
                  return buildLoading();
                } else if (state is TicketsLoaded) {
                  return buildTicketList(context, state.tickets);
                } else if (state is guest.NoGuestsMatchSearch) {
                  return buildNoTickets();
                } else if (state is TicketsError) {
                  return buildError();
                }
                return Container();
              },
            ),
          ],
        ),
      );
    });
  }
}

class SearchInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        textAlign: TextAlign.left,
        onChanged: (value) => _filterTickets(context, value),
        controller: searchController,
        style: Theme.of(context).textTheme.caption,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          suffixIcon: Icon(Icons.search),
          hintStyle: TextStyle(),
          labelText: 'Search by guest name',
//          hintText: 'Search by name, email, or phone (possibly)',
        ),
      ),
    );
  }
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

SliverToBoxAdapter buildNoTickets() {
  return SliverToBoxAdapter(
      child: Center(
    child: Text("No guests match this search."),
  ));
}

AnimationLimiter buildTicketList(BuildContext context, List<Ticket> tickets) {
  return AnimationLimiter(
      child: SliverFixedExtentList(
          itemExtent: 101.0,
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            if (index > tickets.length - 1) return null;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 175),
              child: SlideAnimation(
//            verticalOffset: -50.0,
                horizontalOffset: -30.0,

                child: FadeInAnimation(
                    child: Container(
                        alignment: Alignment.center,
                        child: Column(children: <Widget>[
                          TicketListRow(tickets[index]),
                          Divider()
                        ]))),
              ),
            );
          })));
}

class TicketListRow extends StatelessWidget {
  final Ticket ticket;

  TicketListRow(this.ticket, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String ticketName = ticket.owner.name;
    final String ticketLabel = "Purchased by ${ticket.originalOwner.firstName()}";
    Record record = Record(ticket);
    final bool canReassign = !ticket.redeemed;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          LimitedBox(
              maxHeight: 48,
              child: Row(
                children: [
                  SizedBox(width: 24),
                  Expanded(
                    child:  
                    TextButton(
                      child: Text( 
                        ticketName,
                        textAlign: TextAlign.end ),
                      style: TextButton.styleFrom(
                        textStyle: appTheme.textTheme.headline2,
                        alignment: Alignment.centerLeft
                      ),
                      onPressed: () async {
                        if(!ticket.redeemed) {
                          await showDialog<ReassignTicketModal>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return ReassignTicketModal(
                                owner: ticket.owner,
                                record: record,
                                inputDecoration: ticketLabel
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 24),
                  Row(children: [
                    ticket.redeemed ? buildDisabledButton() : buildCheckInButton(context, ticket, ticket.owner),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: SvgPicture.asset('assets/gearhead-pink.svg',
                            height: 40,
                            width: 40,
                            semanticsLabel: 'An FnF Ticket'))
                  ])
                ],
              )
          ),
          LimitedBox(
              maxHeight: 48,
              child: Row(
                children: [
                  SizedBox(width: 24),
                  Expanded(
                    child: Text("Purchaser: ${ticket.originalOwner.name}",
                        style: Theme.of(context).textTheme.caption),
                  ),
                ],
              )
          )
        ]
        )
    );
  }
}

class ReassignTicketModal extends StatefulWidget {
  const ReassignTicketModal({Key key, this.owner, this.record, this.inputDecoration
});
  final Guest owner;
  final Record record;
  final String inputDecoration;

  @override
  _ReassignTicketModalState createState() => _ReassignTicketModalState();
}

class _ReassignTicketModalState extends State<ReassignTicketModal> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Color(0XFF232426),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: 300,
        height: 250,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child:TextField(
                controller: firstNameController,
                style: appTheme.textTheme.headline1,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "First Name",
                )
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child:TextField(
                controller: lastNameController,
                style: appTheme.textTheme.headline1,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Last Name",
                )
              ),
            ),
            Container(
              width: 150,
              child: 
              TextButton(
                child: Text("Transfer", style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  widget.record.setName(firstNameController.text + " " + lastNameController.text);
                  if(widget.record.valid) {
                    final _bloc = BlocProvider.of<guest.GuestDetailsBloc>(context);
                    final List<Record> records = <Record>[widget.record];
                    _bloc.add(guest.TransferTicket(widget.owner, widget.record));
                    Navigator.pop(context);
                  } 
                },
              )
            ),
      
          ],
        ) 
        
      )
    );
  }
}

