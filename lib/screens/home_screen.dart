import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _brandGreen = Color(0xFF0F8B48);
  static const Color _brandGold = Color(0xFFE8B400);
  static const Color _brandNavy = Color(0xFF0A1F3B);
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  int _year = DateTime.now().year;
  String _month = _months[DateTime.now().month - 1];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final att = context.read<AttendanceProvider>();
    if (!auth.isAuthenticated || (auth.user?.empCode == null && (auth.user?.email == null || auth.user!.email.isEmpty))) {
      await att.refresh(token: auth.token ?? '', email: null, empCode: null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in again')));
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final i = _months.indexOf(_month) + 1;
    final from = DateTime(_year, i, 1);
    final to = DateTime(_year, i + 1, 0, 23, 59, 59);
    await att.refresh(
      token: auth.token ?? '',
      email: auth.user?.email,
      empCode: auth.user?.empCode,
      from: from,
      to: to,
    );
  }

  @override
  Widget build(BuildContext context) {
    final att = context.watch<AttendanceProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 96,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            gradient: LinearGradient(
              colors: [_brandGreen, _brandNavy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E4B63), Color(0xFF0E2534)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.35),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset('assets/assets/images/logo.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ST. FRANCIS XAVIER COLLEGE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))
                          ],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SAN FRANCISCO • AGUSAN DEL SUR',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 2.2,
                          color: const Color(0xFFE8F1FA),
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))
                          ],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_greeting()}, ${_displayName(auth)}!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))
                          ],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1F3B), Color(0xFF0F8B48)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MonthSelector(
                months: _months,
                month: _month,
                year: _year,
                onMonthChanged: (value) async {
                  setState(() => _month = value);
                  await _load();
                },
                onYearChanged: (value) async {
                  setState(() => _year = value);
                  await _load();
                },
              ),
              const SizedBox(height: 16),
              if (att.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(att.error!, style: const TextStyle(color: Colors.red)),
                ),
              _TodayCard(records: att.records),
              const SizedBox(height: 16),
              _StatsRow(records: att.records),
              const SizedBox(height: 12),
              _DailyFeed(records: att.records),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good morning';
    if (h >= 12 && h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _displayName(AuthProvider auth) {
    final u = auth.user;
    if (u == null) return 'there';
    if (u.name.isNotEmpty) return u.name;
    if (u.email.isNotEmpty) return u.email.split('@').first;
    return u.empCode ?? 'there';
  }
}

class _MonthSelector extends StatelessWidget {
  final List<String> months;
  final String month;
  final int year;
  final ValueChanged<String> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const _MonthSelector({
    required this.months,
    required this.month,
    required this.year,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: month,
              decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
              items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) {
                if (v != null) onMonthChanged(v);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: year,
              decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
              items: List.generate(6, (k) {
                final y = DateTime.now().year - 5 + k;
                return DropdownMenuItem(value: y, child: Text('$y'));
              }),
              onChanged: (v) {
                if (v != null) onYearChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final List<AttendanceRecord> records;
  const _TodayCard({required this.records});

  AttendanceRecord? _todayRecord() {
    final now = DateTime.now();
    for (final r in records) {
      if (r.checkInTime.year == now.year &&
          r.checkInTime.month == now.month &&
          r.checkInTime.day == now.day) {
        return r;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayRecord();
    final f = DateFormat('hh:mm a');
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: today == null
          ? Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No attendance recorded today',
                    style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF2E7D32)),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                'Today - ${DateFormat("EEE, MMM d").format(DateTime.now())}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    _StatusChip(status: today.status),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.login,
                  label: 'Check-in',
                  value: today.status.toLowerCase() == 'absent' ? '--' : f.format(today.checkInTime),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.logout,
                  label: 'Check-out',
                  value: today.checkOutTime != null ? f.format(today.checkOutTime!) : '--',
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Correction request coming soon')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E8449),
                    side: const BorderSide(color: Color(0xFF1E8449)),
                  ),
                  child: const Text('Request Correction'),
                ),
              ],
            ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<AttendanceRecord> records;
  const _StatsRow({required this.records});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final r in records) {
      final key = r.status.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final chips = [
      _StatChip(label: 'Present', count: counts['present'] ?? 0, color: const Color(0xFF2ECC71)),
      _StatChip(label: 'Half Day', count: counts['half day'] ?? 0, color: const Color(0xFFF1C40F)),
      _StatChip(label: 'Absent', count: counts['absent'] ?? 0, color: const Color(0xFFE74C3C)),
      _StatChip(label: 'Late', count: counts['late'] ?? 0, color: const Color(0xFFFF7043)),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: chips,
    );
  }
}

class _DailyFeed extends StatelessWidget {
  final List<AttendanceRecord> records;
  const _DailyFeed({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No attendance records found'),
      );
    }
    final sorted = [...records]..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return Column(
      children: sorted.map((r) => _DayCard(record: r)).toList(),
    );
  }
}

class _DayCard extends StatelessWidget {
  final AttendanceRecord record;
  const _DayCard({required this.record});

  Color _color(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const Color(0xFF2ECC71);
      case 'half day':
        return const Color(0xFFF1C40F);
      case 'absent':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF5D6D7E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, MMM dd').format(record.checkInTime);
    final timeFormat = DateFormat('hh:mm a');
    final statusColor = _color(record.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _StatusChip(status: record.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.login,
            label: 'Check-in',
            value: record.status.toLowerCase() == 'absent'
                ? '--'
                : timeFormat.format(record.checkInTime),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.logout,
            label: 'Check-out',
            value: record.checkOutTime != null ? timeFormat.format(record.checkOutTime!) : '--',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color? color;
  const _StatusChip({required this.status, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF1E8449);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label - $count'),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}






