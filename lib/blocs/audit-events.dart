import 'package:equatable/equatable.dart';

abstract class AuditEvent extends Equatable {
  const AuditEvent();
}

class GetAudits extends AuditEvent {
  const GetAudits();
  @override
  List<Object> get props => [];
}
//
class FilterAudits extends AuditEvent {
  final String search;
  const FilterAudits(this.search);
  @override
  List<Object> get props => [search];
}

class FilterAuditsByName extends AuditEvent {
  final String search;
  const FilterAuditsByName(this.search);
  @override
  List<Object> get props => [search];
}
