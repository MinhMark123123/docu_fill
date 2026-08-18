class Optional<T> {
  final T? _value;

  const Optional._(this._value);

  const Optional.empty() : _value = null;

  const Optional.of(T value) : _value = value;

  bool get hasValue => _value != null;

  bool get isEmpty => _value == null;

  T? get value => _value;

  T getOrElse(T fallback) => _value ?? fallback;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Optional<T> && other._value == _value);

  @override
  int get hashCode => _value.hashCode;
}
