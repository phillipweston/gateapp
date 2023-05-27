import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigatorBloc extends Bloc<NagivatorAction, dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;
  NavigatorBloc({required this.navigatorKey}) : super(null);

  @override
  dynamic get initialState => 0;

  @override
  Stream<dynamic> mapEventToState(NagivatorAction event) async* {
    if (event is NavigateToGuestDetails) {
      await navigatorKey.currentState?.pushNamed('/');
    }
  }
}

class Navigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  @override
  Widget build(BuildContext context) {
    return Row();
  }
}

abstract class NagivatorAction extends Equatable {
  const NagivatorAction();
}

class NavigateToGuestList extends NagivatorAction {
  const NavigateToGuestList();

  @override
  List<Object> get props => [];
}

class NavigateToGuestDetails extends NagivatorAction {
  const NavigateToGuestDetails();

  @override
  List<Object> get props => [];
}
