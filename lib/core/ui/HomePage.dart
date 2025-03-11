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
import 'package:odyssey/utils/extensions.dart';
import 'package:odyssey/core/widgets/show_connection.dart';
import '../../connection/SSH.dart';
import '../../kml/Balloon.dart';
import '../kml/KmlOverlayLoader.dart';
import '../../providers/providers.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../utils/ImageConst.dart';

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



  /*orbitPlay() async {
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
  }*/

  showSplashLogo() async{
    try{
      await ref.read(sshClientProvider)?.execute(
          "echo '${KMLMakers.screenOverlayImage(ImageConst.splashOnline3, Const.splashAspectRatio)}' > /var/www/html/kml/slave_${ref.read(leftmostRigProvider)}.kml");
    }catch(error){
      await showSplashLogo();
    }

  }

  cleanKML(context) async {
    try {
      await ref.read(sshClientProvider)?.run('echo "" > /tmp/query.txt');
      await ref.read(sshClientProvider)?.run("echo '' > /var/www/html/kml/slave_${ref.read(rightmostRigProvider)}.txt");
    } catch (error) {
      await cleanKML(context);
    }
  }

  cleanBalloon(context) async {
    try {
      String blank = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';
      await ref.read(sshClientProvider)?.run(
          "echo '${BalloonMakers
              .blankBalloon()}' > /var/www/html/kml/slave_${ref.read(
              leftmostRigProvider)}.kml");

    } catch (error) {
      await cleanBalloon(context);
    }
  }

  showLaFire(context) async {
    try{
      await SSH(ref: ref).sendKmlService(context: context);
    }catch(error){
      //await showLaFire(context);
    }
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
    // Get screen size
    final size = MediaQuery.of(context).size;
    // Define breakpoint for layout switch
    final bool isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemesDark().tabBarColor,
        title: Text(
          "Odyssey Nova - LG Control Panel",
          style: TextStyle(
            color: ThemesDark().oppositeColor,
            // Responsive font size
            fontSize: isSmallScreen ? 18 : 22,
          ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShowConnection(status: isConnectedToLg),
            ),
            // Use LayoutBuilder for responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate animation size based on screen width
                final double animationSize = isSmallScreen
                    ? constraints.maxWidth * 0.8
                    : constraints.maxWidth * 0.4;

                // Content layout changes based on screen size
                return isSmallScreen
                    ? _buildVerticalLayout(animationSize)
                    : _buildHorizontalLayout(animationSize);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(double animationSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Lottie.asset(
              'assets/lottie/earthsat.json',
              controller: _earthController,
              height: animationSize,
              width: animationSize,
            ),
          ),
        ),
        _buildButtonGrid(),
      ],
    );
  }

  Widget _buildHorizontalLayout(double animationSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Lottie.asset(
                'assets/lottie/earthsat.json',
                controller: _earthController,
                height: animationSize,
                width: animationSize,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildButtonGrid(),
        ),
      ],
    );
  }

  Widget _buildButtonGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate button size based on available width
          final double buttonWidth = (constraints.maxWidth - 48) / 2;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButtonRow(
                "Say Hello",
                _sayHello,
                "Show Logo",
                _showLogo,
                buttonWidth,
              ),
              const SizedBox(height: 20),
              _buildButtonRow(
                "Show LA Fire",
                _showLAFire,
                "Clean Logos",
                    () => cleanBalloon(context),
                buttonWidth,
              ),
              const SizedBox(height: 20),
              _buildButtonRow(
                "Clean KMLs",
                _cleanKML,
                "Reboot LG",
                    () => showAlertDialog(context, 1),
                buttonWidth,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButtonRow(
      String label1,
      VoidCallback onPressed1,
      String label2,
      VoidCallback onPressed2,
      double buttonWidth,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: buttonWidth,
          child: menuButton(label1, onPressed1),
        ),
        SizedBox(
          width: buttonWidth,
          child: menuButton(label2, onPressed2),
        ),
      ],
    );
  }

// Assuming this is your existing menuButton widget, but let's make it more responsive
  Widget menuButton(String text, VoidCallback onPressed) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 12 : 16,
              horizontal: isSmallScreen ? 16 : 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }




  @override
  void dispose() {
    _earthController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /*Widget menuButton(String text, Function onPressed) {
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
  }*/



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



  Future<void> _sayHello() async {
    String session = await SSH(ref: ref).renderInSlave(context, ref.read(rightmostRigProvider), KMLMakers.screenOverlayImage(
        Const.overLayImageLink, 2684/3000));
    if (session.isNotEmpty) {
      print(session);
    }else{
      print('Session is null');
    }
  }




  Future<void> _showLAFire() async {
    SSHSession? session = await SSH(ref: ref).sendKmlService(context: context);
    if (session != null) {
      print(session.stdout);
    }
  }

  Future<void> _cleanKML() async {
    await SSH(ref: ref).cleanKML(context);
  }

  Future<void> _cleanBalloon() async {
    await cleanBalloon(context);
  }

  Future<void> _relaunchLG() async {
    SSHSession? session = await SSH(ref: ref).relunchLG();
  }

  Future<void> _showLogo() async {
      await showSplashLogo();
  }

}

enum Planet {
  isEarth,
  isMoon,
  isMars,
}