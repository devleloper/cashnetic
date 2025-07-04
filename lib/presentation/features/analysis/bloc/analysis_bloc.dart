import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/repositories/analysis_repository.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';
import 'package:cashnetic/di/di.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final AnalysisRepository analysisRepository = getIt<AnalysisRepository>();

  AnalysisBloc() : super(AnalysisLoading()) {
    on<LoadAnalysis>(_onLoadAnalysis);
    on<ChangeYear>(_onChangeYear);
    on<ChangeYears>(_onChangeYears);
    on<ChangePeriod>(_onChangePeriod);
  }

  Future<void> _onLoadAnalysis(
    LoadAnalysis event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisLoading());
    try {
      final result = await analysisRepository.getAnalysisForYear(
        event.year,
        event.type,
      );
      final availableYears = await analysisRepository.getAllAvailableYears(
        event.type,
      );
      emit(
        AnalysisLoaded(
          result: result,
          selectedYear: event.year,
          selectedYears: [event.year],
          availableYears: availableYears.isEmpty
              ? [event.year]
              : availableYears,
        ),
      );
    } catch (e) {
      emit(AnalysisError(e.toString()));
    }
  }

  Future<void> _onChangeYear(
    ChangeYear event,
    Emitter<AnalysisState> emit,
  ) async {
    add(LoadAnalysis(year: event.year, type: event.type));
  }

  Future<void> _onChangeYears(
    ChangeYears event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisLoading());
    try {
      final result = await analysisRepository.getAnalysisForYears(
        event.years,
        event.type,
      );
      final availableYears = await analysisRepository.getAllAvailableYears(
        event.type,
      );
      emit(
        AnalysisLoaded(
          result: result,
          selectedYear: event.years.first,
          selectedYears: event.years,
          availableYears: availableYears.isEmpty ? event.years : availableYears,
        ),
      );
    } catch (e) {
      emit(AnalysisError(e.toString()));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisLoading());
    try {
      final result = await analysisRepository.getAnalysisForPeriod(
        event.from,
        event.to,
        event.type,
      );
      final availableYears = await analysisRepository.getAllAvailableYears(
        event.type,
      );
      emit(
        AnalysisLoaded(
          result: result,
          selectedYear: event.from.year,
          selectedYears: [event.from.year],
          availableYears: availableYears.isEmpty
              ? [event.from.year]
              : availableYears,
        ),
      );
    } catch (e) {
      emit(AnalysisError(e.toString()));
    }
  }
}
