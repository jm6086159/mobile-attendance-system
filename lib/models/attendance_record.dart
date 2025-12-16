class AttendanceRecord {
  final String id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
        id: (j['id'] ?? '').toString(),
        // Convert to local so UI always shows device-local time
        checkInTime: DateTime.parse(j['checkInTime']).toLocal(),
        checkOutTime: j['checkOutTime'] != null
            ? DateTime.parse(j['checkOutTime']).toLocal()
            : null,
        status: j['status'] ?? 'Present',
      );
}
