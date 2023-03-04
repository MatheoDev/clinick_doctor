import 'package:calendar_agenda/calendar_agenda.dart';
import 'booking.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:calendar_view/calendar_view.dart';

import 'app_state.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  // props date selected
  String vue = 'mois';

  @override
  Widget build(BuildContext context) {
    // add event controller
    final EventController eventController = EventController();
    context.watch<ApplicationState>().bookings.forEach((booking) {
      eventController.add(
        CalendarEventData(
          title: '${booking.patient} - ${booking.type}',
          color: Colors.blue,
          date: booking.date,
          startTime: booking.date,
          endTime: booking.date.add(const Duration(minutes: 15)),
        ),
      );
    });

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Clinick App'),
            ),
            ListTile(
              title: const Text('Accueil'),
              onTap: () {
                context.push('/');
              },
            ),
            if (context.watch<ApplicationState>().loggedIn)
              ListTile(
                title: const Text('Profil'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile');
                },
              ),
            if (context.watch<ApplicationState>().loggedIn &&
                context.watch<ApplicationState>().selectedDoctor != null)
              ListTile(
                title: const Text('RDV du docteur'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/rdv');
                },
              ),
            if (!context.watch<ApplicationState>().loggedIn)
              ListTile(
                title: const Text('Se connecter'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/sign-in');
                },
              ),
            if (!context.watch<ApplicationState>().loggedIn)
              ListTile(
                title: const Text('S\'inscrire'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/sign-up');
                },
              ),
            if (context.watch<ApplicationState>().loggedIn)
              ListTile(
                title: const Text('Se déconnecter'),
                onTap: () {
                  Navigator.pop(context);
                  FirebaseAuth.instance.signOut();
                },
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Medecin'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                setState(() {
                  vue = 'jour';
                });
              },
            ),
            IconButton(
                icon: const Icon(Icons.calendar_view_week),
                onPressed: () {
                  setState(() {
                    vue = 'semaine';
                  });
                }),
            IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  setState(() {
                    vue = 'mois';
                  });
                }),
          ],
        ),
      ),
      body:
          // en fonction du state on affiche le calendrier du jour, de la semaine ou du mois
          vue == 'jour'
              ? DayView(
                  controller: eventController,
                  eventTileBuilder: (date, events, boundry, start, end) {
                    // Return your widget to display as event tile.
                    return Container(
                      // faire une card avec le rdv pour le start et end
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: // afficher le patient
                          Text(events[0].title),
                    );
                  },
                  fullDayEventBuilder: (events, date) {
                    // Return your widget to display full day event view.
                    return Container();
                  },
                  showVerticalLine:
                      true, // To display live time line in day view.
                  showLiveTimeLineInAllDays:
                      true, // To display live time line in all pages in day view.
                  minDay: DateTime(1990),
                  maxDay: DateTime(2050),
                  initialDay: DateTime.now(),
                  heightPerMinute: 1, // height occupied by 1 minute time span.
                  eventArranger:
                      SideEventArranger(), // To define how simultaneous events will be arranged.
                  onEventTap: (events, date) => print(events),
                  onDateLongPress: (date) => print(date),
                )
              : vue == 'semaine'
                  ? WeekView(
                      controller: eventController,
                      eventTileBuilder: (date, events, boundry, start, end) {
                        // Return your widget to display as event tile.
                        return Container(
                          // faire une card avec le rdv pour le start et end
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(events[0].title),
                        );
                      },
                      fullDayEventBuilder: (events, date) {
                        // Return your widget to display full day event view.
                        return Container();
                      },
                      showLiveTimeLineInAllDays:
                          true, // To display live time line in all pages in week view.
                      width: 400, // width of week view.
                      minDay: DateTime(1990),
                      maxDay: DateTime(2050),
                      initialDay: DateTime.now(),
                      heightPerMinute:
                          1, // height occupied by 1 minute time span.
                      eventArranger:
                          SideEventArranger(), // To define how simultaneous events will be arranged.
                      onEventTap: (events, date) => print(events),
                      onDateLongPress: (date) => print(date),
                      startDay: WeekDays.sunday, //
                    )
                  : MonthView(
                      controller: eventController,
                      cellBuilder: (date, event, isToday, isInMonth) =>
                          Container(
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue : Colors.white,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(date.day.toString()),
                            // show number of booking
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text(
                                  context
                                      .watch<ApplicationState>()
                                      .getNumberOfBooking(date)
                                      .toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      minMonth: DateTime(1990),
                      maxMonth: DateTime(2050),
                      initialMonth: DateTime.now(),
                      cellAspectRatio: 1,
                      onPageChange: (date, pageIndex) =>
                          print("$date, $pageIndex"),
                      onCellTap: (events, date) {
                        // Implement callback when user taps on a cell.
                        print(events);
                      },
                      startDay: WeekDays
                          .sunday, // To change the first day of the week.
                      // This callback will only work if cellBuilder is null.
                      onEventTap: (event, date) => print(event),
                      onDateLongPress: (date) => print(date),
                    ),
    );
  }
}
