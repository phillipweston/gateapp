import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fnf_guest_list/models/audit.dart';
import './audit.dart';

class AuditListBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository auditRepository;

  AuditListBloc(this.auditRepository);

  @override
  AuditState get initialState => AuditsInitial();

  @override
  Stream<AuditState> mapEventToState(AuditEvent event) async* {
    yield AuditsLoading();

    // NO SUPPORT FOR A SWITCH STATEMENT ON TYPES IN DART

    if (event is GetAudits) {
      try {
        final audits = await auditRepository.refreshAll();
        yield AuditsLoaded(audits);
      } on NetworkError {
        yield AuditsError("Couldn't fetch audits. Is the device online?");
      }
    }

    else if (event is FilterAudits) {
      try {
        print("attempting to filter audits");
        List<Audit> audits = await auditRepository.filterAudits(event.search);
        if (audits.isNotEmpty) {
          yield AuditsLoaded(audits);
        }
        else {
          yield NoAuditsMatchSearch();
        }
      } on NetworkError {
        yield AuditsError("Couldn't fetch audits. Is the device online?");
      }
    }

    else if (event is FilterAuditsByName) {
      try {
        print("attempting to filter audits");
        List<Audit> audits = await auditRepository.filterAuditsByName(
            event.search);
        if (audits.isNotEmpty) {
          yield AuditsLoaded(audits);
        }
        else {
          yield NoAuditsMatchSearch();
        }
      } on NetworkError {
        yield AuditsError("Couldn't fetch audits. Is the device online?");
      }
    }

  }
}