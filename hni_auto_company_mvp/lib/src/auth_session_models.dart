enum HniUserRole { public, operator, lead, approver, ceo, admin, machine }

extension HniUserRoleView on HniUserRole {
  static HniUserRole fromName(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'operator':
        return HniUserRole.operator;
      case 'lead':
        return HniUserRole.lead;
      case 'approver':
        return HniUserRole.approver;
      case 'ceo':
        return HniUserRole.ceo;
      case 'admin':
        return HniUserRole.admin;
      case 'machine':
        return HniUserRole.machine;
      default:
        return HniUserRole.public;
    }
  }

  String get label => switch (this) {
    HniUserRole.public => 'Public',
    HniUserRole.operator => 'Operator',
    HniUserRole.lead => 'Lead',
    HniUserRole.approver => 'Approver',
    HniUserRole.ceo => 'CEO',
    HniUserRole.admin => 'Admin',
    HniUserRole.machine => 'Machine',
  };

  bool meets(HniUserRole minimum) => index >= minimum.index;
}

class SessionPrincipal {
  const SessionPrincipal({
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

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'name': name,
    'pictureUrl': pictureUrl,
    'role': role,
    'provider': provider,
    'providerSubjectId': providerSubjectId,
  };

  factory SessionPrincipal.fromJson(Map<String, dynamic> json) {
    return SessionPrincipal(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pictureUrl: json['pictureUrl'] as String?,
      role: json['role'] as String? ?? 'Public',
      provider: json['provider'] as String? ?? 'bootstrap',
      providerSubjectId: json['providerSubjectId'] as String? ?? '',
    );
  }
}

class AuthSessionSnapshot {
  const AuthSessionSnapshot({
    required this.authenticated,
    required this.capabilities,
    this.principal,
    this.authTime,
    this.issuedAt,
    this.expiresAt,
    this.recentAuthExpiresAt,
    this.csrfToken,
  });

  final bool authenticated;
  final SessionPrincipal? principal;
  final Map<String, bool> capabilities;
  final DateTime? authTime;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final DateTime? recentAuthExpiresAt;
  final String? csrfToken;

  HniUserRole get role => HniUserRoleView.fromName(principal?.role);

  bool get canApprove => capabilities['canApprove'] == true;

  bool get canAccessStrategy => capabilities['canAccessStrategy'] == true;

  bool get canManageTelegramOps => capabilities['canManageTelegramOps'] == true;

  bool get canExportAudit => capabilities['canExportAudit'] == true;

  bool hasAtLeast(HniUserRole minimum) {
    return authenticated && role.meets(minimum);
  }

  Map<String, dynamic> toJson() => {
    'authenticated': authenticated,
    'principal': principal?.toJson(),
    'capabilities': capabilities,
    'authTime': authTime?.toIso8601String(),
    'issuedAt': issuedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'recentAuthExpiresAt': recentAuthExpiresAt?.toIso8601String(),
    'csrfToken': csrfToken,
  };

  factory AuthSessionSnapshot.fromEnvelope(Map<String, dynamic> json) {
    final payload = json['session'];
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Missing session payload.');
    }
    return AuthSessionSnapshot.fromJson(payload);
  }

  factory AuthSessionSnapshot.fromJson(Map<String, dynamic> json) {
    final capabilityJson = json['capabilities'] as Map<String, dynamic>? ?? {};
    return AuthSessionSnapshot(
      authenticated: json['authenticated'] == true,
      principal: json['principal'] is Map<String, dynamic>
          ? SessionPrincipal.fromJson(json['principal'] as Map<String, dynamic>)
          : null,
      capabilities: {
        for (final entry in capabilityJson.entries)
          entry.key: entry.value == true,
      },
      authTime: _dateFromJson(json['authTime']),
      issuedAt: _dateFromJson(json['issuedAt']),
      expiresAt: _dateFromJson(json['expiresAt']),
      recentAuthExpiresAt: _dateFromJson(json['recentAuthExpiresAt']),
      csrfToken: json['csrfToken'] as String?,
    );
  }

  factory AuthSessionSnapshot.anonymous() {
    return const AuthSessionSnapshot(authenticated: false, capabilities: {});
  }

  factory AuthSessionSnapshot.localAdmin() {
    final now = DateTime.now().toUtc();
    return AuthSessionSnapshot(
      authenticated: true,
      principal: const SessionPrincipal(
        userId: 'local-admin',
        email: 'local-admin@humantric.net',
        name: 'Local Admin',
        role: 'Admin',
        provider: 'local',
        providerSubjectId: 'local-admin',
      ),
      capabilities: const {
        'canAccessStrategy': true,
        'canApprove': true,
        'canManageTelegramOps': true,
        'canExportAudit': true,
      },
      authTime: now,
      issuedAt: now,
      expiresAt: now.add(const Duration(hours: 8)),
      recentAuthExpiresAt: now.add(const Duration(minutes: 15)),
      csrfToken: 'local-admin-csrf',
    );
  }
}

DateTime? _dateFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}
