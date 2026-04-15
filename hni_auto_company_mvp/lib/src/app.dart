import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'agent_catalog.dart';
import 'auth_session.dart';
import 'models.dart';
import 'store.dart';

class HniAutoCompanyApp extends StatefulWidget {
  const HniAutoCompanyApp({
    super.key,
    required this.store,
    required this.sessionController,
    this.initialLocation = '/',
  });

  final AutoCompanyStore store;
  final AuthSessionController sessionController;
  final String initialLocation;

  @override
  State<HniAutoCompanyApp> createState() => _HniAutoCompanyAppState();
}

enum AppSection { home, squads, orders, reports, approvals, channels, audit }

extension AppSectionView on AppSection {
  String get routePath => switch (this) {
    AppSection.home => '/dashboard/home',
    AppSection.squads => '/dashboard/squads',
    AppSection.orders => '/dashboard/orders',
    AppSection.reports => '/dashboard/reports',
    AppSection.approvals => '/dashboard/approvals',
    AppSection.channels => '/dashboard/channels',
    AppSection.audit => '/dashboard/audit',
  };

  String get headerTitle => switch (this) {
    AppSection.home => 'Executive Home',
    AppSection.squads => '14-Agent Dispatch',
    AppSection.orders => 'Work Orders',
    AppSection.reports => 'Reports',
    AppSection.approvals => 'Approval Gates',
    AppSection.channels => 'Channel Center',
    AppSection.audit => 'Audit Timeline',
  };
}

AppSection? _sectionFromPath(String path) {
  for (final section in AppSection.values) {
    if (section.routePath == path) {
      return section;
    }
  }
  return null;
}

HniUserRole _minimumRoleForSection(AppSection section) {
  return switch (section) {
    AppSection.home => HniUserRole.operator,
    AppSection.orders => HniUserRole.operator,
    AppSection.reports => HniUserRole.operator,
    AppSection.channels => HniUserRole.operator,
    AppSection.audit => HniUserRole.operator,
    AppSection.squads => HniUserRole.lead,
    AppSection.approvals => HniUserRole.approver,
  };
}

