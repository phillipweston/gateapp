import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnf_guest_list/screens/ticket-list.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fnf_guest_list/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String licensePlate = '1234567';

  group('end-to-end integration tests', () {
    testWidgets('test search happy path', (tester) async {
        app.main();
        await tester.pumpAndSettle();
        expect(find.text('Search by guest name or license plate.'), findsOneWidget);
        final Finder searchBox = find.byType(SearchInputField);
        await tester.tap(searchBox);
        await tester.enterText(searchBox, 'Phillip');
        await tester.pumpAndSettle();
        expect(find.byType(TicketListRow), findsNWidgets(7));
      });

      testWidgets('test search no results', (tester) async {
        app.main();
        await tester.pumpAndSettle();
        expect(find.text('Search by guest name or license plate.'), findsOneWidget);
        final Finder searchBox = find.byType(SearchInputField);
        await tester.tap(searchBox);
        await tester.enterText(searchBox, 'Testzzzzzz');
        await tester.pumpAndSettle();
        expect(find.byType(TicketListRow), findsNWidgets(0));
      });

      testWidgets('test redeem', (tester) async {
        app.main();
        await tester.pumpAndSettle();
        final Finder searchBox = find.byType(SearchInputField);
        await tester.tap(searchBox);
        await tester.enterText(searchBox, 'radiant');
        await tester.pumpAndSettle();
        final Finder redeemButton = find.byType(MaterialButton).at(1);
        await tester.tap(redeemButton);
        await tester.pumpAndSettle();
        expect(find.text('Agree and Redeem Ticket'), findsOneWidget);
        final licensePlateInput = find.byType(TextField).last;
        await tester.enterText(licensePlateInput, licensePlate);
        await tester.pumpAndSettle();
        final agreeAndRedeemButton = find.byType(MaterialButton).last;
        await tester.tap(agreeAndRedeemButton);
        await tester.pumpAndSettle();
        await tester.pump(new Duration(milliseconds: 500));
        expect(tester.widget<MaterialButton>(redeemButton).enabled, isFalse);
        // expect(find.text("You're now checked in!"), findsOneWidget);
      });

      testWidgets('search by license plate', (tester) async {
        app.main();
        await tester.pumpAndSettle();
        expect(find.text('Search by guest name or license plate.'), findsOneWidget);
        final Finder searchBox = find.byType(SearchInputField);
        await tester.tap(searchBox);
        await tester.enterText(searchBox, licensePlate);
        await tester.pumpAndSettle();
        expect(find.byType(TicketListRow), findsNWidgets(1));
      });
  });
}
