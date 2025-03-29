import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dashbord_screen.dart'; // تحتوي على DriverSensorsPage

class DriversListPage extends StatefulWidget {
  const DriversListPage({super.key});

  @override
  State<DriversListPage> createState() => _DriversListPageState();
}

class _DriversListPageState extends State<DriversListPage> {
  late DatabaseReference driversRef;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://final-project-25937-default-rtdb.firebaseio.com",
    );
    driversRef = database.ref("drivers");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text('Drivers'),
        backgroundColor: const Color(0xFF2C2C2C),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddDriverDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2C2C2C),
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search driver by name...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: driversRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading drivers!',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text(
                      'No drivers found!',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final dataSnapshot = snapshot.data!.snapshot;
                if (!dataSnapshot.exists) {
                  return const Center(
                    child: Text(
                      'No drivers found!',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final driversMap = dataSnapshot.value as Map<dynamic, dynamic>?;
                if (driversMap == null) {
                  return const Center(
                    child: Text(
                      'No drivers found!',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                print("🔥 Received Data from Firebase: $driversMap");

                final driverKeys = driversMap.keys.toList();

                final filteredKeys = driverKeys.where((driverId) {
                  final driverData = driversMap[driverId];
                  final profileData = driverData['profile'] ?? {};
                  final driverName = (profileData['name'] ?? '').toString();
                  return driverName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredKeys.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching drivers!',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredKeys.length,
                  itemBuilder: (context, index) {
                    final driverId = filteredKeys[index];
                    final driverData = driversMap[driverId];
                    final profileData = driverData['profile'] ?? {};

                    final driverName = profileData['name'] ?? 'No Name';
                    final driverEmail = profileData['email'] ?? 'No Email';
                    final driverPhone =
                        profileData['phoneNumber'] ?? 'No Phone';

                    return Card(
                      color: const Color(0xFF2D2D2D),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: ListTile(
                        title: Text(
                          driverName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Email: $driverEmail\nPhone: $driverPhone',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriverSensorsPage(
                                driverId: driverId.toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneNumberController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Add Driver',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneNumberController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addDriver(
                    nameController.text.trim(),
                    emailController.text.trim(),
                    phoneNumberController.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addDriver(String name, String email, String phoneNumber) {
    if (name.isEmpty) return;
    final newDriver = {
      "profile": {
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
      },
      "sensors": {
        "fuel_level": 0,
        "fuel_type": "n/a",
        "collision_sensor": 0,
        "lock_sensor": false,
        "location": {"lat": 0, "lon": 0},
        "temperature": 0,
      }
    };
    driversRef.push().set(newDriver);
  }
}
