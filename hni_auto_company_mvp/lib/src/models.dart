enum OrderStatus {
  approvalPending,
  planned,
  inProgress,
  evaluation,
  revise,
  completed,
  hold,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.approvalPending => 'Approval Pending',
        OrderStatus.planned => 'Planned',
        OrderStatus.inProgress => 'In Progress',
        OrderStatus.evaluation => 'Evaluation',
        OrderStatus.revise => 'Revise',
        OrderStatus.completed => 'Completed',
        OrderStatus.hold => 'Hold',
      };
}

enum ExecutionStage {
  strategicReview,
  planning,
  execution,
  evaluation,
  revision,
  completion,
}

extension ExecutionStageX on ExecutionStage {
  String get label => switch (this) {
        ExecutionStage.strategicReview => 'Strategic Review',
        ExecutionStage.planning => 'Planned',
        ExecutionStage.execution => 'Execution',
        ExecutionStage.evaluation => 'Evaluation',
        ExecutionStage.revision => 'Revision',
        ExecutionStage.completion => 'Completion',
      };
}

enum StageState { pending, running, completed, skipped }

extension StageStateX on StageState {
  String get label => switch (this) {
        StageState.pending => 'Pending',
        StageState.running => 'Running',
        StageState.completed => 'Completed',
        StageState.skipped => 'Skipped',
      };
}

enum ApprovalType { plan, risk }

extension ApprovalTypeX on ApprovalType {
  String get label => switch (this) {
        ApprovalType.plan => 'Plan Approval',
        ApprovalType.risk => 'Risk Gate',
      };
}

enum ApprovalStatus { pending, approved, held, rejected }

extension ApprovalStatusX on ApprovalStatus {
  String get label => switch (this) {
        ApprovalStatus.pending => 'Pending',
        ApprovalStatus.approved => 'Approved',
        ApprovalStatus.held => 'Held',
        ApprovalStatus.rejected => 'Rejected',
      };
}

enum CommandChannel { dashboard, telegram, whatsapp }

extension CommandChannelX on CommandChannel {
  String get label => switch (this) {
        CommandChannel.dashboard => 'Dashboard',
        CommandChannel.telegram => 'Telegram',
        CommandChannel.whatsapp => 'WhatsApp',
      };
}

class RiskProfile {
  RiskProfile({
    this.scopeExpansion = false,
    this.production = false,
    this.security = false,
    this.privacy = false,
    this.payment = false,
    this.destructive = false,
  });

  bool scopeExpansion;
  bool production;
  bool security;
  bool privacy;
  bool payment;
  bool destructive;

  bool get requiresGate =>
      scopeExpansion ||
      production ||
      security ||
      privacy ||
      payment ||
      destructive;

  List<String> get labels {
    final values = <String>[];
    if (scopeExpansion) values.add('Scope');
    if (production) values.add('Production');
    if (security) values.add('Security');
    if (privacy) values.add('Privacy');
    if (payment) values.add('Payment');
    if (destructive) values.add('Destructive');
    return values;
  }

  Map<String, dynamic> toJson() => {
        'scopeExpansion': scopeExpansion,
        'production': production,
        'security': security,
        'privacy': privacy,
        'payment': payment,
        'destructive': destructive,
      };

  factory RiskProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RiskProfile();
    }
    return RiskProfile(
      scopeExpansion: json['scopeExpansion'] == true,
      production: json['production'] == true,
      security: json['security'] == true,
      privacy: json['privacy'] == true,
      payment: json['payment'] == true,
      destructive: json['destructive'] == true,
    );
  }
}

class StageRecord {
  StageRecord({
    required this.stage,
    required this.state,
    required this.summary,
    this.startedAt,
    this.endedAt,
  });

  ExecutionStage stage;
  StageState state;
  String summary;
  DateTime? startedAt;
  DateTime? endedAt;

  Map<String, dynamic> toJson() => {
        'stage': stage.name,
        'state': state.name,
        'summary': summary,
        'startedAt': startedAt?.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
      };

  factory StageRecord.fromJson(Map<String, dynamic> json) {
    return StageRecord(
      stage: ExecutionStage.values.byName(json['stage'] as String),
      state: StageState.values.byName(json['state'] as String),
      summary: json['summary'] as String? ?? '',
      startedAt: _dateFromJson(json['startedAt']),
      endedAt: _dateFromJson(json['endedAt']),
    );
  }
}

