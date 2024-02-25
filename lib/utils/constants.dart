import 'package:google_maps_flutter/google_maps_flutter.dart';

class Const {
  static const overLayImageLink = 'https://raw.githubusercontent.com/Rohit-554/LaserSlidesFlutter/master/skml.png';
  static double appBarHeight = 80;
  static double tabBarWidthDivider = 5;
  static double longitude = 87.296992;
  static double latitude = 23.547625;
  static double heading = 0.0;
  static double tilt = 0.0;
  static double range = 11;
  static double splashAspectRatio = 2864 / 3000;
  static double lgZoomScale = 130000000.0;
  static double appZoomScale = 11;
  static double tourZoomScale = 16;
  static double orbitZoomScale = 13;
  static double defaultZoomScale = 2;
  static double dashboardUIRoundness = 20;
  static double dashboardUISpacing = 10;
  static double dashboardUIHeightFactor = 0.65;
  static Duration animationDuration = const Duration(milliseconds: 375);
  static double animationDurationDouble = 375;
  static Duration screenshotDelay = const Duration(milliseconds: 1000);
  static double animationDistance = 50;
  static double orbitRange = 40000;
  static double tabBarTextSize = 17;
  static double appBarTextSize = 18;
  static double homePageTextSize = 17;
  static double dashboardTextSize = 16;
  static double tourTextSize = 17;
  static double dashboardChartTextSize = 17;
  static String kmlOrbitFileName = 'Orbit';
  static String kmlCustomFileName = 'custom_kml';
  static String dashboardBalloonFileName = 'dashboard_balloon';
  static String dashboardBalloonFileLocation = '/var/www/html/';
  static List<String> availableLanguages = [
    'English',
    'Spanish',
    'Russian',
    'French',
    'Greek',
    'Swedish',
    'German',
  ];
  static List<String> availableLanguageCodes = [
    'en',
    'es',
    'ru',
    'fr',
    'el',
    'sv',
    'de',
  ];
  static CameraPosition initialMapPosition = const CameraPosition(
    target: LatLng(51.4769, 0.0),
    zoom: 2,
  );
}
