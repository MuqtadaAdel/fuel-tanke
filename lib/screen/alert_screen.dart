import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:finalproject/screen/dashbord_screen.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 199, 1, 1),
      appBar: AppBar(
        title: const Text(
          'Alert',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _deleteResolvedAlerts(context),
          ),
        ],
        backgroundColor: const Color(0xFF2C2C2C),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          return;
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('driver_alerts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(' Error occurred : ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                'there is no alerts right now . ',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ));
            }

            final alerts = snapshot.data!.docs;

            return ListView.builder(
              key: const PageStorageKey<String>('alerts_list'),
              itemCount: alerts.length,
              itemBuilder: (ctx, index) {
                final alert = alerts[index];
                final alertData = alert.data() as Map<String, dynamic>;
                final isResolved = alertData['resolved'] == true;

                return Card(
                  margin: const EdgeInsets.all(8),
                  color: isResolved ? const Color(0xFF2C2C2C) : null,
                  child: ListTile(
                    tileColor: Colors.grey[800],
                    leading: _getAlertIcon(
                        alertData, isResolved), // دالة جديدة لإدارة الأيقونة
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alertData['message'] ?? 'No message',
                            style: const TextStyle(color: Colors.white)),
                        if (alertData['fuel_sensor'] ==
                            false) // شرط عرض حالة الوقود
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver ID: ${alertData['driver_id']}',
                            style: const TextStyle(color: Colors.white70)),
                        if (isResolved)
                          Text(
                              'Resolve at : ${_formatDate(alertData['resolvedAt'])}',
                              style: TextStyle(
                                  color: Colors.green[300], fontSize: 12)),
                      ],
                    ),
                    onTap: () => _showDriverDetails(
                        context, alertData['driver_id'], alert.id, isResolved),
                    trailing: _getTrailingIcon(alertData, isResolved, context,
                        alert.id), // دالة جديدة للأيقونة الجانبية
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

// 1. دالة لإدارة أيقونة الحالة
  Widget _getAlertIcon(Map<String, dynamic> alertData, bool isResolved) {
    if (alertData['fuel_sensor'] == false) {
      return Icon(Icons.local_gas_station, color: Colors.orange);
    }
    return Icon(
      isResolved ? Icons.check_circle : Icons.warning,
      color: isResolved ? Colors.green : Colors.red,
    );
  }

// 2. دالة لإدارة الأيقونة الجانبية
  Widget _getTrailingIcon(Map<String, dynamic> alertData, bool isResolved,
      BuildContext context, String alertId) {
    if (isResolved) {
      return IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteAlert(context, alertId),
      );
    }

    if (alertData['fuel_sensor'] == false) {
      return IconButton(
        icon: const Icon(Icons.build, color: Colors.orange),
        onPressed: () => _resolveFuelAlert(context, alertId),
      );
    }

    return IconButton(
      icon: const Icon(Icons.build, color: Colors.orange),
      onPressed: () => _resolveAlertWithConfirmation(context, alertId),
    );
  }

// 3. دالة تنسيق التاريخ
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'unknown ';
    try {
      return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
    } catch (e) {
      return 'unknown ';
    }
  }

// 4. دالة حل مشكلة الوقود (جديدة)
  Future<void> _resolveFuelAlert(BuildContext context, String alertId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title:
            const Text('Confirmation', style: TextStyle(color: Colors.white)),
        content: const Text('Did you want to resolve the lock sensor?',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child:
                const Text('Resolve ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _resolveAlert(context, alertId);
      // يمكنك هنا إضافة تحديث لحالة الوقود في Realtime Database
    }
  }

  Future<void> _showDriverDetails(BuildContext context, String driverId,
      String alertId, bool isResolved) async {
    try {
      final driverRef =
          FirebaseDatabase.instance.ref('drivers/$driverId/profile');
      final driverSnapshot = await driverRef.once();

      if (!driverSnapshot.snapshot.exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('there is no driver data for this alert',
                    style: TextStyle(color: Colors.white))),
          );
        }
        return;
      }

      final driverData = Map<String, dynamic>.from(
          driverSnapshot.snapshot.value as Map? ?? {});

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C),
            title: Text('driver Inf. : ${driverData['name'] ?? ' Unknown'}',
                style: const TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone number: ${driverData['phoneNumber'] ?? 'Unknown '}',
                    style: const TextStyle(color: Colors.white)),
                Text('Email: ${driverData['email'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white)),
                if (isResolved)
                  Text('Resolve At  : ${DateTime.now().toString()}',
                      style: TextStyle(color: Colors.green)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DriverSensorsPage(driverId: driverId),
                          ),
                        );
                      },
                      child: const Text('Dashboard page'),
                    ),
                    if (!isResolved)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _resolveAlertWithConfirmation(context, alertId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 254, 255, 254),
                        ),
                        child: const Text('Resolve'),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('close',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Error occurred: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _resolveAlertWithConfirmation(
      BuildContext context, String alertId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title:
            const Text(' Confirmation', style: TextStyle(color: Colors.white)),
        content: const Text('Do you want to resolve this alert?',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Resolve',
                style: TextStyle(color: Color.fromARGB(255, 0, 173, 110))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _resolveAlert(context, alertId);
    }
  }

  Future<void> _resolveAlert(BuildContext context, String alertId) async {
    try {
      await FirebaseFirestore.instance
          .collection('driver_alerts')
          .doc(alertId)
          .update(
              {'resolved': true, 'resolvedAt': FieldValue.serverTimestamp()});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert resolved successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resolve: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteAlert(BuildContext context, String alertId) async {
    try {
      await FirebaseFirestore.instance
          .collection('driver_alerts')
          .doc(alertId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert deleted successfully ')),
        );
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('failed to delete the alert: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteResolvedAlerts(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title:
            const Text('confirm delete', style: TextStyle(color: Colors.white)),
        content: const Text('Do you want to delete all resolved alerts?',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final resolvedAlerts = await FirebaseFirestore.instance
          .collection('driver_alerts')
          .where('resolved', isEqualTo: true)
          .get();

      if (resolvedAlerts.docs.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('there is no resolved alerts to delete')),
          );
        }
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in resolvedAlerts.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Delete done  ${resolvedAlerts.docs.length} Resolved alerts')),
        );
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('failed to deletes the alerts   : ${e.toString()}')),
        );
      }
    }
  }
}
