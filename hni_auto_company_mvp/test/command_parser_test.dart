import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/command_parser.dart';

void main() {
  const parser = CommandParser();

  test('new order command parses title and objective', () {
    final command = parser.parse(
      '/new_order Neighborhood run | approval 후 자동 실행 | Mozzy | main',
    );

    expect(command.isValid, isTrue);
    expect(command.title, 'Neighborhood run');
    expect(command.objective, 'approval 후 자동 실행');
    expect(command.targetProduct, 'Mozzy');
    expect(command.targetBranch, 'main');
  });

  test('approve command requires id', () {
    final command = parser.parse('/approve WO-101');

    expect(command.isValid, isTrue);
    expect(command.orderId, 'WO-101');
  });

  test('unknown command is invalid', () {
    final command = parser.parse('/noop');

    expect(command.isValid, isFalse);
    expect(command.error, contains('Unknown command'));
  });
}
