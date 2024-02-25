import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odyssey/providers/connection_providers.dart';
import 'package:odyssey/widget/widgets.dart';

import '../kml/KmlMaker.dart';
import '../kml/NamePlaceBallon.dart';
import '../utils/constants.dart';

class SSH {
  final WidgetRef ref;

  SSH({required this.ref});

  SSHClient? _client;
  final CustomWidgets customWidgets = CustomWidgets();

  //connect with rigs
  Future<bool?> connectToLG(BuildContext context) async {
    try {
      final socket = await SSHSocket.connect(
          ref.read(ipProvider), ref.read(portProvider),
          timeout: const Duration(seconds: 5));
      ref
          .read(sshClientProvider.notifier)
          .state = SSHClient(
        socket,
        username: ref.read(usernameProvider),
        onPasswordRequest: () => ref.read(passwordProvider),
      );
      ref
          .read(connectedProvider.notifier)
          .state = true;
      return true;
    } catch (e) {
      ref
          .read(connectedProvider.notifier)
          .state = false;
      print('Failed to connect: $e');
      customWidgets.showSnackBar(context: context, message: e.toString(), color: Colors.red);
      return false;
    }
  }

  //relaunch Lg
  relunchLG() async {
    try {
      _client = ref.read(sshClientProvider);
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        String cmd = """RELAUNCH_CMD="\\
          if [ -f /etc/init/lxdm.conf ]; then
            export SERVICE=lxdm
          elif [ -f /etc/init/lightdm.conf ]; then
            export SERVICE=lightdm
          else
            exit 1
          fi
          if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} start
          else
            echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} restart
          fi
          " && sshpass -p ${ref.read(passwordProvider)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await ref.read(sshClientProvider)?.execute(
            '"/home/${ref.read(usernameProvider)}/bin/lg-relaunch" > /home/${ref.read(usernameProvider)}/log.txt');
        await ref.read(sshClientProvider)?.execute(cmd);
      }

      /*if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session = await _client!.execute('lg-relaunch');
      return session;*/
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> makeOrbit() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "playtour=Orbit" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }
  initialConnect({int i=0}) async {
    if(i==0){
      await ref.read(sshClientProvider)?.run(
          "echo '${BalloonMakers.blankBalloon()}' > /var/www/html/kml/slave_${ref.read(rightmostRigProvider)}.kml");
      await ref.read(sshClientProvider)?.run(
          "echo '${KMLMakers.screenOverlayImage(Const.overLayImageLink, Const.splashAspectRatio)}' > /var/www/html/kml/slave_${ref.read(leftmostRigProvider)}.kml");
    }
  }

  Future<SSHSession?> locatePlace(String place) async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=$place" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> planetEarth() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "planet=earth" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }
  Future<SSHSession?> planetMoon() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "planet=moon" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> execute() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=Lleida" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> search(String place) async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=$place" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }
  cleanKML(context) async {
    try {
      _client = ref.read(sshClientProvider);
      await stopOrbit(context);
      await ref.read(sshClientProvider)?.execute('echo "" > /tmp/query.txt');
      await ref.read(sshClientProvider)?.execute("echo '' > /var/www/html/kmls.txt");
    } catch (error) {
      await cleanKML(context);
      // showSnackBar(
      //     context: context, message: error.toString(), color: Colors.red);
    }
  }

  cleanBalloon(context) async {
    try {
      _client = ref.read(sshClientProvider);
      if(_client == null){
        await ref.read(sshClientProvider)?.execute(
            "echo '${BalloonMakers.blankBalloon()}' > /var/www/html/kml/slave_${ref.read(rightmostRigProvider)}.kml");
        return;
      }

    } catch (error) {
      await cleanBalloon(context);
    }
  }

  showOverlay(context) async {
    try {
      _client = ref.read(sshClientProvider);

    } catch (error) {
      await showOverlay(context);
    }
  }

  Future<SSHSession?> planetMars() async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session = await ref
          .read(sshClientProvider)!
          .execute('echo "planet=mars" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  //render kml in provided slave
  Future<String> renderInSlave(context, int slaveNo, String kml) async {
    try {
      await ref
          .read(sshClientProvider)
          ?.run("echo '$kml' > /var/www/html/kml/slave_$slaveNo.kml");
      return kml;
    } catch (error) {
      customWidgets.showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
      return BalloonMakers.blankBalloon();
    }
  }

  //use to fly to particular orbit and orbit around
  flyToOrbit(context, double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    print("flytoorbit");
    try {
      print("inside");
      await ref.read(sshClientProvider)?.execute(
          'echo "flytoview=${KMLMakers.orbitLookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
    } catch (error) {
      print("error$error");
      // await connectionRetry(context);
      // await flyToOrbit(context, latitude, longitude, zoom, tilt, bearing);
    }
  }

  //this is used to fly to particular view linearly
  flyTo(context, double latitude, double longitude, double zoom, double tilt,
      double bearing) async {
    try {
      Future.delayed(Duration.zero).then((x) async {
        ref.read(lastGMapPositionProvider.notifier).state = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: zoom,
          tilt: tilt,
          bearing: bearing,
        );
      });
      await ref.read(sshClientProvider)?.run(
          'echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
    } catch (error) {
      try {
        // await connectionRetry(context);
        await flyTo(context, latitude, longitude, zoom, tilt, bearing);
      } catch (e) {}
    }
  }

  stopOrbit(context) async {
    try {
      await ref.read(sshClientProvider)?.execute('echo "exittour=true" > /tmp/query.txt');
    } catch (error) {
      stopOrbit(context);
    }
  }



}