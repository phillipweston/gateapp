import 'package:equatable/equatable.dart';
import 'package:fnf_guest_list/models/audit.dart';

abstract class AuditState extends Equatable {
  const AuditState();
}

class AuditsInitial extends AuditState {
  const AuditsInitial();
  @override
  List<Object> get props => [];
}

class AuditsLoading extends AuditState {
  const AuditsLoading();
  @override
  List<Object> get props => [];
}

class AuditsLoaded extends AuditState {
  final List<Audit> audits;
  const AuditsLoaded(this.audits);
  @override
  List<Object> get props => [audits];
}

class NoAuditsMatchSearch extends AuditState {
  const NoAuditsMatchSearch();
  @override
  List<Object> get props => [];
}

class AuditsError extends AuditState {
  final String message;
  const AuditsError(this.message);
  @override
  List<Object> get props => [message];
}
