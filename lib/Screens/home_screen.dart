import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:medicines_reminder/Screens/login_screen.dart';
import 'package:medicines_reminder/Screens/medication_screen.dart';
import 'package:medicines_reminder/Services/drawer_serivces.dart';
import 'package:medicines_reminder/Services/notification_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationService notificationService = NotificationService();

  User? userId = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationService.requestNotificationPermission();

    notificationService.getDeviceToken().then((value) {
      print('device Token');
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        actions: [
          GestureDetector(
            child: SpeedDial(
              animatedIcon: AnimatedIcons.ellipsis_search,
              direction: SpeedDialDirection.down,
              elevation: 0.0,
              closeManually: false,
              childMargin: const EdgeInsets.only(left: 60.0),
              children: [
                SpeedDialChild(
                    child: const Icon(Icons.logout),
                    label: 'SignOut',
                    onTap: () {
                      EasyLoading.show();
                      FirebaseAuth.instance.signOut();
                      Get.off(() => const LoginScreen());
                      EasyLoading.dismiss();
                    }),
              ],
            ),
          )
        ],
        title: const Text('Home'),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("reminder")
            .where("userId", isEqualTo: userId!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something is wrong!'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
                    "Let's add Your Reminder by \nclicking that plus button!"));
          }
          if (snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var note = snapshot.data!.docs[index]["medicineName"];
                  var docId = snapshot.data!.docs[index].id;
                  Timestamp date = snapshot.data!.docs[index]['Created At'];
                  var finalDate = DateTime.parse(date.toDate().toString());
                  return Card(
                    elevation: 3,
                    shadowColor: Colors.grey,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        note,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text('Created : ${GetTimeAgo.parse(finalDate)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 10.0),
                          GestureDetector(
                              onTap: () {
                                EasyLoading.show();
                                FirebaseFirestore.instance
                                    .collection("reminder")
                                    .doc(docId)
                                    .delete();
                                EasyLoading.dismiss();
                              },
                              child: const Icon(Icons.delete))
                        ],
                      ),
                    ),
                  );
                });
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          EasyLoading.show();
          Get.to(() => MedicationScreen());
          EasyLoading.dismiss();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
