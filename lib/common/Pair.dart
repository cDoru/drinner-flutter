class Pair<S, R> {
  const Pair(this.first, this.second);
  static Pair<S, R> create<S, R>(S first, R second) => Pair(first, second);
  final S first;
  final R second;
}

class Twin<S> extends Pair<S, S> {
  const Twin(S first, S second) : super(first, second);
}
