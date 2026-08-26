import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/journey_model.dart';
import '../models/location_point.dart';

class JourneyRepository {
  final FirebaseFirestore _firestore;
  JourneyModel? _activeMockJourney;
  final List<JourneyModel> _mockHistory = [];

  JourneyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<JourneyModel?> watchActiveJourney(String userId) {
    try {
      return _firestore
          .collection('journeys')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return JourneyModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      });
    } catch (e) {
      debugPrint('Watch active journey stream fallback: $e');
      return Stream.value(_activeMockJourney);
    }
  }

  Stream<JourneyModel?> watchJourneyById(String journeyId) {
    try {
      return _firestore
          .collection('journeys')
          .doc(journeyId)
          .snapshots()
          .map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return JourneyModel.fromMap(doc.data()!, doc.id);
      });
    } catch (e) {
      debugPrint('Watch journey by ID fallback: $e');
      if (_activeMockJourney?.id == journeyId) {
        return Stream.value(_activeMockJourney);
      }
      return Stream.value(null);
    }
  }

  Stream<List<LocationPoint>> watchJourneyLocations(String journeyId) {
    try {
      return _firestore
          .collection('journeys')
          .doc(journeyId)
          .collection('locations')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => LocationPoint.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      debugPrint('Locations stream fallback: $e');
      final loc = _activeMockJourney?.lastKnownLocation;
      return Stream.value(loc != null ? [loc] : []);
    }
  }

  Future<JourneyModel> startJourney({
    required String userId,
    required List<String> contactIds,
    String? destinationName,
    bool isPanicTriggered = false,
  }) async {
    final journeyId = const Uuid().v4();
    final now = DateTime.now();
    final journey = JourneyModel(
      id: journeyId,
      userId: userId,
      isActive: true,
      startTime: now,
      destinationName: destinationName ?? (isPanicTriggered ? 'SOS Emergency Panic' : 'Standard Journey'),
      contactIds: contactIds,
      isPanicTriggered: isPanicTriggered,
      expiresAt: now.add(const Duration(hours: 12)),
    );

    try {
      await _firestore.collection('journeys').doc(journeyId).set(journey.toMap());
    } catch (e) {
      debugPrint('Start journey fallback: $e');
      _activeMockJourney = journey;
    }
    return journey;
  }

  Future<void> updateLocation({
    required String journeyId,
    required LocationPoint location,
  }) async {
    try {
      await _firestore
          .collection('journeys')
          .doc(journeyId)
          .collection('locations')
          .add(location.toMap());

      await _firestore.collection('journeys').doc(journeyId).update({
        'lastKnownLocation': location.toMap(),
      });
    } catch (e) {
      debugPrint('Update location fallback: $e');
      if (_activeMockJourney?.id == journeyId) {
        _activeMockJourney = _activeMockJourney!.copyWith(
          lastKnownLocation: location,
        );
      }
    }
  }

  Future<void> endJourney(String journeyId) async {
    final now = DateTime.now();
    try {
      await _firestore.collection('journeys').doc(journeyId).update({
        'isActive': false,
        'endTime': now.toIso8601String(),
      });
    } catch (e) {
      debugPrint('End journey fallback: $e');
      if (_activeMockJourney?.id == journeyId) {
        final ended = _activeMockJourney!.copyWith(
          isActive: false,
          endTime: now,
        );
        _mockHistory.add(ended);
        _activeMockJourney = null;
      }
    }
  }

  Future<void> setBatteryAlerted(String journeyId) async {
    try {
      await _firestore.collection('journeys').doc(journeyId).update({
        'isBatteryAlerted': true,
      });
    } catch (e) {
      debugPrint('Set battery alert fallback: $e');
      if (_activeMockJourney?.id == journeyId) {
        _activeMockJourney = _activeMockJourney!.copyWith(isBatteryAlerted: true);
      }
    }
  }

  Future<List<JourneyModel>> getJourneyHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('journeys')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) => JourneyModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Get history fallback: $e');
      return _mockHistory;
    }
  }
}
