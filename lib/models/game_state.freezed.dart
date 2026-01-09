// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameState {
  List<Word> get words;
  int get currentIndex;
  bool get isLoading;
  GameMode get gameMode;
  GameMode get selectedLevel;
  double get remainingTime;
  double get maxTime;
  int get score;
  bool get isGameOver;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameStateCopyWith<GameState> get copyWith =>
      _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameState &&
            const DeepCollectionEquality().equals(other.words, words) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.gameMode, gameMode) ||
                other.gameMode == gameMode) &&
            (identical(other.selectedLevel, selectedLevel) ||
                other.selectedLevel == selectedLevel) &&
            (identical(other.remainingTime, remainingTime) ||
                other.remainingTime == remainingTime) &&
            (identical(other.maxTime, maxTime) || other.maxTime == maxTime) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.isGameOver, isGameOver) ||
                other.isGameOver == isGameOver));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(words),
      currentIndex,
      isLoading,
      gameMode,
      selectedLevel,
      remainingTime,
      maxTime,
      score,
      isGameOver);

  @override
  String toString() {
    return 'GameState(words: $words, currentIndex: $currentIndex, isLoading: $isLoading, gameMode: $gameMode, selectedLevel: $selectedLevel, remainingTime: $remainingTime, maxTime: $maxTime, score: $score, isGameOver: $isGameOver)';
  }
}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) =
      _$GameStateCopyWithImpl;
  @useResult
  $Res call(
      {List<Word> words,
      int currentIndex,
      bool isLoading,
      GameMode gameMode,
      GameMode selectedLevel,
      double remainingTime,
      double maxTime,
      int score,
      bool isGameOver});
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res> implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? words = null,
    Object? currentIndex = null,
    Object? isLoading = null,
    Object? gameMode = null,
    Object? selectedLevel = null,
    Object? remainingTime = null,
    Object? maxTime = null,
    Object? score = null,
    Object? isGameOver = null,
  }) {
    return _then(_self.copyWith(
      words: null == words
          ? _self.words
          : words // ignore: cast_nullable_to_non_nullable
              as List<Word>,
      currentIndex: null == currentIndex
          ? _self.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      gameMode: null == gameMode
          ? _self.gameMode
          : gameMode // ignore: cast_nullable_to_non_nullable
              as GameMode,
      selectedLevel: null == selectedLevel
          ? _self.selectedLevel
          : selectedLevel // ignore: cast_nullable_to_non_nullable
              as GameMode,
      remainingTime: null == remainingTime
          ? _self.remainingTime
          : remainingTime // ignore: cast_nullable_to_non_nullable
              as double,
      maxTime: null == maxTime
          ? _self.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as double,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      isGameOver: null == isGameOver
          ? _self.isGameOver
          : isGameOver // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GameState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GameState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GameState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<Word> words,
            int currentIndex,
            bool isLoading,
            GameMode gameMode,
            GameMode selectedLevel,
            double remainingTime,
            double maxTime,
            int score,
            bool isGameOver)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(
            _that.words,
            _that.currentIndex,
            _that.isLoading,
            _that.gameMode,
            _that.selectedLevel,
            _that.remainingTime,
            _that.maxTime,
            _that.score,
            _that.isGameOver);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<Word> words,
            int currentIndex,
            bool isLoading,
            GameMode gameMode,
            GameMode selectedLevel,
            double remainingTime,
            double maxTime,
            int score,
            bool isGameOver)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState():
        return $default(
            _that.words,
            _that.currentIndex,
            _that.isLoading,
            _that.gameMode,
            _that.selectedLevel,
            _that.remainingTime,
            _that.maxTime,
            _that.score,
            _that.isGameOver);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<Word> words,
            int currentIndex,
            bool isLoading,
            GameMode gameMode,
            GameMode selectedLevel,
            double remainingTime,
            double maxTime,
            int score,
            bool isGameOver)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(
            _that.words,
            _that.currentIndex,
            _that.isLoading,
            _that.gameMode,
            _that.selectedLevel,
            _that.remainingTime,
            _that.maxTime,
            _that.score,
            _that.isGameOver);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GameState extends GameState {
  const _GameState(
      {final List<Word> words = const [],
      this.currentIndex = 0,
      this.isLoading = true,
      this.gameMode = GameMode.a1,
      this.selectedLevel = GameMode.a1,
      this.remainingTime = 60.0,
      this.maxTime = 60.0,
      this.score = 0,
      this.isGameOver = false})
      : _words = words,
        super._();

  final List<Word> _words;
  @override
  @JsonKey()
  List<Word> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  @override
  @JsonKey()
  final int currentIndex;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final GameMode gameMode;
  @override
  @JsonKey()
  final GameMode selectedLevel;
  @override
  @JsonKey()
  final double remainingTime;
  @override
  @JsonKey()
  final double maxTime;
  @override
  @JsonKey()
  final int score;
  @override
  @JsonKey()
  final bool isGameOver;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameStateCopyWith<_GameState> get copyWith =>
      __$GameStateCopyWithImpl<_GameState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GameState &&
            const DeepCollectionEquality().equals(other._words, _words) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.gameMode, gameMode) ||
                other.gameMode == gameMode) &&
            (identical(other.selectedLevel, selectedLevel) ||
                other.selectedLevel == selectedLevel) &&
            (identical(other.remainingTime, remainingTime) ||
                other.remainingTime == remainingTime) &&
            (identical(other.maxTime, maxTime) || other.maxTime == maxTime) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.isGameOver, isGameOver) ||
                other.isGameOver == isGameOver));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_words),
      currentIndex,
      isLoading,
      gameMode,
      selectedLevel,
      remainingTime,
      maxTime,
      score,
      isGameOver);

  @override
  String toString() {
    return 'GameState(words: $words, currentIndex: $currentIndex, isLoading: $isLoading, gameMode: $gameMode, selectedLevel: $selectedLevel, remainingTime: $remainingTime, maxTime: $maxTime, score: $score, isGameOver: $isGameOver)';
  }
}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(
          _GameState value, $Res Function(_GameState) _then) =
      __$GameStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<Word> words,
      int currentIndex,
      bool isLoading,
      GameMode gameMode,
      GameMode selectedLevel,
      double remainingTime,
      double maxTime,
      int score,
      bool isGameOver});
}

/// @nodoc
class __$GameStateCopyWithImpl<$Res> implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? words = null,
    Object? currentIndex = null,
    Object? isLoading = null,
    Object? gameMode = null,
    Object? selectedLevel = null,
    Object? remainingTime = null,
    Object? maxTime = null,
    Object? score = null,
    Object? isGameOver = null,
  }) {
    return _then(_GameState(
      words: null == words
          ? _self._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<Word>,
      currentIndex: null == currentIndex
          ? _self.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      gameMode: null == gameMode
          ? _self.gameMode
          : gameMode // ignore: cast_nullable_to_non_nullable
              as GameMode,
      selectedLevel: null == selectedLevel
          ? _self.selectedLevel
          : selectedLevel // ignore: cast_nullable_to_non_nullable
              as GameMode,
      remainingTime: null == remainingTime
          ? _self.remainingTime
          : remainingTime // ignore: cast_nullable_to_non_nullable
              as double,
      maxTime: null == maxTime
          ? _self.maxTime
          : maxTime // ignore: cast_nullable_to_non_nullable
              as double,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      isGameOver: null == isGameOver
          ? _self.isGameOver
          : isGameOver // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
