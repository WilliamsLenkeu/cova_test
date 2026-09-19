import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('affiche la connexion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TaskApp());
    await tester.pumpAndSettle();
    expect(find.text('Tâches'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });
}