class ReportEntry {
  ReportEntry({
    required this.id,
    required this.orderId,
    required this.stage,
    required this.title,
    required this.summary,
    required this.findings,
    required this.recommendations,
    required this.ownerGroup,
    required this.personaLead,
    required this.createdAt,
  });

  String id;
  String orderId;
  ExecutionStage stage;
  String title;
  String summary;
  List<String> findings;
  List<String> recommendations;
  String ownerGroup;
  String personaLead;
  DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'stage': stage.name,
        'title': title,
        'summary': summary,
        'findings': findings,
        'recommendations': recommendations,
        'ownerGroup': ownerGroup,
        'personaLead': personaLead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ReportEntry.fromJson(Map<String, dynamic> json) {
    return ReportEntry(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      stage: ExecutionStage.values.byName(json['stage'] as String),
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      findings: (json['findings'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      ownerGroup: json['ownerGroup'] as String? ?? '',
      personaLead: json['personaLead'] as String? ?? '',
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class ApprovalRecord {
  ApprovalRecord({
    required this.id,
    required this.orderId,
    required this.type,
    required this.status,
    required this.note,
    required this.createdAt,
    this.resolvedAt,
  });

  String id;
  String orderId;
  ApprovalType type;
  ApprovalStatus status;
  String note;
  DateTime createdAt;
  DateTime? resolvedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'type': type.name,
        'status': status.name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
      };

  factory ApprovalRecord.fromJson(Map<String, dynamic> json) {
    return ApprovalRecord(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      type: ApprovalType.values.byName(json['type'] as String),
      status: ApprovalStatus.values.byName(json['status'] as String),
      note: json['note'] as String? ?? '',
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      resolvedAt: _dateFromJson(json['resolvedAt']),
    );
  }
}

class AuditEntry {
  AuditEntry({
    required this.id,
    required this.orderId,
    required this.message,
    required this.createdAt,
  });

  String id;
  String orderId;
  String message;
  DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      message: json['message'] as String? ?? '',
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class CommandLogEntry {
  CommandLogEntry({
    required this.id,
    required this.channel,
    required this.input,
    required this.result,
    required this.createdAt,
  });

  String id;
  CommandChannel channel;
  String input;
  String result;
  DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel': channel.name,
        'input': input,
        'result': result,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommandLogEntry.fromJson(Map<String, dynamic> json) {
    return CommandLogEntry(
      id: json['id'] as String,
      channel: CommandChannel.values.byName(json['channel'] as String),
      input: json['input'] as String? ?? '',
      result: json['result'] as String? ?? '',
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class WorkOrder {
  WorkOrder({
    required this.id,
    required this.title,
    required this.objective,
    required this.targetProduct,
    required this.targetBranch,
    required this.requestedBy,
    required this.sourceChannel,
    required this.assignedSquad,
    required this.status,
    required this.planSummary,
    required this.riskProfile,
    required this.planApproved,
    required this.createdAt,
    required this.updatedAt,
    required this.stageRecords,
    required this.reports,
    required this.approvals,
    required this.auditTrail,
  });

  String id;
  String title;
  String objective;
  String targetProduct;
  String targetBranch;
  String requestedBy;
  CommandChannel sourceChannel;
  String assignedSquad;
  OrderStatus status;
  String planSummary;
  RiskProfile riskProfile;
  bool planApproved;
  DateTime createdAt;
  DateTime updatedAt;
  List<StageRecord> stageRecords;
  List<ReportEntry> reports;
  List<ApprovalRecord> approvals;
  List<AuditEntry> auditTrail;

  ApprovalRecord? pendingApproval(ApprovalType type) {
    for (final approval in approvals) {
      if (approval.type == type && approval.status == ApprovalStatus.pending) {
        return approval;
      }
    }
    return null;
  }

  bool get hasPendingApprovals =>
      approvals.any((item) => item.status == ApprovalStatus.pending);

  bool get isCompleted => status == OrderStatus.completed;

  int get completedStages =>
      stageRecords.where((item) => item.state == StageState.completed).length;

  double get progress {
    if (stageRecords.isEmpty) {
      return 0;
    }
    return completedStages / stageRecords.length;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'objective': objective,
        'targetProduct': targetProduct,
        'targetBranch': targetBranch,
        'requestedBy': requestedBy,
        'sourceChannel': sourceChannel.name,
        'assignedSquad': assignedSquad,
        'status': status.name,
        'planSummary': planSummary,
        'riskProfile': riskProfile.toJson(),
        'planApproved': planApproved,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'stageRecords': stageRecords.map((item) => item.toJson()).toList(),
        'reports': reports.map((item) => item.toJson()).toList(),
        'approvals': approvals.map((item) => item.toJson()).toList(),
        'auditTrail': auditTrail.map((item) => item.toJson()).toList(),
      };

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      objective: json['objective'] as String? ?? '',
      targetProduct: json['targetProduct'] as String? ?? '',
      targetBranch: json['targetBranch'] as String? ?? '',
      requestedBy: json['requestedBy'] as String? ?? '',
      sourceChannel: CommandChannel.values.byName(
        json['sourceChannel'] as String? ?? CommandChannel.dashboard.name,
      ),
      assignedSquad: json['assignedSquad'] as String? ?? '',
      status: OrderStatus.values.byName(json['status'] as String),
      planSummary: json['planSummary'] as String? ?? '',
      riskProfile: RiskProfile.fromJson(
        json['riskProfile'] as Map<String, dynamic>?,
      ),
      planApproved: json['planApproved'] == true,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']) ?? DateTime.now(),
      stageRecords: (json['stageRecords'] as List<dynamic>? ?? const [])
          .map((item) => StageRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
      reports: (json['reports'] as List<dynamic>? ?? const [])
          .map((item) => ReportEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
      approvals: (json['approvals'] as List<dynamic>? ?? const [])
          .map((item) => ApprovalRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
      auditTrail: (json['auditTrail'] as List<dynamic>? ?? const [])
          .map((item) => AuditEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AppSnapshot {
  AppSnapshot({
    required this.orders,
    required this.commandLogs,
    this.selectedOrderId,
  });

  List<WorkOrder> orders;
  List<CommandLogEntry> commandLogs;
  String? selectedOrderId;

  Map<String, dynamic> toJson() => {
        'orders': orders.map((item) => item.toJson()).toList(),
        'commandLogs': commandLogs.map((item) => item.toJson()).toList(),
        'selectedOrderId': selectedOrderId,
      };

  factory AppSnapshot.fromJson(Map<String, dynamic> json) {
    return AppSnapshot(
      orders: (json['orders'] as List<dynamic>? ?? const [])
          .map((item) => WorkOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
      commandLogs: (json['commandLogs'] as List<dynamic>? ?? const [])
          .map((item) => CommandLogEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
      selectedOrderId: json['selectedOrderId'] as String?,
    );
  }

  AppSnapshot deepCopy() => AppSnapshot.fromJson(toJson());
}

class OrderDraft {
  OrderDraft({
    required this.title,
    required this.objective,
    required this.targetProduct,
    required this.targetBranch,
    required this.requestedBy,
    required this.sourceChannel,
    required this.assignedSquad,
    required this.riskProfile,
  });

  final String title;
  final String objective;
  final String targetProduct;
  final String targetBranch;
  final String requestedBy;
  final CommandChannel sourceChannel;
  final String assignedSquad;
  final RiskProfile riskProfile;

  Map<String, dynamic> toJson() => {
        'title': title,
        'objective': objective,
        'targetProduct': targetProduct,
        'targetBranch': targetBranch,
        'requestedBy': requestedBy,
        'sourceChannel': sourceChannel.name,
        'assignedSquad': assignedSquad,
        'riskProfile': riskProfile.toJson(),
      };

  factory OrderDraft.fromJson(Map<String, dynamic> json) {
    return OrderDraft(
      title: json['title'] as String? ?? '',
      objective: json['objective'] as String? ?? '',
      targetProduct: json['targetProduct'] as String? ?? 'Mozzy',
      targetBranch: json['targetBranch'] as String? ?? 'main',
      requestedBy: json['requestedBy'] as String? ?? 'Unknown',
      sourceChannel: CommandChannel.values.byName(
        json['sourceChannel'] as String? ?? CommandChannel.dashboard.name,
      ),
      assignedSquad: json['assignedSquad'] as String? ?? 'Feature Delivery',
      riskProfile: RiskProfile.fromJson(
        json['riskProfile'] as Map<String, dynamic>?,
      ),
    );
  }
}

class PendingApprovalItem {
  PendingApprovalItem({
    required this.order,
    required this.approval,
  });

  final WorkOrder order;
  final ApprovalRecord approval;
}

DateTime? _dateFromJson(Object? rawValue) {
  if (rawValue is String && rawValue.isNotEmpty) {
    return DateTime.tryParse(rawValue);
  }
  return null;
}
