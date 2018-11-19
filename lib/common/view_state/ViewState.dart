abstract class ViewState<T> {}

class DataState<T> extends ViewState<T> {
  DataState(this.data);
  final T data;
  static DataState<T> create<T>(T data) => DataState(data);
}

class LoadingState<T> extends ViewState<T> {}

class ErrorState<T> extends ViewState<T> {}
