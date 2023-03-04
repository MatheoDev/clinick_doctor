import 'doctor.dart';

class Booking {
  final String patient;
  final Doctor doctor;
  final String type;
  final DateTime date;

  Booking(
      {required this.patient,
      required this.doctor,
      required this.date,
      required this.type});

  factory Booking.fromJson(Map<String, dynamic> json) {
    Doctor doctor = Doctor(
      name: json['doctor']['nom'],
      prenom: json['doctor']['prenom'],
      fonction: json['doctor']['fonction'],
    );
    // json['date'] = Timestamp(seconds=1677762000, nanoseconds=891000000)
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
        json['date'].seconds * 1000 + json['date'].nanoseconds ~/ 1000000);
    return Booking(
      patient: json['patient'],
      doctor: doctor,
      date: date,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patient,
      'doctor': {
        'nom': doctor.name,
        'prenom': doctor.prenom,
        'fonction': doctor.fonction
      },
      'date': date,
      'type': type,
    };
  }
}
