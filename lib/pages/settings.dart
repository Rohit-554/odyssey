import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:odyssey/utils/string_constants.dart';
import 'package:odyssey/widget/show_connection.dart';

import '../connection/SSH.dart';
import '../providers/connection_providers.dart';
import '../utils/theme.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  TextEditingController ipController = TextEditingController(text: '');
  TextEditingController usernameController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController portController = TextEditingController(text: '');
  TextEditingController rigsController = TextEditingController(text: '');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  late SSH ssh;
  initTextControllers() {
    ipController.text = ref.read(ipProvider);
    usernameController.text = ref.read(usernameProvider);
    passwordController.text = ref.read(passwordProvider);
    portController.text = ref.read(portProvider).toString();
    rigsController.text = ref.read(rigsProvider).toString();
  }
  /*void _doSomething() async {
    Timer(Duration(seconds: 3), () {
      _btnController.success();
    });
  }*/

  updateProviders() {
    ref.read(ipProvider.notifier).state = ipController.text;
    ref.read(usernameProvider.notifier).state = usernameController.text;
    ref.read(passwordProvider.notifier).state = passwordController.text;
    ref.read(portProvider.notifier).state = int.parse(portController.text);
    ref.read(rigsProvider.notifier).state = int.parse(rigsController.text);
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG(context);
    ref.read(connectedProvider.notifier).state = result!;
  }

 /* Future<void> _execute() async {
    SSHSession? session = await ssh.execute();
    if (session != null) {
      print(session.stdout);
    }
  }*/

  @override
  void initState() {
    super.initState();
    initTextControllers();
    ssh = SSH(ref: ref);
  }

  @override
  Widget build(BuildContext context) {
    bool isConnectedToLg = ref.watch(connectedProvider);
    return SafeArea(
      child: Scaffold(
        appBar:  AppBar(
            backgroundColor: ThemesDark().tabBarColor,
            title: Text(
              StringConstants.Settings,
              style: TextStyle(color: ThemesDark().oppositeColor),
            ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: ThemesDark().oppositeColor,
          ),
        ),

        backgroundColor: ThemesDark().normalColor,
        body: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              ShowConnection(status: isConnectedToLg),
              customInput(ipController, "IP Address"),
              customInput(usernameController, "Username"),
              customInput(passwordController, "Password"),
              customInput(portController, "Port"),
              customInput(rigsController, "Rigs"),
              ElevatedButton(
                onPressed: () {
                  updateProviders();
                  if (!isConnectedToLg) _connectToLG();
                },
                child: Text('Connect to LG'),
              ),
             /* AnimatedButton(
                width: 200,
                height: 70,
                text: StringConstants.connectToLg,
                isReverse: false,
                selectedTextColor: Colors.black,
                transitionType: TransitionType.LEFT_TO_RIGHT,
                selectedBackgroundColor: Colors.green,
                textStyle: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal
                ),
                onPress: () {
                  _cleanKml();
                  _cleanBalloon();
                  },
                borderRadius: 50,
                borderWidth: 2,
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget customInput(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: TextFormField(
        style: TextStyle(color: ThemesDark().oppositeColor),
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: ThemesDark().oppositeColor),
        ),
      ),
    );
  }

  Future<void> _cleanKml() async {
    SSHSession? session = await SSH(ref: ref).cleanKML(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  Future<void> _cleanBalloon() async {

    SSHSession? session = await SSH(ref: ref).cleanBalloon(context);
    if (session != null) {
      print(session.stdout);
    }else{
      print('Session is null');
    }
  }

  @override
  void dispose() {
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    portController.dispose();
    rigsController.dispose();
    super.dispose();
  }
}