import 'dart:io';

import 'package:hni_auto_company_mvp/src/backend_service.dart';

Future<void> main(List<String> args) async {
  final port = int.tryParse(
        Platform.environment['HNI_BACKEND_PORT'] ??
            const String.fromEnvironment('HNI_BACKEND_PORT', defaultValue: '8787'),
      ) ??
      8787;
  final stageDelayMs = int.tryParse(
        Platform.environment['HNI_STAGE_DELAY_MS'] ??
            const String.fromEnvironment('HNI_STAGE_DELAY_MS', defaultValue: '500'),
      ) ??
      500;
  final filePath = Platform.environment['HNI_BACKEND_STATE_FILE'] ??
      const String.fromEnvironment(
        'HNI_BACKEND_STATE_FILE',
        defaultValue: '.hni_auto_company/backend_state.json',
      );

  final repository = FileBackendSnapshotRepository(File(filePath));
  final service = await AutoCompanyBackendService.load(
    repository,
    stageDelay: Duration(milliseconds: stageDelayMs),
  );
  final server = await AutoCompanyBackendService.serve(
    service: service,
    port: port,
  );

  stdout.writeln(
    'HNI auto-company backend listening on http://${server.address.host}:${server.port}',
  );
  stdout.writeln('State file: ${File(filePath).absolute.path}');
}
