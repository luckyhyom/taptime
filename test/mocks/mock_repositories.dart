import 'package:mocktail/mocktail.dart';

import 'package:taptime/shared/repositories/active_timer_repository.dart';
import 'package:taptime/shared/repositories/preset_repository.dart';
import 'package:taptime/shared/repositories/session_repository.dart';
import 'package:taptime/shared/repositories/user_settings_repository.dart';

class MockPresetRepository extends Mock implements PresetRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

class MockActiveTimerRepository extends Mock implements ActiveTimerRepository {}

class MockUserSettingsRepository extends Mock implements UserSettingsRepository {}
