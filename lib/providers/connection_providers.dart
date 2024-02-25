import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../kml/NamePlaceBallon.dart';

StateProvider<SSHClient?> sshClientProvider = StateProvider(
      (ref) => null,
);

StateProvider<String> ipProvider = StateProvider((ref) => '192.168.201.3');
StateProvider<String> usernameProvider = StateProvider((ref) => 'lg');
StateProvider<String> passwordProvider = StateProvider((ref) => 'lg');
StateProvider<int> portProvider = StateProvider((ref) => 22);
StateProvider<int> rigsProvider = StateProvider((ref) => 3);
StateProvider<bool> connectedProvider = StateProvider((ref) => false);
StateProvider<int> leftmostRigProvider = StateProvider((ref) => 3);
StateProvider<int> rightmostRigProvider = StateProvider((ref) => 2);
StateProvider<String> lastBalloonProvider = StateProvider((ref) => BalloonMakers.blankBalloon());
StateProvider<bool> isLoadingProvider = StateProvider((ref) => false);
StateProvider<CameraPosition?> lastGMapPositionProvider =
StateProvider((ref) => null);

setRigs(int rig, WidgetRef ref) {
  ref.read(rigsProvider.notifier).state = rig;
  ref.read(leftmostRigProvider.notifier).state = (rig) ~/ 2 + 2;
  ref.read(rightmostRigProvider.notifier).state = (rig) ~/ 2 + 1;
}