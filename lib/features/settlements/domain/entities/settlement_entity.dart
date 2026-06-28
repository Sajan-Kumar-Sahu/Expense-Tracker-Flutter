import 'package:equatable/equatable.dart';

class SettlementEntity extends Equatable {
  final String id;
  final String userId;
  final String contactId;
  final String contactName;

  /// 1=Receivable (they owe you), 2=Payable (you owe them)
  final int settlementType;
  final String reason;
  final double originalAmount;
  final double pendingAmount;

  /// 1=Pending, 2=Partial, 3=Completed, 4=Cancelled
  final int status;
  final DateTime? dueDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  const SettlementEntity({
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

  bool get isReceivable => settlementType == 1;
  bool get isPayable => settlementType == 2;

  bool get isPending => status == 1;
  bool get isPartial => status == 2;
  bool get isCompleted => status == 3;
  bool get isCancelled => status == 4;

  double get paidAmount => originalAmount - pendingAmount;

  String get statusName {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Partial';
      case 3:
        return 'Completed';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get typeName => isReceivable ? 'Receivable' : 'Payable';

  @override
  List<Object?> get props => [
        id,
        userId,
        contactId,
        contactName,
        settlementType,
        reason,
        originalAmount,
        pendingAmount,
        status,
        dueDate,
        isActive,
        notes,
        createdAt,
      ];
}

class SettlementSummaryEntity extends Equatable {
  final double totalReceivable;
  final double totalPayable;
  final int pendingReceivableCount;
  final int pendingPayableCount;
  final int completedSettlementCount;

  const SettlementSummaryEntity({
    required this.totalReceivable,
    required this.totalPayable,
    required this.pendingReceivableCount,
    required this.pendingPayableCount,
    required this.completedSettlementCount,
  });

  double get netBalance => totalReceivable - totalPayable;

  @override
  List<Object?> get props => [
        totalReceivable,
        totalPayable,
        pendingReceivableCount,
        pendingPayableCount,
        completedSettlementCount,
      ];
}
