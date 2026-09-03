enum StepItemState {
  completed,
  current,
  upcoming;

  static StepItemState fromIndex({
    required int index,
    required int currentIndex,
  }) => switch (index.compareTo(currentIndex)) {
    -1 => StepItemState.completed,
    0 => StepItemState.current,
    _ => StepItemState.upcoming,
  };
}
