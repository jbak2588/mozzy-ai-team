import 'dart:io';

import 'package:hni_auto_company_mvp/src/ai_orchestrator.dart';
import 'package:hni_auto_company_mvp/src/backend_service.dart';
import 'package:hni_auto_company_mvp/src/telegram_integration.dart';

Future<void> main(List<String> args) async {
  final port =
      int.tryParse(
        Platform.environment['HNI_BACKEND_PORT'] ??
            const String.fromEnvironment(
              'HNI_BACKEND_PORT',
              defaultValue: '8787',
            ),
      ) ??
      8787;
  final stageDelayMs =
      int.tryParse(
        Platform.environment['HNI_STAGE_DELAY_MS'] ??
            const String.fromEnvironment(
              'HNI_STAGE_DELAY_MS',
              defaultValue: '500',
            ),
      ) ??
      500;
  final filePath =
      Platform.environment['HNI_BACKEND_STATE_FILE'] ??
      const String.fromEnvironment(
        'HNI_BACKEND_STATE_FILE',
        defaultValue: '.hni_auto_company/backend_state.json',
      );
  final orchestratorBaseUrl =
      Platform.environment['HNI_AI_ORCHESTRATOR_BASE_URL'] ??
      const String.fromEnvironment(
        'HNI_AI_ORCHESTRATOR_BASE_URL',
        defaultValue: '',
      );

  final repository = FileBackendSnapshotRepository(File(filePath));
  final telegram = TelegramIntegration(
    config: TelegramIntegrationConfig.fromEnvironment(),
  );
  final authBootstrap = AuthBootstrapConfig.fromEnvironment();
  final orchestrator = orchestratorBaseUrl.trim().isEmpty
      ? null
      : AiOrchestratorClient(baseUrl: orchestratorBaseUrl.trim());
  final service = await AutoCompanyBackendService.load(
    repository,
    stageDelay: Duration(milliseconds: stageDelayMs),
    telegramIntegration: telegram.isConfigured ? telegram : null,
    orchestrator: orchestrator,
    authBootstrap: authBootstrap,
  );
  final server = await AutoCompanyBackendService.serve(
    service: service,
    port: port,
  );

  stdout.writeln(
    'HNI auto-company backend listening on http://${server.address.host}:${server.port}',
  );
  stdout.writeln('State file: ${File(filePath).absolute.path}');
  stdout.writeln(
    telegram.isConfigured
        ? telegram.config.pollingEnabled
              ? 'Telegram integration enabled in polling mode'
              : 'Telegram integration enabled at ${telegram.config.webhookPath}'
        : 'Telegram integration disabled (no HNI_TELEGRAM_BOT_TOKEN)',
  );
  stdout.writeln(
    orchestrator == null
        ? 'AI orchestrator disabled (no HNI_AI_ORCHESTRATOR_BASE_URL)'
        : 'AI orchestrator enabled at ${orchestrator.baseUrl}',
  );
  stdout.writeln(
    authBootstrap.enabled
        ? 'Auth bootstrap enabled for ${authBootstrap.role} at ${authBootstrap.email}'
        : 'Auth bootstrap disabled',
  );
  stdout.writeln('Auth provider mode: ${service.authProviderMode}');
}
