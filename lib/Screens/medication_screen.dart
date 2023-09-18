import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:medicines_reminder/Screens/home_screen.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({Key? key}) : super(key: key);

  @override
  MedicationScreenState createState() => MedicationScreenState();
}

class MedicationScreenState extends State<MedicationScreen> {
  String medicationName = '';
  int frequency = 1;
  List<TimeOfDay> times = [TimeOfDay.now()];

  TextEditingController medicineNameController = TextEditingController();

  User? userId = FirebaseAuth.instance.currentUser;
  String? userName = FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reminder'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  height: 250.0,
                  child: Lottie.asset('assets/animation_lmovv4v6.json')),
              SizedBox(
                height: 18.0,
              ),
              TextFormField(
                controller: medicineNameController,
                decoration: const InputDecoration(
                  hintText: 'Medicine Name',
                  enabledBorder: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    medicationName = value;
                  });
                },
              ),
              SizedBox(
                height: 18.0,
              ),
              const Text('Frequency (times per day):'),
              Slider(
                value: frequency.toDouble(),
                min: 1,
                max: 5,
                onChanged: (value) {
                  setState(() {
                    frequency = value.toInt();
                  });
                },
              ),
              SizedBox(
                height: 18.0,
              ),
              const Text('Times to take medication:'),
              Column(
                children: times.map((time) {
                  return TimePickerWidget(
                    initialTime: time,
                    onTimeSelected: (newTime) {
                      setState(() {
                        times.remove(time);
                        times.add(newTime);
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(
                height: 18.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  EasyLoading.show();
                  var medicineName = medicineNameController.text.trim();
                  if (medicineName.isNotEmpty) {
                    try {
                      await FirebaseFirestore.instance
                          .collection("reminder")
                          .doc()
                          .set({
                        "medicineName": medicineName,
                        "Created At": DateTime.now(),
                        "userId": userId?.uid,
                        "email": userName,
                        "Time": times.toString(),
                      });
                    } catch (e) {
                      print("Error $e");
                    }
                  } else {
                    EasyLoading.dismiss();
                    print("Medicine name is empty");
                  }

                  Get.to(() => HomeScreen());
                  EasyLoading.dismiss();
                },
                child: const Text('Save Medication'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(400, 45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimePickerWidget extends StatelessWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerWidget(
      {required this.initialTime, required this.onTimeSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('${initialTime.hour}:${initialTime.minute}'),
        IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: initialTime,
            );
            if (selectedTime != null) {
              onTimeSelected(selectedTime);
            }
          },
        ),
      ],
    );
  }
}
