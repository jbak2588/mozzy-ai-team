import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hni_auto_company_mvp/src/auth_session.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('auth session controller refreshes authenticated session', () async {
    final controller = AuthSessionController(
      baseUrl: 'http://127.0.0.1:8787',
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/session');
        return http.Response(
          jsonEncode({
            'session': {
              'authenticated': true,
              'principal': {
                'userId': 'usr-1',
                'email': 'operator@humantric.net',
                'name': 'HNI Operator',
                'role': 'Approver',
                'provider': 'bootstrap',
                'providerSubjectId': 'usr-1',
              },
              'capabilities': {
                'canAccessStrategy': true,
                'canApprove': true,
                'canManageTelegramOps': false,
                'canExportAudit': false,
              },
              'authTime': '2026-04-10T10:00:00Z',
              'issuedAt': '2026-04-10T10:00:00Z',
              'expiresAt': '2026-04-10T18:00:00Z',
              'recentAuthExpiresAt': '2026-04-10T10:15:00Z',
              'csrfToken': 'csrf-1',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await controller.refresh();

    expect(controller.isAuthenticated, isTrue);
    expect(controller.session.role, HniUserRole.approver);
    expect(controller.session.canApprove, isTrue);
    expect(controller.phase, AuthSessionPhase.ready);
  });

  test('auth session controller bootstrap login and logout roundtrip', () async {
    final requests = <String>[];
    final controller = AuthSessionController(
      baseUrl: 'http://127.0.0.1:8787',
      client: MockClient((request) async {
        requests.add(request.url.path);
        if (request.url.path == '/api/v1/session/bootstrap') {
          return http.Response(
            jsonEncode({
              'session': {
                'authenticated': true,
                'principal': {
                  'userId': 'usr-2',
                  'email': 'admin@humantric.net',
                  'name': 'HNI Admin',
                  'role': 'Admin',
                  'provider': 'bootstrap',
                  'providerSubjectId': 'usr-2',
                },
                'capabilities': {
                  'canAccessStrategy': true,
                  'canApprove': true,
                  'canManageTelegramOps': true,
                  'canExportAudit': true,
                },
                'authTime': '2026-04-10T10:00:00Z',
                'issuedAt': '2026-04-10T10:00:00Z',
                'expiresAt': '2026-04-10T18:00:00Z',
                'recentAuthExpiresAt': '2026-04-10T10:15:00Z',
                'csrfToken': 'csrf-2',
              },
              'redirectTo': '/dashboard/home',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        expect(request.headers['x-hni-csrf-token'], 'csrf-2');
        return http.Response(
          jsonEncode({
            'session': {
              'authenticated': false,
              'principal': null,
              'capabilities': {},
              'authTime': null,
              'issuedAt': null,
              'expiresAt': null,
              'recentAuthExpiresAt': null,
              'csrfToken': null,
            },
            'redirectTo': '/auth/login',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final loginRedirect = await controller.bootstrapLogin();
    final logoutRedirect = await controller.logout();

    expect(loginRedirect, '/dashboard/home');
    expect(logoutRedirect, '/auth/login');
    expect(requests, ['/api/v1/session/bootstrap', '/api/v1/session/logout']);
    expect(controller.isAuthenticated, isFalse);
  });
}
