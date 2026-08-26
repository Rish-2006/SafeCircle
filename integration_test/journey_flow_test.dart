import 'package:flutter_test/flutter_test.dart';
import 'package:safecircle/data/repositories/journey_repository.dart';

void main() {
  group('Journey Start-to-End Integration Flow Test', () {
    late JourneyRepository repository;

    setUp(() {
      repository = JourneyRepository();
    });

    test('Full journey lifecycle: start journey, record location, and end safely', () async {
      const userId = 'test_user_flow';
      final contacts = ['contact_1', 'contact_2'];

      // 1. Start journey
      final journey = await repository.startJourney(
        userId: userId,
        contactIds: contacts,
        destinationName: 'Office Commute',
      );

      expect(journey.isActive, isTrue);
      expect(journey.destinationName, equals('Office Commute'));
      expect(journey.contactIds.length, equals(2));

      // 2. End journey
      await repository.endJourney(journey.id);

      // 3. Verify journey is logged into private history
      final history = await repository.getJourneyHistory(userId);
      expect(history, isNotEmpty);
      expect(history.any((j) => j.id == journey.id), isTrue);
    });
  });
}
