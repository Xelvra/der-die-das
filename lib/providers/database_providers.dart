import 'package:der_die_das/repositories/progress_repository.dart';
import 'package:der_die_das/repositories/vocabulary_repository.dart';
import 'package:der_die_das/services/user_database_service.dart';
import 'package:der_die_das/services/vocabulary_database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Vocabulary Service Provider
final vocabularyDatabaseServiceProvider =
    Provider<VocabularyDatabaseService>((ref) {
  return VocabularyDatabaseService();
});

// User Database Service Provider
final userDatabaseServiceProvider = Provider<UserDatabaseService>((ref) {
  return UserDatabaseService();
});

// Vocabulary Repository (Depends on VocabularyDatabaseService)
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  final vocabService = ref.watch(vocabularyDatabaseServiceProvider);
  return VocabularyRepository(vocabService);
});

// Progress Repository (Depends on UserDatabaseService and VocabularyDatabaseService)
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final userService = ref.watch(userDatabaseServiceProvider);
  final vocabService = ref.watch(vocabularyDatabaseServiceProvider);
  return ProgressRepository(userService, vocabService);
});
