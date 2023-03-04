import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'src/auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
                Navigator.pop(context);
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
        title: const Text('Accueil'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (context.watch<ApplicationState>().loggedIn)
                  Text(
                    '${FirebaseAuth.instance.currentUser!.displayName}',
                    style: const TextStyle(fontSize: 19),
                  ),
                Visibility(
                  visible: !context.watch<ApplicationState>().loggedIn,
                  child: const Text(
                    'Bonjour,',
                    style: TextStyle(fontSize: 19),
                  ),
                ),
                Consumer<ApplicationState>(
                  builder: (context, state, child) {
                    return AuthFunc(
                      loggedIn: state.loggedIn,
                      signOut: () {
                        FirebaseAuth.instance.signOut();
                      },
                    );
                  },
                ),
              ],
            ),
            // title header for the list of doctors
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Liste des docteurs',
                style: TextStyle(fontSize: 19),
              ),
            ),
            Consumer<ApplicationState>(
              builder: (context, state, child) {
                return Visibility(
                  visible: state.loggedIn,
                  // on affiche les docteurs
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        for (var doctor
                            in context.watch<ApplicationState>().getDoctors)
                          // faire une card
                          Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(doctor.fonction),
                                  subtitle:
                                      Text('${doctor.name} ${doctor.prenom}'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      child: const Icon(
                                        Icons.calendar_month,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        size: 30.0,
                                      ),
                                      onPressed: () {
                                        // mettre dans le state le docteur selectionné
                                        context
                                            .read<ApplicationState>()
                                            .setSelectedDoctor(doctor);

                                        // call getBookings
                                        context
                                            .read<ApplicationState>()
                                            .getBookings();

                                        context.push('/doctor');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
