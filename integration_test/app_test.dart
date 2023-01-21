import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnf_guest_list/screens/ticket-list.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fnf_guest_list/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
        await tester.enterText(searchBox, 'Phillipzzzzzz');
        await tester.pumpAndSettle();
        expect(find.byType(TicketListRow), findsNWidgets(0));
      });

      testWidgets('test redeem', (tester) async {
        app.main();
        await tester.pumpAndSettle();
        final Finder searchBox = find.byType(SearchInputField);
        await tester.tap(searchBox);
        await tester.enterText(searchBox, 'Radiant');
        await tester.pumpAndSettle();
        final Finder redeemButton = find.byType(MaterialButton).at(2);
        await tester.tap(redeemButton);
        await tester.pumpAndSettle();
        expect(find.text('Agree and Redeem Ticket'), findsOneWidget);
        final licensePlateInput = find.byType(TextField).last;
        await tester.enterText(licensePlateInput, "1234567");
        await tester.pumpAndSettle();
        final agreeAndRedeemButton = find.byType(MaterialButton).last;
        await tester.tap(agreeAndRedeemButton);
        await tester.pumpAndSettle();
        await tester.pump(new Duration(milliseconds: 50));
        expect(tester.widget<MaterialButton>(redeemButton).enabled, isFalse);
        // expect(find.text("You're now checked in!"), findsOneWidget);
        // await tester.pump(new Duration(milliseconds: 5000));
      });
  });
}
