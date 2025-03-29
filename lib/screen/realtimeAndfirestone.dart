import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DataBridgeService {
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref('drivers');
  final CollectionReference _firestore =
      FirebaseFirestore.instance.collection('driver_alerts');
  final Map<String, StreamSubscription> _subscriptions = {};

  void startMonitoring() {
    _cancelSubscriptions();
    _rtdb.onChildAdded.listen((driverSnapshot) async {
      final driverId = driverSnapshot.snapshot.key;
      if (driverId == null) return;

      final driverDataRef = _rtdb.child('$driverId/sensors');

      _subscriptions[driverId] =
          driverDataRef.onValue.listen((dataSnapshot) async {
        try {
          final data = dataSnapshot.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null && data.isNotEmpty) {
            await _processDriverData(driverId, data);
          }
        } catch (e) {
          debugPrint('Error processing driver $driverId data: $e');
          await _logError(driverId, e.toString());
        }
      });
    });
  }

  Future<void> _processDriverData(
      String driverId, Map<dynamic, dynamic> data) async {
    // Handle fuel sensor first as it's most critical
    final fuelSensor = data['lock_sensor'] as bool? ?? true;

    if (!fuelSensor) {
      await _handleFuelAlert(driverId, data);
    } else {
      await _resolveFuelAlerts(driverId);
    }

    // Then handle other conditions
    await _checkOtherConditions(driverId, data);
  }

  Future<void> _handleFuelAlert(
      String driverId, Map<dynamic, dynamic> data) async {
    final existingAlert = await _firestore
        .where('driver_id', isEqualTo: driverId)
        .where('type', isEqualTo: 'fuel_sensor')
        .where('resolved', isEqualTo: false)
        .limit(1)
        .get();

    if (existingAlert.docs.isEmpty) {
      await _firestore.add({
        'driver_id': driverId,
        'message': 'Fuel sensor is open',
        'type': 'fuel_sensor',
        'severity': 'critical',
        'resolved': false,
        'first_occurrence': FieldValue.serverTimestamp(),
        'last_occurrence': FieldValue.serverTimestamp(),
        'sensor_data': data,
        'timestamp': FieldValue.serverTimestamp()
      });
      debugPrint('Created new fuel alert for driver: $driverId');
    } else {
      final alertId = existingAlert.docs.first.id;
      await _firestore.doc(alertId).update({
        'last_occurrence': FieldValue.serverTimestamp(),
        'sensor_data': data,
      });
      debugPrint('Updated existing fuel alert for driver: $driverId');
    }
  }

  Future<void> _resolveFuelAlerts(String driverId) async {
    try {
      final alerts = await _firestore
          .where('driver_id', isEqualTo: driverId)
          .where('type', isEqualTo: 'fuel_sensor')
          .where('resolved', isEqualTo: false)
          .get();

      if (alerts.docs.isNotEmpty) {
        final batch = _firestore.firestore.batch();
        for (final doc in alerts.docs) {
          batch.update(doc.reference, {
            'resolved': true,
            'resolvedAt': FieldValue.serverTimestamp(),
            'resolution_note':
                'Automatically resolved when sensor returned to normal'
          });
        }
        await batch.commit();
        debugPrint('Resolved all fuel alerts for driver: $driverId');
      }
    } catch (e) {
      debugPrint('Error resolving fuel alerts: $e');
      await _logError(driverId, 'Resolve fuel alerts error: $e');
    }
  }

  Future<void> _checkOtherConditions(
      String driverId, Map<dynamic, dynamic> data) async {
    // Temperature check
    final temperature = (data['temperature'] as num?)?.toDouble() ?? 0;
    if (temperature > 40) {
      await _createConditionAlert(
          driverId,
          'high_temperature',
          'High temperature: ${temperature.toStringAsFixed(1)}°C',
          'high',
          data);
    }

    // Fuel level check
    final fuelLevel = (data['fuel_level'] as num?)?.toDouble() ?? 0;
    if (fuelLevel < 20) {
      await _createConditionAlert(driverId, 'low_fuel',
          'Low fuel level: ${fuelLevel.toStringAsFixed(1)}%', 'medium', data);
    }
  }

  Future<void> _createConditionAlert(String driverId, String type,
      String message, String severity, Map<dynamic, dynamic> sensorData) async {
    final existingAlert = await _firestore
        .where('driver_id', isEqualTo: driverId)
        .where('type', isEqualTo: type)
        .where('resolved', isEqualTo: false)
        .limit(1)
        .get();

    if (existingAlert.docs.isEmpty) {
      await _firestore.add({
        'driver_id': driverId,
        'type': type,
        'message': message,
        'severity': severity,
        'resolved': false,
        'first_occurrence': FieldValue.serverTimestamp(),
        'sensor_data': sensorData,
        'timestamp': FieldValue.serverTimestamp()
      });
      debugPrint('Created new $type alert for driver: $driverId');
    } else {
      final alertId = existingAlert.docs.first.id;
      await _firestore.doc(alertId).update({
        'last_occurrence': FieldValue.serverTimestamp(),
        'sensor_data': sensorData,
      });
      debugPrint('Updated existing $type alert for driver: $driverId');
    }
  }

  Future<void> _logError(String? driverId, String error) async {
    try {
      await _firestore
          .doc('errors/${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'error': error,
        'driverId': driverId,
        'timestamp': FieldValue.serverTimestamp()
      });
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }

  void _cancelSubscriptions() {
    _subscriptions.forEach((driverId, subscription) {
      subscription.cancel();
    });
    _subscriptions.clear();
  }

  void dispose() {
    _cancelSubscriptions();
  }
}
