import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../connection/SSH.dart';
import '../providers/connection_providers.dart';
import 'NamePlaceBallon.dart';

class BalloonLoader {
  WidgetRef ref;
  BuildContext context;
  bool mounted;

  BalloonLoader({
    required this.ref,
    required this.context,
    required this.mounted,
  });

  loadDashBoardBalloon() async {
    print('Loading Dashboard Balloon');
    /*var initialMapPosition = CameraPosition(
      target: ref.read(cityDataProvider)!.location,
      zoom: Const.appZoomScale,
    );*/
    ref.read(lastBalloonProvider.notifier).state = await SSH(ref: ref).renderInSlave(
      context,
      ref.read(rightmostRigProvider),
      BalloonMakers.dashboardBalloon(),
    ).catchError((onError) {
      print('Error: $onError');
    });

  }

  loadKmlBalloon(String kmlName, String fileSize) async {
    String name = '<h3>Playing KML: $kmlName</h3>\n';
    String size = '<h3>KML file size: $fileSize</h3>\n';
    String processKml =
    ref.read(lastBalloonProvider).replaceAll('<img', '$name$size<img');
    await SSH(ref: ref)
        .renderInSlave(context, ref.read(rightmostRigProvider), processKml);
  }

  restoreBalloon(String kmlName, String fileSize) async =>
      await SSH(ref: ref).renderInSlave(context, ref.read(rightmostRigProvider),
          ref.read(lastBalloonProvider));

}