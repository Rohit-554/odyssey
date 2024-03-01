import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:odyssey/core/ui/connectionScreen.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:odyssey/utils/extensions.dart';
import 'package:odyssey/core/widgets/show_connection.dart';
import '../../connection/SSH.dart';
import '../../kml/Balloon.dart';
import '../kml/KmlOverlayLoader.dart';
import '../../providers/providers.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

final settingsKey = GlobalKey();

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  Planet planet = Planet.isEarth;
  late AnimationController _earthController;
  late AnimationController _moonController;
  late AnimationController _marsController;
  late TextEditingController _searchController;


  GlobalKey settingsKey = GlobalKey();
  GlobalKey connectedKey = GlobalKey();
  GlobalKey navigateToLleidaKey = GlobalKey();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  bool orbitPlaying = false;



  orbitPlay() async {
    setState(() {
      orbitPlaying = true;
    });
    SSH(ref: ref).flyTo(context,Const.latitude, Const.longitude, Const.appZoomScale.zoomLG, 0, 0);

    await Future.delayed(const Duration(milliseconds: 1000));
    for (int i = 0; i <= 360; i += 10) {
      if (!mounted) {
        return;
      }
      if (!orbitPlaying) {
        break;
      }
      SSH(ref: ref).flyToOrbit(
          context,
          Const.latitude,
          Const.longitude,
          Const.orbitZoomScale.zoomLG,
          60,
          i.toDouble());
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    if (!mounted) {
      return;
    }
    SSH(ref: ref).flyTo(context, Const.latitude,
        Const.longitude, Const.appZoomScale.zoomLG, 0, 0);
    setState(() {
      orbitPlaying = false;
    });
  }

  orbitStop() async {
    setState(() {
      orbitPlaying = false;
    });
    SSH(ref: ref).flyTo(context, Const.latitude,
        Const.longitude, Const.appZoomScale.zoomLG, 0, 0);
  }

  @override
  void initState() {
    super.initState();
    // _loadBalloon();
    _earthController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _moonController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _marsController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _searchController = TextEditingController(text: '');
    _earthController.stop();

    SSH(ref: ref).flyTo(
        context,
        Const.latitude,
        Const.longitude,
        11,
        0.0,
        0.0);
    SSH(ref:ref).initialConnect();

    _earthController.repeat();
  }



  @override
  Widget build(BuildContext context) {
    bool isConnectedToLg = ref.watch(connectedProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemesDark().tabBarColor,
        title: Text(
          "Odyssey - LG Control Panel",
          style: TextStyle(color: ThemesDark().oppositeColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectionScreen(),
                ),
              );
            },
            color: ThemesDark().oppositeColor,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ShowConnection(status: isConnectedToLg),
          ),
          Expanded( // Wrap the Row with Expanded
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Lottie.asset(
                        'assets/lottie/earthsat.json',
                        controller: _earthController,
                        height: 400, // Adjust height as needed
                        width: 400, // Adjust width as needed
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          menuButton("Take me to Home", _navigateToKolkata),
                          menuButton("Play orbit", _playOrbit),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          menuButton("Display Overlay", _showOverlay),
                          menuButton("Reboot LG", () {
                            showAlertDialog(context, 1);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }




  @override
  void dispose() {
    _earthController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget menuButton(String text, Function onPressed) {
    return Container(
      height: 150,
      width: 200,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF001F5C), // Dark blue
            Color(0xFF253773), // Deep blue
            Color(0xFF161D3F), // Dark purple
          ],
          stops: [0.1, 0.5, 0.9],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ),
        onPressed: () {
          onPressed();
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }



  showAlertDialog(BuildContext context, int ind) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop();
        if (ind == 1) {
          print("this is confirmed");
          _relaunchLG();
        } else if (ind == 2) {
          print("this is confirmed2");
          ref.read(connectedProvider.notifier).state = false;
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: Text((ind == 1)
          ? "Are you sure you want to relaunch LG?"
          : "Are you sure you want to disconnect from LG?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }



  Future<void> _showOverlay() async {
    String session = await SSH(ref: ref).renderInSlave(context, ref.read(rightmostRigProvider), KMLMakers.screenOverlayImage(
        Const.overLayImageLink, 2684/3000));
    if (session.isNotEmpty) {
      print(session);
    }else{
      print('Session is null');
    }
  }



  Future<void> _navigateToKolkata() async {
    SSHSession? session = await SSH(ref: ref).search("sec V,Kolkata");
    if (session != null) {
      print(session.stdout);
    }
  }

  Future<void> _relaunchLG() async {
    SSHSession? session = await SSH(ref: ref).relunchLG();
  }

  Future<void> _playOrbit() async {
    if (orbitPlaying) {
      await orbitStop();
    } else {
      await orbitPlay();
    }
  }

}

enum Planet {
  isEarth,
  isMoon,
  isMars,
}