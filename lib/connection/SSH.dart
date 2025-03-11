import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odyssey/providers/providers.dart';
import 'package:odyssey/core/widgets/widgets.dart';
import 'package:odyssey/utils/extensions.dart';

import '../kml/Balloon.dart';
import '../core/kml/KmlOverlayLoader.dart';
import '../utils/constants.dart';
import 'package:path/path.dart' as path;

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
      customWidgets.showSnackBar(
          context: context, message: e.toString(), color: Colors.red);
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
          " && sshpass -p ${ref.read(
            passwordProvider)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await ref.read(sshClientProvider)?.execute(
            '"/home/${ref.read(usernameProvider)}/bin/lg-relaunch" > /home/${ref
                .read(usernameProvider)}/log.txt');
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

  initialConnect({int i = 0}) async {
    if (i == 0) {
      await ref.read(sshClientProvider)?.run(
          "echo '${BalloonMakers
              .blankBalloon()}' > /var/www/html/kml/slave_${ref.read(
              rightmostRigProvider)}.kml");
      await ref.read(sshClientProvider)?.run(
          "echo '${KMLMakers.screenOverlayImage(Const.overLayImageLink,
              Const.splashAspectRatio)}' > /var/www/html/kml/slave_${ref.read(
              leftmostRigProvider)}.kml");
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

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("This is a Custom Toast"),
        ],
      ),
    );
  }

     sendKmlService({
      required BuildContext context,
    }) async {
      FToast fToast;
      fToast = FToast();
      fToast.init(context);
      late SftpClient? sftp;
      final projectname = 'laFire';
      final remoteKmlPath = '/var/www/html/$projectname.kml';
      final remoteKmlListPath = '/var/www/html/kmls.txt';
      final localPath = path.join(Directory.current.path, 'lib', 'connection', 'Fire.kml');
      print('Attempting to access file at: $localPath');

      try {
        _client = ref.read(sshClientProvider);

        // KML upload
        sftp = await _client?.sftp();
        final bytes = await rootBundle.load('assets/Fire.kml');
        final remoteFile = await sftp?.open(remoteKmlPath,
            mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
        await remoteFile?.writeBytes(bytes.buffer.asUint8List());
        await remoteFile?.close();

        // Update KML list
        final result = await _client?.execute(
            'echo "http://lg1:81/$projectname.kml" > $remoteKmlListPath');
        if (result == null) throw 'SSH command failed';

        // Flyto command
        final flytoCommand = 'echo "flytoview=${KMLMakers.lookAtLinear(
            34.071290,-118.518887,  11, 15, 0)}" > /tmp/query.txt';
        final flytoResult = await _client?.execute(flytoCommand);
        if (flytoResult == null) throw 'Flyto command failed';

        // Show toast
        /*fToast.showToast(
          child: _showToast(),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2),
        );*/

      } catch (e) {
        print('Error: $e');
        throw e.toString();
      } finally {
        //_client?.close();
      }
    }


    cleanKML(context) async {
      try {
        //await ref.read(sshClientProvider)?.execute('echo "" > /tmp/query.txt');
        await ref.read(sshClientProvider)?.execute(
            "> /var/www/html/kmls.txt");
        await ref.read(sshClientProvider)?.run(
            "echo '${BalloonMakers
                .blankBalloon()}' > /var/www/html/kml/slave_${ref.read(
                rightmostRigProvider)}.kml");
        setRefresh(context);
      } catch (error) {
        print('Error: $error');
        //await cleanKML(context);
        // showSnackBar(
        //     context: context, message: error.toString(), color: Colors.red);
      }
    }

    cleanBalloon(context) async {
      try {
        _client = ref.read(sshClientProvider);
        if (_client == null) {
          await ref.read(sshClientProvider)?.execute(
              "echo '${BalloonMakers
                  .blankBalloon()}' > /var/www/html/kml/slave_${ref.read(
                  rightmostRigProvider)}.kml");
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

  setRefresh(context) async {
    _client = ref.read(sshClientProvider);
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref
                .read(
                passwordProvider)} | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref
                .read(
                passwordProvider)} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (error) {
      customWidgets.showSnackBar(context: context, message: "Error: $error", color: Colors.red);
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
            'echo "flytoview=${KMLMakers.orbitLookAtLinear(
                latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
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
          ref
              .read(lastGMapPositionProvider.notifier)
              .state = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: zoom,
            tilt: tilt,
            bearing: bearing,
          );
        });
        await ref.read(sshClientProvider)?.run(
            'echo "flytoview=${KMLMakers.lookAtLinear(
                latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
      } catch (error) {
        try {
          // await connectionRetry(context);
          await flyTo(context, latitude, longitude, zoom, tilt, bearing);
        } catch (e) {}
      }
    }

    stopOrbit(context) async {
      try {
        await ref.read(sshClientProvider)?.execute(
            'echo "exittour=true" > /tmp/query.txt');
      } catch (error) {
        stopOrbit(context);
      }
    }
  }