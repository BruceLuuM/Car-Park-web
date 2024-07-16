import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_system/components/add_parking.dart';
import 'package:parking_system/components/camera_view.dart';
import 'package:parking_system/providers/auth_providers.dart';
import 'package:parking_system/providers/parking_providers.dart';
import 'package:parking_system/screen/register.dart';
import 'package:parking_system/screen/signup.dart';
import 'package:parking_system/services/api_service.dart';
import 'package:parking_system/services/mock_api_service.dart';
import 'package:parking_system/components/web_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiService = ApiService('http://localhost:3000');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ParkingProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Parking System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CAR PARKING SYSTEM')),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () async {
                  await context.read<AuthProvider>().login(
                        usernameController.text,
                        passwordController.text,
                      );
                  if (context.read<AuthProvider>().isAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  }
                },
                child: const Text('Login'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final parkingProvider = context.watch<ParkingProvider>();
    final TextEditingController plateNumberController = TextEditingController();
    final apiService = MockApiService('http://localhost:3000');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
            child: const Text('Register'),
          ),
          Expanded(
            child: Row(
              children: [
                // const Expanded(
                //   flex: 4,
                //   child: VideoStreamScreen(
                //     streamUrl:
                //         'http://localhost:5001/', // Replace with your streaming URL
                //   ),
                // ),
                // Expanded(
                //   flex: 4,
                //   child: VideoCameraScreen(),
                // ),
                Expanded(
                    flex: 3,
                    child: AddParkingScreen(
                      onUpdate: () {
                        setState(() {});
                      },
                    )),
                Expanded(
                  flex: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('LIST'),
                    ),
                    body: FutureBuilder(
                      future: parkingProvider.fetchParkings(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return ListView.builder(
                            itemCount: parkingProvider.parkings.length,
                            itemBuilder: (context, index) {
                              final parking = parkingProvider.parkings[index];
                              return ListTile(
                                title: Text('Plate: ${parking['numberPlate']}'),
                                subtitle: Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(parking['timeIn']))} In: ${DateFormat('HH:mm').format(DateTime.parse(parking['timeIn']))}  Out: ${(parking['timeOut'] != null) ? DateFormat('HH:mm').format(DateTime.parse(parking['timeOut'])) : 'N/A'}'),
                                trailing: Column(
                                  children: [
                                    // Expanded(
                                    //   flex: 4,
                                    //   child: ElevatedButton(
                                    //     onPressed: () {
                                    //       // Calculate money based on time in and time out
                                    //       if (parking['timeIn'] != null &&
                                    //           parking['timeOut'] != null) {
                                    //         final timeIn =
                                    //             DateTime.parse(parking['timeIn']);
                                    //         final timeOut = DateTime.parse(
                                    //             parking['timeOut']!);
                                    //         final duration =
                                    //             timeOut.difference(timeIn);
                                    //         final hours = duration.inHours;
                                    //         final money = hours *
                                    //             10; // Assuming $10 per hour

                                    //         showDialog(
                                    //           context: context,
                                    //           builder: (BuildContext context) =>
                                    //               AlertDialog(
                                    //             title: const Text('Calculate'),
                                    //             content: Text('Total: \$ $money'),
                                    //             actions: <Widget>[
                                    //               TextButton(
                                    //                 onPressed: () =>
                                    //                     Navigator.pop(context),
                                    //                 child: const Text('OK'),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         );
                                    //       } else {
                                    //         ScaffoldMessenger.of(context)
                                    //             .showSnackBar(
                                    //           const SnackBar(
                                    //             content: Text(
                                    //                 'Time in and time out must be set.'),
                                    //           ),
                                    //         );
                                    //       }
                                    //     },
                                    //     child: const Text('Calculate Money'),
                                    //   ),
                                    // ),
                                    // const Spacer(),
                                    // Expanded(
                                    //   flex: 4,
                                    //   child: ElevatedButton(
                                    //     onPressed: () async {
                                    //       // Capture frame and retrieve plate number
                                    //       plateNumberController.text =
                                    //           parking['numberPlate'];
                                    //       String plateNumber = await apiService
                                    //           .captureFrameAndRetrievePlateNumber();
                                    //       if (plateNumber.isNotEmpty) {
                                    //         // Plate number exists, set time out and save using API
                                    //         context
                                    //             .read<ParkingProvider>()
                                    //             .completeParking(parking['id'], {
                                    //           'timeOut':
                                    //               DateFormat('yyyy-MM-dd HH:mm')
                                    //                   .format(DateTime.now()),
                                    //         });
                                    //       } else {
                                    //         // Handle case where plate number is not recognized
                                    //         ScaffoldMessenger.of(context)
                                    //             .showSnackBar(
                                    //           const SnackBar(
                                    //             content: Text(
                                    //                 'Plate number not recognized.'),
                                    //           ),
                                    //         );
                                    //       }
                                    //     },
                                    //     child: const Text('Timeout'),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),

                //thống kê
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const AddParkingScreen()),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
