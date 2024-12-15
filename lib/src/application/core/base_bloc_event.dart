
import 'package:map_assignment/src/application/core/process_state.dart';

abstract class BaseBlocEvent {
  ProcessState processState = ProcessState.initial();
}
