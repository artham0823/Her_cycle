import 'dart:async';
import 'package:flutter/material.dart';
import '../models/period_model.dart';
import '../services/firestore_service.dart';
import '../services/cycle_service.dart';

class PeriodProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<PeriodModel> _periods = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<PeriodModel> get periods => _periods;
  bool get isLoading => _isLoading;

  int get averageCycleLength => CycleService.calculateAverageCycleLength(_periods);

  DateTime? get nextPeriodDate => CycleService.predictNextPeriod(_periods);

  CyclePhase get currentPhase =>
      CycleService.getCurrentPhase(_periods, DateTime.now());

  int get dayOfCycle =>
      CycleService.getDayOfCycle(_periods, DateTime.now());

  void listenToPeriods(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.getPeriods(userId).listen((periods) {
      _periods = periods;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addPeriod(String userId, DateTime startDate) async {
    final period = PeriodModel(
      id: '',
      userId: userId,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      createdAt: DateTime.now(),
    );
    await _firestoreService.addPeriod(period);
  }

  Future<void> deletePeriod(String userId, String periodId) async {
    await _firestoreService.deletePeriod(userId, periodId);
  }

  bool isMenstrualDay(DateTime date) =>
      CycleService.isMenstrualDay(_periods, date);

  bool isFertileDay(DateTime date) =>
      CycleService.isFertileDay(_periods, date);

  bool isPredictedDay(DateTime date) =>
      CycleService.isPredictedDay(_periods, date);

  CyclePhase getPhaseForDate(DateTime date) =>
      CycleService.getCurrentPhase(_periods, date);

  int getDayOfCycleForDate(DateTime date) =>
      CycleService.getDayOfCycle(_periods, date);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
