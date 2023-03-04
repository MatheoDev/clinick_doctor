import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'booking.dart';
import 'doctor.dart';
import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Doctor? _selectedDoctor;
  Doctor? get selectedDoctor => _selectedDoctor;

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  StreamSubscription<QuerySnapshot>? _getDBookingUserSubscription;
  List<Booking> _rdvs = [];
  List<Booking> get rdvs => _rdvs;

  StreamSubscription<QuerySnapshot>? _getDoctorsSubscription;
  List<Doctor> _getDoctors = [];
  List<Doctor> get getDoctors => _getDoctors;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _getDoctorsSubscription = FirebaseFirestore.instance
            .collection('doctors')
            .snapshots()
            .listen((snapshot) {
          _getDoctors = [];
          for (final document in snapshot.docs) {
            _getDoctors.add(
              Doctor(
                name: document.data()['nom'] as String,
                prenom: document.data()['prenom'] as String,
                fonction: document.data()['fonction'] as String,
              ),
            );
          }

          notifyListeners();
        });
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }

  Future<void> getBookings() async {
    final snapsh = await FirebaseFirestore.instance
        .collection('booking')
        .where('doctor.nom', isEqualTo: selectedDoctor!.name)
        .where('doctor.prenom', isEqualTo: selectedDoctor!.prenom)
        .get();
    final slots = snapsh.docs.map((e) => e.data()).toList();
    List<Booking> bookings = [];
    for (final slot in slots) {
      bookings.add(Booking.fromJson(slot));
    }
    _bookings = bookings;
    notifyListeners();
  }

  void setSelectedDoctor(Doctor doctor) {
    _selectedDoctor = doctor;
    notifyListeners();
  }

  Future<void> addBooking(Booking booking) async {
    await FirebaseFirestore.instance
        .collection('booking')
        .add(booking.toJson());
    _bookings.add(booking);
    notifyListeners();
  }

  bool isReserved(String time, DateTime date) {
    // time = '10:00' ou '10:30'
    DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(time.split(':')[0]),
      int.parse(time.split(':')[1]),
    );
    return _bookings.any((element) =>
        element.date.year == dateTime.year &&
        element.date.month == dateTime.month &&
        element.date.day == dateTime.day &&
        element.date.hour == dateTime.hour &&
        element.date.minute == dateTime.minute);
  }

  // return number of booking for a date
  int getNumberOfBooking(DateTime date) {
    print('getNumberOfBooking($date)');
    return _bookings
        .where((element) =>
            element.date.year == date.year &&
            element.date.month == date.month &&
            element.date.day == date.day)
        .length;
  }
}
