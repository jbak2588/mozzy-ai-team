import 'dart:async';

import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class HniAutoCompanyApp extends StatefulWidget {
  const HniAutoCompanyApp({
    super.key,
    required this.store,
  });

  final AutoCompanyStore store;

  @override
  State<HniAutoCompanyApp> createState() => _HniAutoCompanyAppState();
}

enum AppSection { home, orders, reports, approvals, channels, audit }

class _HniAutoCompanyAppState extends State<HniAutoCompanyApp> {
  AppSection _section = AppSection.home;
  CommandChannel _channel = CommandChannel.telegram;
  final TextEditingController _commandController = TextEditingController(
    text: '/new_order Neighborhood MVP | approval 이후 연속 실행 검증 | HNI | main',
  );

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HNI Auto-Company MVP',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          final store = widget.store;
          return Scaffold(
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF7F2E8),
                    Color(0xFFEAF4F1),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _NavigationSidebar(
                    selected: _section,
                    onSelect: (section) => setState(() => _section = section),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _TopHeader(
                          store: store,
                          section: _section,
                          onNewOrder: _openCreateOrderDialog,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 16, 16),
                            child: _SectionSurface(
                              child: _buildSection(store),
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
      ),
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
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
          ),
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

  Widget _buildSection(AutoCompanyStore store) {
    return switch (_section) {
      AppSection.home => _buildHome(store),
      AppSection.orders => _buildOrders(store),
      AppSection.reports => _buildReports(store),
      AppSection.approvals => _buildApprovals(store),
      AppSection.channels => _buildChannels(store),
      AppSection.audit => _buildAudit(store),
    };
  }

  Widget _buildHome(AutoCompanyStore store) {
    final activeOrders = store.orders.take(4).toList();
    final reports = store.allReports.take(3).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HNI Auto-Company MVP',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'plan approval 이후에는 추가 단계 문의 없이 '
            'agreed chain을 끝까지 실행하는 HNI auto-company 실행 앱입니다.',
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
                                  setState(() => _section = AppSection.orders);
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
                                  setState(() => _section = AppSection.orders);
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
        ],
      ),
    );
  }

  Widget _buildOrders(AutoCompanyStore store) {
    final order = store.selectedOrder;
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
                    Text(
                      'Work Orders',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _openCreateOrderDialog,
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
                    onApprovePlan: () {
                      final approval = order.pendingApproval(ApprovalType.plan);
                      if (approval != null) {
                        unawaited(
                          store.approveApproval(order.id, approval.id),
                        );
                      }
                    },
                    onApproveRisk: () {
                      final approval = order.pendingApproval(ApprovalType.risk);
                      if (approval != null) {
                        unawaited(
                          store.approveApproval(order.id, approval.id),
                        );
                      }
                    },
                    onHold: () => unawaited(store.holdOrder(order.id)),
                    onResume: () => unawaited(store.resumeOrder(order.id)),
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

  Widget _buildApprovals(AutoCompanyStore store) {
    final approvals = store.approvalQueue;
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
                      onPressed: () => unawaited(
                        store.approveApproval(item.order.id, item.approval.id),
                      ),
                      child: const Text('Approve'),
                    ),
                    OutlinedButton(
                      onPressed: () => unawaited(
                        store.holdOrder(item.order.id, note: item.approval.note),
                      ),
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

  Widget _buildChannels(AutoCompanyStore store) {
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
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<CommandChannel>(
                          initialValue: _channel,
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commandController,
                          decoration: const InputDecoration(
                            hintText: '/new_order title | objective | product | branch',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () async {
                          final input = _commandController.text.trim();
                          if (input.isEmpty) {
                            return;
                          }
                          await store.submitCommand(_channel, input);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Command dispatched'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Run'),
                      ),
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
                        onTap: () => _commandController.text = '/approve WO-101',
                      ),
                      _SuggestionChip(
                        label: '/status WO-101',
                        onTap: () => _commandController.text = '/status WO-101',
                      ),
                    ],
                  ),
                ],
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
            subtitle: Text('${entry.orderId} · ${_formatDateTime(entry.createdAt)}'),
          ),
        );
      },
    );
  }

  Future<void> _openCreateOrderDialog() async {
    final titleController = TextEditingController();
    final objectiveController = TextEditingController();
    final requesterController = TextEditingController(text: 'HNI CEO');
    final branchController = TextEditingController(text: 'main');
    final productController = TextEditingController(text: 'Mozzy');
    String squad = 'Feature Delivery';
    final risk = RiskProfile();

    await showDialog<void>(
      context: context,
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
                        decoration: const InputDecoration(labelText: 'Objective'),
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
                          setDialogState(() => risk.scopeExpansion = value ?? false);
                        },
                        title: const Text('Scope expansion'),
                      ),
                      CheckboxListTile(
                        value: risk.production,
                        onChanged: (value) {
                          setDialogState(() => risk.production = value ?? false);
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
                          setDialogState(() => risk.destructive = value ?? false);
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
                    setState(() => _section = AppSection.orders);
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
  const _NavigationSidebar({
    required this.selected,
    required this.onSelect,
  });

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
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF115E59),
          ],
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
        unselectedIconTheme: const IconThemeData(
          color: Color(0xFFD1D5DB),
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Color(0xFFD1D5DB),
        ),
        onDestinationSelected: (index) => onSelect(AppSection.values[index]),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: Text('Home'),
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
    required this.section,
    required this.onNewOrder,
  });

  final AutoCompanyStore store;
  final AppSection section;
  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: Row(
        children: [
          Text(
            switch (section) {
              AppSection.home => 'Executive Home',
              AppSection.orders => 'Work Orders',
              AppSection.reports => 'Reports',
              AppSection.approvals => 'Approval Gates',
              AppSection.channels => 'Channel Center',
              AppSection.audit => 'Audit Timeline',
            },
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          _StatusPill(
            label: store.modeLabel,
            color: store.isRemoteMode
                ? const Color(0xFF1D4ED8)
                : const Color(0xFF475569),
          ),
          const SizedBox(width: 8),
          _StatusPill(
            label: store.backendStatusLabel,
            color: store.isRemoteMode
                ? const Color(0xFF0891B2)
                : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          _StatusPill(
            label: 'Auto Runs ${store.activeRunCount}',
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(width: 8),
          _StatusPill(
            label: 'Pending ${store.pendingApprovalCount}',
            color: const Color(0xFFB45309),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onNewOrder,
            icon: const Icon(Icons.add),
            label: const Text('New Work Order'),
          ),
        ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: child,
      ),
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
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: accent,
                  fontSize: 34,
                ),
          ),
          const SizedBox(height: 8),
          Text(caption),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.child,
  });

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
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            child,
          ],
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
  final VoidCallback onApprovePlan;
  final VoidCallback onApproveRisk;
  final VoidCallback onHold;
  final VoidCallback onResume;

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
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 34,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: order.id,
                color: const Color(0xFF0F766E),
              ),
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
                  (item) => _StatusPill(
                    label: item,
                    color: const Color(0xFFB45309),
                  ),
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
              OutlinedButton(
                onPressed: onHold,
                child: const Text('Hold'),
              ),
              OutlinedButton(
                onPressed: onResume,
                child: const Text('Resume'),
              ),
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
                  ...order.reports.reversed.map((report) => _ReportTile(report: report)),
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
  const _StatusPill({
    required this.label,
    required this.color,
  });

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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  const _StagePill({
    required this.label,
    required this.tone,
  });

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
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
    );
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

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
