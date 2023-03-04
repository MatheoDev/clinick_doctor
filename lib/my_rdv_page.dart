import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class MyRdvPage extends StatefulWidget {
  const MyRdvPage({Key? key}) : super(key: key);

  @override
  State<MyRdvPage> createState() => _MyRdvPageState();
}

class _MyRdvPageState extends State<MyRdvPage> {
  @override
  Widget build(BuildContext context) {
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
        title: const Text('Liste des RDV'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Consumer<ApplicationState>(
                builder: (context, appState, child) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: appState.bookings.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Pour ${appState.bookings[index].patient}'),
                                Text('Type : ${appState.bookings[index].type}'),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Le ${appState.bookings[index].date.day}/${appState.bookings[index].date.month}/${appState.bookings[index].date.year} à ${appState.bookings[index].date.hour}:${appState.bookings[index].date.minute == 0 ? '00' : appState.bookings[index].date.minute}'),
                                Text(appState.bookings[index].doctor.fonction),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
