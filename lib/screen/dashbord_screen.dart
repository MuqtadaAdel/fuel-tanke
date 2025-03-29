import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'map_screen.dart';

class DriverSensorsPage extends StatefulWidget {
  final String driverId;

  const DriverSensorsPage({super.key, required this.driverId});

  @override
  State<DriverSensorsPage> createState() => _DriverSensorsPageState();
}

class _DriverSensorsPageState extends State<DriverSensorsPage> {
  late DatabaseReference driverRef;

  double parsedLat = 0.0;
  double parsedLon = 0.0;

  @override
  void initState() {
    super.initState();
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://final-project-25937-default-rtdb.firebaseio.com",
    );
    // سنقرأ عقدة السائق كاملة: drivers/driverId
    driverRef = database.ref('drivers/${widget.driverId}');
  }

  // دالة "سحب للتحديث" (إضافية؛ Realtime Database تتحدث تلقائيًا)
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    return;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF2C2C2C),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder<DatabaseEvent>(
          // نراقب التغيرات في عقدة السائق كلها
          stream: driverRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'Loading ${widget.driverId} data...',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 50),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text('No data found!',
                    style: TextStyle(color: Colors.white)),
              );
            }

            final dataSnapshot = snapshot.data!.snapshot;
            if (!dataSnapshot.exists) {
              return const Center(
                child: Text('No data found!',
                    style: TextStyle(color: Colors.white)),
              );
            }

            // نفترض أن بنية السائق بالشكل:
            // {
            //   "name": "Muqtada Adel",
            //   "sensors": {
            //     "temperature": 0,
            //     ...
            //   }
            // }
            final driverMap = dataSnapshot.value as Map<dynamic, dynamic>?;

            if (driverMap == null) {
              return const Center(
                child: Text('No data found!',
                    style: TextStyle(color: Colors.white)),
              );
            }

            // قراءة اسم السائق
            final profileData = driverMap['profile'] ?? {};
            final driverEmail = profileData['email'] ?? 'No Email';
            final driverPhone = profileData['phoneNumber'] ?? 'No Phone';
            final driverName = profileData['name'] ?? 'No Name';

            // قراءة الحساسات
            final sensorsMap = driverMap['sensors'] as Map<dynamic, dynamic>?;

            if (sensorsMap == null) {
              // إذا لم يكن هناك عقدة sensors
              return Center(
                child: Text(
                  'No sensor data found for $driverName!',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            // بقية الحقول
            final temperature = sensorsMap['temperature']?.toString() ?? 'N/A';
            final fuelLevel = sensorsMap['fuel_level']?.toString() ?? 'N/A';
            final fuelType = sensorsMap['fuel_type']?.toString() ?? 'N/A';
            final collision =
                sensorsMap['collision_sensor']?.toString() ?? 'N/A';
            final lockSensor = sensorsMap['lock_sensor']?.toString() ?? 'N/A';

            var lat = 'N/A';
            var lon = 'N/A';
            if (sensorsMap['location'] != null) {
              lat = sensorsMap['location']['lat']?.toString() ?? 'N/A';
              lon = sensorsMap['location']['lon']?.toString() ?? 'N/A';
            }

            // محاولة تحويل lat/lon إلى double
            try {
              parsedLat = double.parse(lat);
              parsedLon = double.parse(lon);
            } catch (e) {
              parsedLat = 0.0;
              parsedLon = 0.0;
            }

            // تصميم الواجهة
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // البطاقة الرئيسية
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Driver Name
                        const Text(
                          'Driver Name:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$driverName,\n Email:  $driverEmail,\n Phone Number: $driverPhone',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 8),

                        // صف: Temperature + Fuel Level
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.thermostat,
                                    color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  'Temperature: $temperature°C',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_gas_station,
                                    color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  'Fuel Level: $fuelLevel%',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // صف ثاني: Fuel Type + Collision
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.ev_station,
                                    color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  'Fuel Type: $fuelType',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.warning,
                                    color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  'Collision: $collision',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // GPS
                        Row(
                          children: [
                            const Icon(Icons.my_location,
                                color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              'GPS:  $lat, $lon',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Lock
                        Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              'Lock: ${lockSensor == 'true' ? 'Locked' : 'Unlocked'}',
                              style: TextStyle(
                                color: lockSensor == 'true'
                                    ? Colors.red
                                    : Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر ينقلنا لشاشة MapScreen مع lat/lon
                  InkWell(
                    onTap: () {
                      // انتقل لشاشة MapScreen ومرر lat/lon
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapScreen(
                            latitude: parsedLat.toString(),
                            longitude: parsedLon.toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, color: Colors.white),
                          const SizedBox(width: 8),
                          // نص ملوّن (كما تريد)، هنا جعلناه بسيطًا مع 4 ألوان
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: 'View',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                TextSpan(
                                  text: ' Truck',
                                  style: TextStyle(color: Colors.red),
                                ),
                                TextSpan(
                                  text: ' Location',
                                  style: TextStyle(color: Colors.yellow),
                                ),
                                TextSpan(
                                  text: ' on Map',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
