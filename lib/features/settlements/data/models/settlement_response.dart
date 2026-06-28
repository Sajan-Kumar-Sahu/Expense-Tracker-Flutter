import '../../domain/entities/settlement_entity.dart';

class SettlementResponse {
  final String id;
  final String userId;
  final String contactId;
  final String contactName;
  final int settlementType;
  final String reason;
  final double originalAmount;
  final double pendingAmount;
  final int status;
  final DateTime? dueDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  SettlementResponse({
    required this.id,
    required this.userId,
    required this.contactId,
    required this.contactName,
    required this.settlementType,
    required this.reason,
    required this.originalAmount,
    required this.pendingAmount,
    required this.status,
    this.dueDate,
    required this.isActive,
    this.notes,
    required this.createdAt,
  });

  factory SettlementResponse.fromJson(Map<String, dynamic> json) {
    return SettlementResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contactId: json['contactId'] as String,
      contactName: json['contactName'] as String? ?? '',
      settlementType: json['settlementType'] as int,
      reason: json['reason'] as String,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      status: json['status'] as int,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  SettlementEntity toEntity() {
    return SettlementEntity(
      id: id,
      userId: userId,
      contactId: contactId,
      contactName: contactName,
      settlementType: settlementType,
      reason: reason,
      originalAmount: originalAmount,
      pendingAmount: pendingAmount,
      status: status,
      dueDate: dueDate,
      isActive: isActive,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

class SettlementListResponse {
  final String id;
  final String contactId;
  final String contactName;
  final int settlementType;
  final String reason;
  final double originalAmount;
  final double pendingAmount;
  final int status;
  final DateTime? dueDate;
  final DateTime createdAt;

  SettlementListResponse({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.settlementType,
    required this.reason,
    required this.originalAmount,
    required this.pendingAmount,
    required this.status,
    this.dueDate,
    required this.createdAt,
  });

  factory SettlementListResponse.fromJson(Map<String, dynamic> json) {
    return SettlementListResponse(
      id: json['id'] as String,
      contactId: json['contactId'] as String,
      contactName: json['contactName'] as String? ?? '',
      settlementType: json['settlementType'] as int,
      reason: json['reason'] as String,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      status: json['status'] as int,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  SettlementEntity toEntity() {
    return SettlementEntity(
      id: id,
      userId: '',
      contactId: contactId,
      contactName: contactName,
      settlementType: settlementType,
      reason: reason,
      originalAmount: originalAmount,
      pendingAmount: pendingAmount,
      status: status,
      dueDate: dueDate,
      isActive: true,
      createdAt: createdAt,
    );
  }
}

class SettlementSummaryResponse {
  final double totalReceivable;
  final double totalPayable;
  final int pendingReceivableCount;
  final int pendingPayableCount;
  final int completedSettlementCount;

  SettlementSummaryResponse({
    required this.totalReceivable,
    required this.totalPayable,
    required this.pendingReceivableCount,
    required this.pendingPayableCount,
    required this.completedSettlementCount,
  });

  factory SettlementSummaryResponse.fromJson(Map<String, dynamic> json) {
    return SettlementSummaryResponse(
      totalReceivable: (json['totalReceivable'] as num).toDouble(),
      totalPayable: (json['totalPayable'] as num).toDouble(),
      pendingReceivableCount: json['pendingReceivableCount'] as int,
      pendingPayableCount: json['pendingPayableCount'] as int,
      completedSettlementCount: json['completedSettlementCount'] as int,
    );
  }

  SettlementSummaryEntity toEntity() {
    return SettlementSummaryEntity(
      totalReceivable: totalReceivable,
      totalPayable: totalPayable,
      pendingReceivableCount: pendingReceivableCount,
      pendingPayableCount: pendingPayableCount,
      completedSettlementCount: completedSettlementCount,
    );
  }
}
