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
import 'package:particles_flutter/particles_flutter.dart';
import 'package:odyssey/kml/KmlMaker.dart';
import 'package:odyssey/pages/settings.dart';
import 'package:odyssey/utils/extensions.dart';
import 'package:odyssey/widget/show_connection.dart';

import '../connection/SSH.dart';
import '../kml/BaloonLoader.dart';
import '../kml/NamePlaceBallon.dart';
import '../providers/connection_providers.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

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
    print("wrking");
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
        print("thisiswokng");
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
    _loadBalloon();
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
    _moonController.stop();
    _marsController.stop();

    SSH(ref: ref).flyTo(
        context,
        40.730610,
        -73.935242,
        11,
        0.0,
        0.0);
    SSH(ref:ref).initialConnect();
  }



  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool connected = ref.watch(connectedProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemesDark().tabBarColor,
        title: Text(
          "Voyager",
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
      body: Stack(
        children: [
          Expanded(
            child: CircularParticle(
              key: UniqueKey(),
              awayRadius: 60,
              numberOfParticles: 600,
              speedOfParticles: 1,
              height: screenHeight,
              width: screenWidth,
              onTapAnimation: true,
              particleColor: Colors.white.withAlpha(150),
              awayAnimationDuration: Duration(milliseconds: 600),
              maxParticleSize: 2,
              isRandSize: true,
              isRandomColor: true,
              randColorList: [
                Colors.white.withAlpha(50),
                Colors.white.withAlpha(50),
              ],
              awayAnimationCurve: Curves.ease,
              enableHover: true,
              hoverColor: Colors.white.withAlpha(80),
              hoverRadius: 90,
              connectDots: false, //not recommended
            ),
          ),
          Center(
            child: ListView(
              children: <Widget>[
                Container(
                    key: connectedKey, child: ShowConnection(status: connected)),
                Container(
                  height: 400,
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Lottie.asset('assets/lottie/earth360.json',
                            controller: _earthController),
                        onTap: () {
                         /* AllCityData.availableCities.map(
                                (city) {
                              ref.read(cityDataProvider.notifier).state = city;
                            },
                          ).toList();*/
                          _earthController.repeat();
                          _moonController.stop();
                          _marsController.stop();
                          _planetEarth();
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /*Container(
                        key: navigateToLleidaKey,
                        child: menuButton("Navigate To Kolkata", _execute),
                      ),*/
                      menuButton("Navigate To Durgapur", _navigateToDurgapur),
                      menuButton("play Orbit", _playOrbit),
                      menuButton("Display Html Bubble", _showOverlay),    //Todo: Display Html Bubble
                      menuButton("Relaunch LG", () {
                        showAlertDialog(context, 1);
                      }),
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
    _moonController.dispose();
    _marsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget menuButton(String text, Function onPressed) {
    return Container(
      height: 150,
      width: 200,
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(ThemesDark().tabBarColor),
              foregroundColor:
                  MaterialStateProperty.all(ThemesDark().oppositeColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0)))),
          onPressed: () {
            onPressed();

          },
          child: Text(
            text,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          )),
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
          // _cleanKml();
          // _cleanBalloon();
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

  Future<void> _planetMars() async {
    SSHSession? session = await SSH(ref: ref).planetMars();
    if (session != null) {
      print(session.stdout);
    }
    setState(() {
      planet = Planet.isMars;
    });
  }

  Future<void> _loadBalloon() async {
    await BalloonLoader(ref: ref, mounted: mounted, context: context)
        .loadDashBoardBalloon();
    ref.read(isLoadingProvider.notifier).state = false;
  }

 Future<void> _cleanKml() async {
    SSHSession? session = await SSH(ref: ref).cleanKML(context);
    if (session != null) {
      print(session.stdout);
    }
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
  
  Future<void> _cleanBalloon() async {
    SSHSession? session = await SSH(ref: ref).cleanBalloon(context);
    if (session != null) {
      print(session.stdout);
    }
  }

  Future<void> _execute() async {
    SSHSession? session = await SSH(ref: ref).execute();
    if (session != null) {
      print(session.stdout);
    }
  }

  Future<void> _navigateToDurgapur() async {
    SSHSession? session = await SSH(ref: ref).search("Department of Computer Science, NIT Durgapur,Kolkata");
    if (session != null) {
      print(session.stdout);
    }
  }

  Future<void> _relaunchLG() async {
    SSHSession? session = await SSH(ref: ref).relunchLG();
   /* print("this is relaunched$session");
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }*/
  }

  Future<void> _planetEarth() async {
    SSHSession? session = await SSH(ref: ref).planetEarth();
    if (session != null) {
      print(session.stdout);
    }
    setState(() {
      planet = Planet.isEarth;
    });
  }

  Future<void> _playOrbit() async {
    if (orbitPlaying) {
      await orbitStop();
    } else {
      await orbitPlay();
    }
  }

  Future<void> _planetMoon() async {
    SSHSession? session = await SSH(ref: ref).planetMoon();
    if (session != null) {
      print(session.stdout);
    }
    setState(() {
      planet = Planet.isMoon;
    });
  }

}

enum Planet {
  isEarth,
  isMoon,
  isMars,
}