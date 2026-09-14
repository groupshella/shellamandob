import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sixam_mart/core/error/failures.dart';

abstract class BaseUseCase<T, Params> {
  dynamic get repository;
  Future<Either<Failure, T>> execute(Params params);
  Future<Either<Failure, T>> call(Params params) => execute(params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
