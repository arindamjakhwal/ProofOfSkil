import 'package:flutter_test/flutter_test.dart';
import 'package:proof_of_skill/main.dart';

void main() {
  testWidgets('ProofOfSkill app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const ProofOfSkillApp());
  });
}
