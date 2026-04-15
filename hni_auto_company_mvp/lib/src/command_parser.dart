import 'models.dart';

enum ParsedCommandType {
  newOrder,
  approve,
  hold,
  resume,
  status,
  help,
  invalid,
}

class ParsedCommand {
  ParsedCommand({
    required this.type,
    this.orderId,
    this.title,
    this.objective,
    this.targetProduct,
    this.targetBranch,
    this.note,
    this.error,
  });

  final ParsedCommandType type;
  final String? orderId;
  final String? title;
  final String? objective;
  final String? targetProduct;
  final String? targetBranch;
  final String? note;
  final String? error;

  bool get isValid => error == null;
}

class CommandParser {
  const CommandParser();

  ParsedCommand parse(String input) {
    final value = input.trim();
    if (value.isEmpty || value == '/help') {
      return ParsedCommand(type: ParsedCommandType.help);
    }

    if (value.startsWith('/new_order')) {
      final payload = value.replaceFirst('/new_order', '').trim();
      if (payload.isEmpty) {
        return ParsedCommand(
          type: ParsedCommandType.invalid,
          error: 'Usage: /new_order title | objective | product | branch',
        );
      }
      final segments = payload.split('|').map((item) => item.trim()).toList();
      if (segments.length < 2) {
        return ParsedCommand(
          type: ParsedCommandType.invalid,
          error: 'Usage: /new_order title | objective | product | branch',
        );
      }
      return ParsedCommand(
        type: ParsedCommandType.newOrder,
        title: segments[0],
        objective: segments[1],
        targetProduct: segments.length > 2 && segments[2].isNotEmpty
            ? segments[2]
            : 'Mozzy',
        targetBranch: segments.length > 3 && segments[3].isNotEmpty
            ? segments[3]
            : 'main',
      );
    }

    if (value.startsWith('/approve')) {
      final orderId = value.replaceFirst('/approve', '').trim();
      if (orderId.isEmpty) {
        return ParsedCommand(
          type: ParsedCommandType.invalid,
          error: 'Usage: /approve WO-001',
        );
      }
      return ParsedCommand(type: ParsedCommandType.approve, orderId: orderId);
    }

    if (value.startsWith('/hold')) {
      final payload = value.replaceFirst('/hold', '').trim();
      if (payload.isEmpty) {
        return ParsedCommand(
          type: ParsedCommandType.invalid,
          error: 'Usage: /hold WO-001 | note',
        );
      }
      final segments = payload.split('|').map((item) => item.trim()).toList();
      return ParsedCommand(
        type: ParsedCommandType.hold,
        orderId: segments.first,
        note: segments.length > 1 ? segments[1] : 'Manual hold',
      );
    }

    if (value.startsWith('/resume')) {
      final orderId = value.replaceFirst('/resume', '').trim();
      if (orderId.isEmpty) {
        return ParsedCommand(
          type: ParsedCommandType.invalid,
          error: 'Usage: /resume WO-001',
        );
      }
      return ParsedCommand(type: ParsedCommandType.resume, orderId: orderId);
    }

    if (value.startsWith('/status')) {
      final orderId = value.replaceFirst('/status', '').trim();
      if (orderId.isEmpty) {
        return ParsedCommand(
          type: ParsedCommandType.invalid,
          error: 'Usage: /status WO-001',
        );
      }
      return ParsedCommand(type: ParsedCommandType.status, orderId: orderId);
    }

    return ParsedCommand(
      type: ParsedCommandType.invalid,
      error: 'Unknown command. Try /help',
    );
  }

  static String helpText(CommandChannel channel) {
    return '${channel.label} commands: '
        '/new_order title | objective | product | branch, '
        '/approve WO-001, /hold WO-001 | note, /resume WO-001, /status WO-001';
  }
}
