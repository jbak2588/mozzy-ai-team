enum AuthProviderMode { bootstrap, mockOidc }

extension AuthProviderModeView on AuthProviderMode {
  static AuthProviderMode fromName(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'mock_oidc':
      case 'mock-oidc':
      case 'mockoidc':
        return AuthProviderMode.mockOidc;
      default:
        return AuthProviderMode.bootstrap;
    }
  }

  String get wireName => switch (this) {
    AuthProviderMode.bootstrap => 'bootstrap',
    AuthProviderMode.mockOidc => 'mock_oidc',
  };
}

class AuthProviderIdentity {
  const AuthProviderIdentity({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.provider,
    required this.providerSubjectId,
    this.pictureUrl,
  });

  final String userId;
  final String email;
  final String name;
  final String role;
  final String provider;
  final String providerSubjectId;
  final String? pictureUrl;
}

class PendingAuthFlow {
  const PendingAuthFlow({
    required this.state,
    required this.returnTo,
    required this.providerMode,
  });

  final String state;
  final String returnTo;
  final AuthProviderMode providerMode;

  String encode() {
    return '${providerMode.wireName}|$state|$returnTo';
  }

  static PendingAuthFlow? decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final parts = raw.split('|');
    if (parts.length != 3) {
      return null;
    }
    return PendingAuthFlow(
      providerMode: AuthProviderModeView.fromName(parts[0]),
      state: parts[1],
      returnTo: parts[2],
    );
  }
}

class AuthLoginChallenge {
  const AuthLoginChallenge({
    required this.pending,
    required this.redirectLocation,
  });

  final PendingAuthFlow pending;
  final String redirectLocation;
}

class AuthProviderConfig {
  const AuthProviderConfig({
    required this.mode,
    required this.defaultReturnTo,
    required this.mockIdentity,
  });

  final AuthProviderMode mode;
  final String defaultReturnTo;
  final AuthProviderIdentity mockIdentity;

  factory AuthProviderConfig.fromEnvironment() {
    const mockPictureUrl = String.fromEnvironment(
      'HNI_AUTH_MOCK_PICTURE_URL',
      defaultValue: '',
    );
    return AuthProviderConfig(
      mode: AuthProviderModeView.fromName(
        const String.fromEnvironment('HNI_AUTH_PROVIDER_MODE'),
      ),
      defaultReturnTo: const String.fromEnvironment(
        'HNI_AUTH_PROVIDER_DEFAULT_RETURN_TO',
        defaultValue: '/dashboard/home',
      ),
      mockIdentity: AuthProviderIdentity(
        userId: const String.fromEnvironment(
          'HNI_AUTH_MOCK_USER_ID',
          defaultValue: 'mock-approver',
        ),
        email: const String.fromEnvironment(
          'HNI_AUTH_MOCK_EMAIL',
          defaultValue: 'mock-approver@humantric.net',
        ),
        name: const String.fromEnvironment(
          'HNI_AUTH_MOCK_NAME',
          defaultValue: 'HNI Mock Approver',
        ),
        role: const String.fromEnvironment(
          'HNI_AUTH_MOCK_ROLE',
          defaultValue: 'Approver',
        ),
        provider: 'mock-oidc',
        providerSubjectId: const String.fromEnvironment(
          'HNI_AUTH_MOCK_SUBJECT',
          defaultValue: 'mock-approver',
        ),
        pictureUrl: mockPictureUrl.isEmpty ? null : mockPictureUrl,
      ),
    );
  }
}

abstract class AuthProviderAdapter {
  const AuthProviderAdapter();

  AuthProviderMode get mode;

  String get defaultReturnTo;

  String get label;

  AuthLoginChallenge beginLogin({required String returnTo});

  AuthProviderIdentity completeCallback({
    required Uri requestedUri,
    required PendingAuthFlow pending,
    required AuthProviderIdentity bootstrapIdentity,
  });

  factory AuthProviderAdapter.fromConfig(AuthProviderConfig config) {
    return switch (config.mode) {
      AuthProviderMode.bootstrap => BootstrapAuthProviderAdapter(
        defaultReturnTo: config.defaultReturnTo,
      ),
      AuthProviderMode.mockOidc => MockOidcAuthProviderAdapter(
        defaultReturnTo: config.defaultReturnTo,
        identity: config.mockIdentity,
      ),
    };
  }
}

class BootstrapAuthProviderAdapter extends AuthProviderAdapter {
  const BootstrapAuthProviderAdapter({required this.defaultReturnTo});

  @override
  final String defaultReturnTo;

  @override
  AuthProviderMode get mode => AuthProviderMode.bootstrap;

  @override
  String get label => 'bootstrap';

  @override
  AuthLoginChallenge beginLogin({required String returnTo}) {
    final pending = PendingAuthFlow(
      state: _stateToken(),
      returnTo: returnTo,
      providerMode: mode,
    );
    return AuthLoginChallenge(
      pending: pending,
      redirectLocation:
          '/auth/callback?provider=${mode.wireName}&state=${pending.state}',
    );
  }

  @override
  AuthProviderIdentity completeCallback({
    required Uri requestedUri,
    required PendingAuthFlow pending,
    required AuthProviderIdentity bootstrapIdentity,
  }) {
    final query = requestedUri.queryParameters;
    final state = query['state'];
    if (state == null || state != pending.state) {
      throw const FormatException('OIDC state validation failed.');
    }
    return bootstrapIdentity;
  }
}

class MockOidcAuthProviderAdapter extends AuthProviderAdapter {
  const MockOidcAuthProviderAdapter({
    required this.defaultReturnTo,
    required this.identity,
  });

  @override
  final String defaultReturnTo;

  final AuthProviderIdentity identity;

  @override
  AuthProviderMode get mode => AuthProviderMode.mockOidc;

  @override
  String get label => 'mock-oidc';

  @override
  AuthLoginChallenge beginLogin({required String returnTo}) {
    final pending = PendingAuthFlow(
      state: _stateToken(),
      returnTo: returnTo,
      providerMode: mode,
    );
    return AuthLoginChallenge(
      pending: pending,
      redirectLocation:
          '/auth/callback?provider=${mode.wireName}&state=${pending.state}&code=mock-code',
    );
  }

  @override
  AuthProviderIdentity completeCallback({
    required Uri requestedUri,
    required PendingAuthFlow pending,
    required AuthProviderIdentity bootstrapIdentity,
  }) {
    final query = requestedUri.queryParameters;
    if (query['state'] != pending.state) {
      throw const FormatException('OIDC state validation failed.');
    }
    if ((query['code'] ?? '').trim().isEmpty) {
      throw const FormatException('OIDC authorization code is missing.');
    }
    return identity;
  }
}

String _stateToken() {
  return 'st-${DateTime.now().microsecondsSinceEpoch}';
}
