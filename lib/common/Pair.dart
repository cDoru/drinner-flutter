class Pair<S, R> {
  const Pair(this.first, this.second);
  final S first;
  final R second;
}

class Twin<S> extends Pair<S, S> {
  const Twin(S first, S second) : super(first, second);
  static Twin<S> create<S>(S first, S second) => Twin(first, second);
}
