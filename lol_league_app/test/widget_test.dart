import 'package:flutter_test/flutter_test.dart';
import 'package:lol_league_app/app.dart';

void main() {
  testWidgets('APP launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const LolLeagueApp());
    await tester.pump();

    // Verify app launches
    expect(find.text('英雄联盟业余联赛平台'), findsWidgets);
  });
}