class _HniAutoCompanyAppState extends State<HniAutoCompanyApp> {
  CommandChannel _channel = CommandChannel.telegram;
  String _focusedPersona = agentPersonas.first.persona;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter _router;
  final TextEditingController _commandController = TextEditingController(
    text: '/new_order Neighborhood MVP | approval 이후 연속 실행 검증 | HNI | main',
  );

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: widget.initialLocation,
      refreshListenable: widget.sessionController,
      redirect: _handleRedirect,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
        GoRoute(path: '/dashboard', builder: (context, state) => const SizedBox()),
        for (final section in AppSection.values)
          GoRoute(
            path: section.routePath,
            builder: (context, state) => _buildDashboardPage(section),
          ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => _buildLoginRoute(state),
        ),
        GoRoute(
          path: '/auth/forbidden',
          builder: (context, state) => _buildRoutePlaceholder(
            title: 'Forbidden Route',
            message:
                '권한 게이트는 문서 설계까지 완료됐고, 실제 auth/session enforcement는 '
                '다음 slice에서 연결합니다.',
            primaryLabel: 'Back To Dashboard',
            onPrimaryAction: () => _goToSection(AppSection.home),
          ),
        ),
        GoRoute(
          path: '/auth/loading',
          builder: (context, state) => _buildRoutePlaceholder(
            title: 'Loading Session',
            message:
                'same-origin session bootstrap을 읽는 중입니다. '
                'session endpoint 응답 후 route gate를 다시 계산합니다.',
            primaryLabel: 'Retry Session',
            onPrimaryAction: () => unawaited(widget.sessionController.refresh()),
            showSpinner: true,
          ),
        ),
        GoRoute(
          path: '/auth/session-expired',
          builder: (context, state) => _buildRoutePlaceholder(
            title: 'Session Expired',
            message:
                '세션 만료 화면 placeholder입니다. 실제 session bootstrap 및 '
                'recent-auth enforcement는 아직 구현하지 않았습니다.',
            primaryLabel: 'Go To Login',
            onPrimaryAction: () => _router.go('/auth/login'),
          ),
        ),
      ],
      errorBuilder: (context, state) => _buildRoutePlaceholder(
        title: 'Route Not Found',
        message: 'Unknown route: ${state.uri.path}',
        primaryLabel: 'Open Dashboard',
        onPrimaryAction: () => _goToSection(AppSection.home),
      ),
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mozzy-ai-team Control Plane',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: _buildTheme(),
      routerConfig: _router,
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0E7490),
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }

  Widget _buildDashboardPage(AppSection section) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.store, widget.sessionController]),
      builder: (context, _) {
        final store = widget.store;
        final session = widget.sessionController.session;
        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7F2E8), Color(0xFFEAF4F1)],
              ),
            ),
            child: Row(
              children: [
                _NavigationSidebar(
                  selected: section,
                  onSelect: _goToSection,
                ),
                Expanded(
                  child: Column(
                    children: [
                      _TopHeader(
                        store: store,
                        session: session,
                        section: section,
                        onNewOrder: _openCreateOrderDialog,
                        onSignOut: widget.sessionController.isAuthenticated
                            ? () async {
                                final redirectTo =
                                    await widget.sessionController.logout();
                                if (widget.store.isRemoteMode) {
                                  await widget.store.enterRemoteShell();
                                }
                                if (!mounted) {
                                  return;
                                }
                                _router.go(redirectTo ?? '/auth/login');
                              }
                            : null,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 16, 16),
                          child: _SectionSurface(
                            child: _buildSection(store, section),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(AutoCompanyStore store, AppSection section) {
    final session = widget.sessionController.session;
    return switch (section) {
      AppSection.home => _buildHome(store, session),
      AppSection.squads => _buildSquads(store, session),
      AppSection.orders => _buildOrders(store, session),
      AppSection.reports => _buildReports(store),
      AppSection.approvals => _buildApprovals(store, session),
      AppSection.channels => _buildChannels(store, session),
      AppSection.audit => _buildAudit(store),
    };
  }

  Widget _buildRoutePlaceholder({
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimaryAction,
    bool showSpinner = false,
  }) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F2E8), Color(0xFFEAF4F1)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(message, style: Theme.of(context).textTheme.bodyLarge),
                    if (showSpinner) ...[
                      const SizedBox(height: 18),
                      const CircularProgressIndicator(),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onPrimaryAction,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(primaryLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToSection(AppSection section) {
    if (_router.state.uri.path == section.routePath) {
      return;
    }
    _router.go(section.routePath);
  }

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final session = widget.sessionController;
    final path = state.uri.path;
    final currentLocation = state.uri.toString();
    if (session.isLoading) {
      if (path == '/auth/loading') {
        return null;
      }
      return Uri(
        path: '/auth/loading',
        queryParameters: {'returnTo': currentLocation},
      ).toString();
    }

    final section = _sectionFromPath(path);
    if (!session.isAuthenticated) {
      if (section != null || path == '/' || path == '/dashboard') {
        return Uri(
          path: '/auth/login',
          queryParameters: {
            'returnTo': section == null ? AppSection.home.routePath : currentLocation,
          },
        ).toString();
      }
      return null;
    }

    if (path == '/' ||
        path == '/dashboard' ||
        path == '/auth/login' ||
        path == '/auth/loading' ||
        path == '/auth/session-expired') {
      return state.uri.queryParameters['returnTo'] ?? AppSection.home.routePath;
    }

    if (section != null) {
      final minimumRole = _minimumRoleForSection(section);
      if (!session.session.hasAtLeast(minimumRole)) {
        return '/auth/forbidden';
      }
    }
    return null;
  }

  Widget _buildLoginRoute(GoRouterState state) {
    return AnimatedBuilder(
      animation: widget.sessionController,
      builder: (context, _) {
        final session = widget.sessionController;
        final returnTo =
            state.uri.queryParameters['returnTo'] ?? AppSection.home.routePath;
        return _buildRoutePlaceholder(
          title: 'Login Route',
          message: session.lastError == null
              ? 'OIDC/provider 실연동 전 단계입니다. 현재는 same-origin '
                    'bootstrap session으로 route gate와 dashboard shell을 먼저 검증합니다.'
              : 'session bootstrap 실패: ${session.lastError}',
          primaryLabel: session.isAuthenticated
              ? 'Open Dashboard'
              : 'Bootstrap Session',
          onPrimaryAction: () {
            if (session.isAuthenticated) {
              _router.go(returnTo);
              return;
            }
            unawaited(_bootstrapSessionAndRedirect(returnTo));
          },
          showSpinner: session.isLoading,
        );
      },
    );
  }

  Future<void> _bootstrapSessionAndRedirect(String returnTo) async {
    final redirectTo = await widget.sessionController.bootstrapLogin(
      returnTo: returnTo,
    );
    if (widget.store.isRemoteMode && widget.sessionController.isAuthenticated) {
      await widget.store.reconnectRemote();
    }
    if (!mounted) {
      return;
    }
    _router.go(redirectTo ?? returnTo);
  }

  bool _hasRole(AuthSessionSnapshot session, HniUserRole minimumRole) {
    return session.hasAtLeast(minimumRole);
  }

  Widget _buildHome(AutoCompanyStore store, AuthSessionSnapshot session) {
    final activeOrders = store.orders.take(4).toList();
    final reports = store.allReports.take(3).toList();
    final selectedOrder = store.selectedOrder;
    final canAssignLead = _hasRole(session, HniUserRole.lead);
    final canDispatch = _hasRole(session, HniUserRole.lead);
    final canManageApprovals = _hasRole(session, HniUserRole.approver);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mozzy-ai-team Control Plane',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'HNI용 14-persona AI agent 협업 control plane입니다. '
            '대시보드와 채널을 통해 order, approval, dispatch, report를 한 화면에서 추적합니다.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            store.isRemoteMode
                ? '현재 모드: ${store.modeLabel} · ${store.backendStatusLabel}'
                : '현재 모드: ${store.modeLabel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (store.backendBaseUrl != null) ...[
            const SizedBox(height: 4),
            Text(
              store.backendBaseUrl!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: 'Active Orders',
                value: '${store.activeOrderCount}',
                caption: 'approval pending + running',
                accent: const Color(0xFF115E59),
              ),
              _MetricCard(
                label: 'Pending Gates',
                value: '${store.pendingApprovalCount}',
                caption: 'plan / risk approvals',
                accent: const Color(0xFFB45309),
              ),
              _MetricCard(
                label: 'Auto Runs',
                value: '${store.activeRunCount}',
                caption: 'live stage runners',
                accent: const Color(0xFF7C3AED),
              ),
              _MetricCard(
                label: 'Completed',
                value: '${store.completedCount}',
                caption: 'orders closed',
                accent: const Color(0xFF15803D),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 980;
              if (!wide) {
                return Column(
                  children: [
                    _InfoCard(
                      title: 'Active Orders',
                      child: Column(
                        children: activeOrders
                            .map(
                              (order) => _OrderListTile(
                                order: order,
                                selected: false,
                                onTap: () {
                                  store.selectOrder(order.id);
                                  _goToSection(AppSection.orders);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Recent Reports',
                      child: Column(
                        children: reports
                            .map((report) => _ReportTile(report: report))
                            .toList(),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: 'Active Orders',
                      child: Column(
                        children: activeOrders
                            .map(
                              (order) => _OrderListTile(
                                order: order,
                                selected: false,
                                onTap: () {
                                  store.selectOrder(order.id);
                                  _goToSection(AppSection.orders);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      title: 'Recent Reports',
                      child: Column(
                        children: reports
                            .map((report) => _ReportTile(report: report))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: '14-Agent Control Panel',
            child: _AgentControlPanel(
              graph: store.selectedAgentGraph,
              selectedOrder: selectedOrder,
              focusedPersona: _focusedPersona,
              onFocusPersona: (persona) {
                setState(() => _focusedPersona = persona);
              },
              onAssignLead: selectedOrder == null || !canAssignLead
                  ? null
                  : (persona) async {
                      await store.assignPersonaLead(selectedOrder.id, persona);
                      _showMessage('Lead assigned: $persona');
                    },
              onDispatch: selectedOrder == null || !canDispatch
                  ? null
                  : (persona) async {
                      await store.dispatchPersona(selectedOrder.id, persona);
                      _showMessage('Dispatch queued: $persona');
                    },
              onHoldResume: selectedOrder == null || !canManageApprovals
                  ? null
                  : () async {
                      if (selectedOrder.status == OrderStatus.hold) {
                        await store.resumeOrder(selectedOrder.id);
                        _showMessage('Order resumed');
                      } else {
                        await store.holdOrder(
                          selectedOrder.id,
                          note: 'Control panel hold',
                        );
                        _showMessage('Order held');
                      }
                    },
              onJumpToReports: selectedOrder == null
                  ? null
                  : () {
                      store.selectOrder(selectedOrder.id);
                      _goToSection(AppSection.reports);
                    },
              onJumpToAudit: selectedOrder == null
                  ? null
                  : () {
                      store.selectOrder(selectedOrder.id);
                      _goToSection(AppSection.audit);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquads(AutoCompanyStore store, AuthSessionSnapshot session) {
    final selectedOrder = store.selectedOrder;
    final canAssignLead = _hasRole(session, HniUserRole.lead);
    final canDispatch = _hasRole(session, HniUserRole.lead);
    final canManageApprovals = _hasRole(session, HniUserRole.approver);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '14-Agent Dispatch Console',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '선택된 work order 기준으로 lead 지정, persona dispatch, hold/resume, report/audit jump를 수행합니다.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final order in store.orders.take(8))
                    ChoiceChip(
                      label: Text('${order.id} · ${order.title}'),
                      selected: selectedOrder?.id == order.id,
                      onSelected: (_) => store.selectOrder(order.id),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AgentControlPanel(
            graph: store.selectedAgentGraph,
            selectedOrder: selectedOrder,
            focusedPersona: _focusedPersona,
            onFocusPersona: (persona) {
              setState(() => _focusedPersona = persona);
            },
            onAssignLead: selectedOrder == null || !canAssignLead
                ? null
                : (persona) async {
                    await store.assignPersonaLead(selectedOrder.id, persona);
                    _showMessage('Lead assigned: $persona');
                  },
            onDispatch: selectedOrder == null || !canDispatch
                ? null
                : (persona) async {
                    await store.dispatchPersona(selectedOrder.id, persona);
                    _showMessage('Dispatch queued: $persona');
                  },
            onHoldResume: selectedOrder == null || !canManageApprovals
                ? null
                : () async {
                    if (selectedOrder.status == OrderStatus.hold) {
                      await store.resumeOrder(selectedOrder.id);
                      _showMessage('Order resumed');
                    } else {
                      await store.holdOrder(
                        selectedOrder.id,
                        note: 'Control panel hold',
                      );
                      _showMessage('Order held');
                    }
                  },
            onJumpToReports: selectedOrder == null
                ? null
                : () {
                    store.selectOrder(selectedOrder.id);
                    _goToSection(AppSection.reports);
                  },
            onJumpToAudit: selectedOrder == null
                ? null
                : () {
                    store.selectOrder(selectedOrder.id);
                    _goToSection(AppSection.audit);
                  },
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildOrders(AutoCompanyStore store, AuthSessionSnapshot session) {
    final order = store.selectedOrder;
    final canCreateOrders = _hasRole(session, HniUserRole.operator);
    final canManageApprovals = _hasRole(session, HniUserRole.approver);
    return Row(
      children: [
        SizedBox(
          width: 360,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Work Orders',
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: canCreateOrders ? _openCreateOrderDialog : null,
                      icon: const Icon(Icons.add),
                      label: const Text('New'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.builder(
                    itemCount: store.orders.length,
                    itemBuilder: (context, index) {
                      final item = store.orders[index];
                      return _OrderListTile(
                        order: item,
                        selected: order?.id == item.id,
                        onTap: () => store.selectOrder(item.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
            child: order == null
                ? const Center(child: Text('No order selected'))
                : _OrderDetailPane(
                    order: order,
                    onApprovePlan: canManageApprovals
                        ? () {
                      final approval = order.pendingApproval(ApprovalType.plan);
                      if (approval != null) {
                        unawaited(store.approveApproval(order.id, approval.id));
                      }
                    }
                        : null,
                    onApproveRisk: canManageApprovals
                        ? () {
                      final approval = order.pendingApproval(ApprovalType.risk);
                      if (approval != null) {
                        unawaited(store.approveApproval(order.id, approval.id));
                      }
                    }
                        : null,
                    onHold: canManageApprovals
                        ? () => unawaited(store.holdOrder(order.id))
                        : null,
                    onResume: canManageApprovals
                        ? () => unawaited(store.resumeOrder(order.id))
                        : null,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReports(AutoCompanyStore store) {
    final reports = store.allReports;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StagePill(
                      label: report.stage.label,
                      tone: _toneForStage(report.stage),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        report.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(report.summary),
                const SizedBox(height: 10),
                Text(
                  '${report.ownerGroup} · ${report.personaLead}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (report.findings.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...report.findings.map((item) => Text('• $item')),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovals(AutoCompanyStore store, AuthSessionSnapshot session) {
    final approvals = store.approvalQueue;
    final canManageApprovals = _hasRole(session, HniUserRole.approver);
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: approvals.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = approvals[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusPill(
                      label: item.approval.type.label,
                      color: item.approval.type == ApprovalType.plan
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item.order.id} · ${item.order.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item.approval.note),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: canManageApprovals
                          ? () => unawaited(
                              store.approveApproval(
                                item.order.id,
                                item.approval.id,
                              ),
                            )
                          : null,
                      child: const Text('Approve'),
                    ),
                    OutlinedButton(
                      onPressed: canManageApprovals
                          ? () => unawaited(
                              store.holdOrder(
                                item.order.id,
                                note: item.approval.note,
                              ),
                            )
                          : null,
                      child: const Text('Hold'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChannels(
    AutoCompanyStore store,
    AuthSessionSnapshot session,
  ) {
    final canRunCommands = _hasRole(session, HniUserRole.operator);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Channel Simulator',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '실제 webhook 대신 Telegram/WhatsApp 형식 command를 '
            '같은 규격으로 로컬 시뮬레이션합니다.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 860;
                  final channelPicker = SizedBox(
                    width: isCompact ? double.infinity : 180,
                    child: DropdownButtonFormField<CommandChannel>(
                      initialValue: _channel,
                      isExpanded: true,
                      items: CommandChannel.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _channel = value);
                        }
                      },
                    ),
                  );
                  final commandField = TextField(
                    controller: _commandController,
                    decoration: const InputDecoration(
                      hintText:
                          '/new_order title | objective | product | branch',
                    ),
                  );
                  final runButton = FilledButton.icon(
                    onPressed: !canRunCommands
                        ? null
                        : () async {
                      final input = _commandController.text.trim();
                      if (input.isEmpty) {
                        return;
                      }
                      await store.submitCommand(_channel, input);
                      if (mounted) {
                        _scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(content: Text('Command dispatched')),
                        );
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Run'),
                  );

                  return Column(
                    children: [
                      if (isCompact) ...[
                        channelPicker,
                        const SizedBox(height: 12),
                        commandField,
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: runButton,
                        ),
                      ] else
                        Row(
                          children: [
                            channelPicker,
                            const SizedBox(width: 12),
                            Expanded(child: commandField),
                            const SizedBox(width: 12),
                            runButton,
                          ],
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SuggestionChip(
                            label: '/new_order Neighborhood read | 승인 후 연속 실행',
                            onTap: () => _commandController.text =
                                '/new_order Neighborhood read | 승인 후 연속 실행 | Mozzy | hyperlocal-proposal',
                          ),
                          _SuggestionChip(
                            label: '/approve WO-101',
                            onTap: () =>
                                _commandController.text = '/approve WO-101',
                          ),
                          _SuggestionChip(
                            label: '/status WO-101',
                            onTap: () =>
                                _commandController.text = '/status WO-101',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: store.commandLogs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = store.commandLogs[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusPill(
                              label: log.channel.label,
                              color: log.channel == CommandChannel.telegram
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                log.input,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if ((log.senderLabel ?? '').isNotEmpty ||
                            (log.chatId ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              [
                                if ((log.senderLabel ?? '').isNotEmpty)
                                  log.senderLabel!,
                                if ((log.chatId ?? '').isNotEmpty)
                                  'chat ${log.chatId}',
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF64748B)),
                            ),
                          ),
                        Text(log.result),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudit(AutoCompanyStore store) {
    final entries = store.allAuditEntries;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE6FFFB),
              child: Icon(Icons.timeline, color: Color(0xFF115E59)),
            ),
            title: Text(entry.message),
            subtitle: Text(
              '${entry.orderId} · ${_formatDateTime(entry.createdAt)}',
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCreateOrderDialog() async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) {
      return;
    }
    final titleController = TextEditingController();
    final objectiveController = TextEditingController();
    final requesterController = TextEditingController(text: 'HNI CEO');
    final branchController = TextEditingController(text: 'main');
    final productController = TextEditingController(text: 'Mozzy');
    String squad = 'Feature Delivery';
    final risk = RiskProfile();

    await showDialog<void>(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Work Order'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: objectiveController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Objective',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: productController,
                              decoration: const InputDecoration(
                                labelText: 'Target Product',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: branchController,
                              decoration: const InputDecoration(
                                labelText: 'Target Branch',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: requesterController,
                              decoration: const InputDecoration(
                                labelText: 'Requested By',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: squad,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Discovery',
                                  child: Text('Discovery'),
                                ),
                                DropdownMenuItem(
                                  value: 'Feature Delivery',
                                  child: Text('Feature Delivery'),
                                ),
                                DropdownMenuItem(
                                  value: 'Trust & Readiness',
                                  child: Text('Trust & Readiness'),
                                ),
                                DropdownMenuItem(
                                  value: 'Release Planning',
                                  child: Text('Release Planning'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setDialogState(() => squad = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Risk Flags',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      CheckboxListTile(
                        value: risk.scopeExpansion,
                        onChanged: (value) {
                          setDialogState(
                            () => risk.scopeExpansion = value ?? false,
                          );
                        },
                        title: const Text('Scope expansion'),
                      ),
                      CheckboxListTile(
                        value: risk.production,
                        onChanged: (value) {
                          setDialogState(
                            () => risk.production = value ?? false,
                          );
                        },
                        title: const Text('Production action'),
                      ),
                      CheckboxListTile(
                        value: risk.security,
                        onChanged: (value) {
                          setDialogState(() => risk.security = value ?? false);
                        },
                        title: const Text('Security'),
                      ),
                      CheckboxListTile(
                        value: risk.privacy,
                        onChanged: (value) {
                          setDialogState(() => risk.privacy = value ?? false);
                        },
                        title: const Text('Privacy'),
                      ),
                      CheckboxListTile(
                        value: risk.payment,
                        onChanged: (value) {
                          setDialogState(() => risk.payment = value ?? false);
                        },
                        title: const Text('Payment'),
                      ),
                      CheckboxListTile(
                        value: risk.destructive,
                        onChanged: (value) {
                          setDialogState(
                            () => risk.destructive = value ?? false,
                          );
                        },
                        title: const Text('Destructive change'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        objectiveController.text.trim().isEmpty) {
                      return;
                    }
                    final navigator = Navigator.of(context);
                    await widget.store.createOrder(
                      OrderDraft(
                        title: titleController.text.trim(),
                        objective: objectiveController.text.trim(),
                        targetProduct: productController.text.trim(),
                        targetBranch: branchController.text.trim(),
                        requestedBy: requesterController.text.trim(),
                        sourceChannel: CommandChannel.dashboard,
                        assignedSquad: squad,
                        riskProfile: risk,
                      ),
                    );
                    if (!mounted) {
                      return;
                    }
                    navigator.pop();
                    _goToSection(AppSection.orders);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar({required this.selected, required this.onSelect});

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF115E59)],
        ),
      ),
      child: NavigationRail(
        minWidth: 96,
        backgroundColor: Colors.transparent,
        labelType: NavigationRailLabelType.all,
        selectedIndex: AppSection.values.indexOf(selected),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        selectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: const IconThemeData(color: Color(0xFFD1D5DB)),
        unselectedLabelTextStyle: const TextStyle(color: Color(0xFFD1D5DB)),
        onDestinationSelected: (index) => onSelect(AppSection.values[index]),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.account_tree_outlined),
            label: Text('Squads'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.assignment_outlined),
            label: Text('Orders'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.description_outlined),
            label: Text('Reports'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.approval_outlined),
            label: Text('Gates'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.forum_outlined),
            label: Text('Channels'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.timeline_outlined),
            label: Text('Audit'),
          ),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.store,
    required this.session,
    required this.section,
    required this.onNewOrder,
    this.onSignOut,
  });

  final AutoCompanyStore store;
  final AuthSessionSnapshot session;
  final AppSection section;
  final VoidCallback onNewOrder;
  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      section.headerTitle,
      style: Theme.of(context).textTheme.titleLarge,
    );
    final actions = Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusPill(
          label: store.modeLabel,
          color: store.isRemoteMode
              ? const Color(0xFF1D4ED8)
              : const Color(0xFF475569),
        ),
        _StatusPill(
          label: store.backendStatusLabel,
          color: store.isRemoteMode
              ? const Color(0xFF0891B2)
              : const Color(0xFF64748B),
        ),
        _StatusPill(
          label: 'Auto Runs ${store.activeRunCount}',
          color: const Color(0xFF7C3AED),
        ),
        _StatusPill(
          label: 'Pending ${store.pendingApprovalCount}',
          color: const Color(0xFFB45309),
        ),
        if (session.authenticated && session.principal != null)
          _StatusPill(
            label: '${session.principal!.name} · ${session.role.label}',
            color: const Color(0xFF0F766E),
          ),
        FilledButton.icon(
          onPressed: onNewOrder,
          icon: const Icon(Icons.add),
          label: const Text('New Work Order'),
        ),
        if (onSignOut != null)
          OutlinedButton.icon(
            onPressed: () => unawaited(onSignOut!()),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 12), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 12),
              Flexible(
                child: Align(alignment: Alignment.centerRight, child: actions),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(34), child: child),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.accent,
  });

  final String label;
  final String value;
  final String caption;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: accent, fontSize: 34),
          ),
          const SizedBox(height: 8),
          Text(caption),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AgentControlPanel extends StatelessWidget {
  const _AgentControlPanel({
    required this.graph,
    required this.selectedOrder,
    required this.focusedPersona,
    required this.onFocusPersona,
    required this.onAssignLead,
    required this.onDispatch,
    required this.onHoldResume,
    required this.onJumpToReports,
    required this.onJumpToAudit,
  });

  final AgentGraph? graph;
  final WorkOrder? selectedOrder;
  final String focusedPersona;
  final ValueChanged<String> onFocusPersona;
  final Future<void> Function(String persona)? onAssignLead;
  final Future<void> Function(String persona)? onDispatch;
  final Future<void> Function()? onHoldResume;
  final VoidCallback? onJumpToReports;
  final VoidCallback? onJumpToAudit;

  @override
  Widget build(BuildContext context) {
    final index = {
      for (final persona in agentPersonas) persona.persona: persona,
    };
    final nodes =
        graph?.nodes ??
        agentPersonas
            .map(
              (persona) => AgentGraphNode(
                persona: persona.persona,
                group: persona.group,
                title: persona.title,
                focus: persona.focus,
                status: AgentNodeStatus.idle,
                assigned: false,
                isLead: false,
                reportCount: 0,
              ),
            )
            .toList();
    final focusedNode = nodes.where((node) => node.persona == focusedPersona);
    final currentNode = focusedNode.isEmpty ? nodes.first : focusedNode.first;
    final currentMeta = index[currentNode.persona]!;
    final order = selectedOrder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (order != null) ...[
              _StatusPill(label: order.id, color: const Color(0xFF0F766E)),
              _StatusPill(
                label: order.status.label,
                color: _colorForOrderStatus(order.status),
              ),
              _StatusPill(
                label: graph?.providerMode ?? 'local-store',
                color: const Color(0xFF2563EB),
              ),
            ] else
              const _StatusPill(
                label: 'No order selected',
                color: Color(0xFF64748B),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: nodes
              .map(
                (node) => _AgentNodeCard(
                  node: node,
                  selected: focusedPersona == node.persona,
                  onTap: () => onFocusPersona(node.persona),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white.withValues(alpha: 0.94),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 980;
                final detail = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusPill(
                          label: currentMeta.group,
                          color: _colorForAgentGroup(currentMeta.group),
                        ),
                        _StatusPill(
                          label: currentNode.status.label,
                          color: _colorForNodeStatus(currentNode.status),
                        ),
                        if (currentNode.isLead)
                          const _StatusPill(
                            label: 'Lead',
                            color: Color(0xFF7C3AED),
                          ),
                        if (currentNode.assigned)
                          const _StatusPill(
                            label: 'Assigned',
                            color: Color(0xFF15803D),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentMeta.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentMeta.persona,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),
                    Text(currentMeta.focus),
                    const SizedBox(height: 12),
                    if (currentNode.latestSummary != null &&
                        currentNode.latestSummary!.isNotEmpty)
                      Text(
                        currentNode.latestSummary!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      Text(
                        '최근 보고 요약이 아직 없습니다. 먼저 dispatch 하거나 stage run을 완료하세요.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                );
                final controls = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: order == null || onAssignLead == null
                          ? null
                          : () => onAssignLead!(currentMeta.persona),
                      icon: const Icon(Icons.person_pin_circle_outlined),
                      label: Text(
                        currentNode.isLead ? 'Reassign Lead' : 'Assign Lead',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: order == null || onDispatch == null
                          ? null
                          : () => onDispatch!(currentMeta.persona),
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text('Dispatch'),
                    ),
                    OutlinedButton.icon(
                      onPressed: order == null || onHoldResume == null
                          ? null
                          : () => onHoldResume!(),
                      icon: Icon(
                        order?.status == OrderStatus.hold
                            ? Icons.play_circle_outline
                            : Icons.pause_circle_outline,
                      ),
                      label: Text(
                        order?.status == OrderStatus.hold
                            ? 'Resume Order'
                            : 'Hold Order',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onJumpToReports,
                      icon: const Icon(Icons.description_outlined),
                      label: const Text('Latest Report'),
                    ),
                    TextButton.icon(
                      onPressed: onJumpToAudit,
                      icon: const Icon(Icons.timeline_outlined),
                      label: const Text('Audit Trail'),
                    ),
                  ],
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [detail, const SizedBox(height: 16), controls],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: detail),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: controls),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentNodeCard extends StatelessWidget {
  const _AgentNodeCard({
    required this.node,
    required this.selected,
    required this.onTap,
  });

  final AgentGraphNode node;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _colorForAgentGroup(node.group);
    final tone = _colorForNodeStatus(node.status);
    return SizedBox(
      width: 248,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? tone.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? tone : accent.withValues(alpha: 0.2),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _StatusPill(label: node.group, color: accent),
                    _StatusPill(label: node.status.label, color: tone),
                  ],
                ),
                const SizedBox(height: 10),
                Text(node.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(
                  node.persona,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                Text(node.focus, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Text(
                  'Reports ${node.reportCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  const _OrderListTile({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  final WorkOrder order;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? const Color(0xFFECFDF5) : null,
      child: ListTile(
        onTap: onTap,
        title: Text(order.title),
        subtitle: Text('${order.id} · ${order.targetProduct}'),
        trailing: _StatusPill(
          label: order.status.label,
          color: _colorForOrderStatus(order.status),
        ),
      ),
    );
  }
}

class _OrderDetailPane extends StatelessWidget {
  const _OrderDetailPane({
    required this.order,
    required this.onApprovePlan,
    required this.onApproveRisk,
    required this.onHold,
    required this.onResume,
  });

  final WorkOrder order;
  final VoidCallback? onApprovePlan;
  final VoidCallback? onApproveRisk;
  final VoidCallback? onHold;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final pendingPlan = order.pendingApproval(ApprovalType.plan);
    final pendingRisk = order.pendingApproval(ApprovalType.risk);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.title,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(label: order.id, color: const Color(0xFF0F766E)),
              _StatusPill(
                label: order.status.label,
                color: _colorForOrderStatus(order.status),
              ),
              _StatusPill(
                label: order.assignedSquad,
                color: const Color(0xFF4338CA),
              ),
              if (order.riskProfile.labels.isNotEmpty)
                ...order.riskProfile.labels.map(
                  (item) =>
                      _StatusPill(label: item, color: const Color(0xFFB45309)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Objective',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(order.objective),
                  const SizedBox(height: 16),
                  Text(
                    'Plan Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(order.planSummary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (pendingPlan != null)
                FilledButton(
                  onPressed: onApprovePlan,
                  child: const Text('Approve Plan'),
                ),
              if (pendingRisk != null)
                FilledButton.tonal(
                  onPressed: onApproveRisk,
                  child: const Text('Approve Risk Gate'),
                ),
              OutlinedButton(onPressed: onHold, child: const Text('Hold')),
              OutlinedButton(onPressed: onResume, child: const Text('Resume')),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Execution Stages',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...order.stageRecords.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StagePill(
                            label: record.state.label,
                            tone: _toneForStage(record.stage),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.stage.label,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(record.summary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generated Reports',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...order.reports.reversed.map(
                    (report) => _ReportTile(report: report),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final ReportEntry report;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StagePill(
                  label: report.stage.label,
                  tone: _toneForStage(report.stage),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(report.summary),
            const SizedBox(height: 6),
            Text(
              '${report.ownerGroup} · ${report.personaLead} · '
              '${_formatDateTime(report.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  const _StagePill({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tone.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, color: tone),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(onPressed: onTap, label: Text(label));
  }
}

Color _colorForOrderStatus(OrderStatus status) => switch (status) {
  OrderStatus.approvalPending => const Color(0xFFB45309),
  OrderStatus.planned => const Color(0xFF0F766E),
  OrderStatus.inProgress => const Color(0xFF2563EB),
  OrderStatus.evaluation => const Color(0xFF7C3AED),
  OrderStatus.revise => const Color(0xFFDC2626),
  OrderStatus.completed => const Color(0xFF15803D),
  OrderStatus.hold => const Color(0xFF6B7280),
};

Color _toneForStage(ExecutionStage stage) => switch (stage) {
  ExecutionStage.strategicReview => const Color(0xFF7C3AED),
  ExecutionStage.planning => const Color(0xFF0F766E),
  ExecutionStage.execution => const Color(0xFF2563EB),
  ExecutionStage.evaluation => const Color(0xFFB45309),
  ExecutionStage.revision => const Color(0xFFDC2626),
  ExecutionStage.completion => const Color(0xFF15803D),
};

Color _colorForAgentGroup(String group) => switch (group) {
  'Strategy' => const Color(0xFF7C3AED),
  'Product' => const Color(0xFF0F766E),
  'Engineering' => const Color(0xFF2563EB),
  'Business' => const Color(0xFFB45309),
  'Intelligence' => const Color(0xFFDC2626),
  _ => const Color(0xFF475569),
};

Color _colorForNodeStatus(AgentNodeStatus status) => switch (status) {
  AgentNodeStatus.idle => const Color(0xFF64748B),
  AgentNodeStatus.queued => const Color(0xFFB45309),
  AgentNodeStatus.active => const Color(0xFF2563EB),
  AgentNodeStatus.blocked => const Color(0xFF6B7280),
  AgentNodeStatus.completed => const Color(0xFF15803D),
  AgentNodeStatus.recent => const Color(0xFF0F766E),
  AgentNodeStatus.lead => const Color(0xFF7C3AED),
};

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
