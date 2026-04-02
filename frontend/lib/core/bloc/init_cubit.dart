// lib/core/bloc/init_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

class InitState {
  final bool isInitialized;
  const InitState(this.isInitialized);
}

class InitCubit extends Cubit<InitState> {
  InitCubit() : super(const InitState(false));

  Future<void> initialize() async {
    // No hay delay - Firebase ya está inicializado en main()
    // Solo marcamos como inicializado inmediatamente
    emit(const InitState(true));
  }
}
