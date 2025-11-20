import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_logger.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogger.debug('🟢 Created: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.info(
      '🔄 ${bloc.runtimeType} State: ${change.currentState} => ${change.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.error('🔴 ${bloc.runtimeType} Error: $error');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    AppLogger.debug('⚫ Closed: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    // _logger.i('🔷 Event in ${bloc.runtimeType}: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // _logger.d('Transition in ${bloc.runtimeType}: $transition');
  }
}
