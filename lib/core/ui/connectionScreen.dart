import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odyssey/utils/string_constants.dart';
import 'package:odyssey/core/widgets/show_connection.dart';

import '../../connection/SSH.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';

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
  late SSH ssh;
  initTextControllers() {
    ipController.text = ref.read(ipProvider);
    usernameController.text = ref.read(usernameProvider);
    passwordController.text = ref.read(passwordProvider);
    portController.text = ref.read(portProvider).toString();
    rigsController.text = ref.read(rigsProvider).toString();
  }

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
        appBar: AppBar(
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
        // Wrap the body in a SingleChildScrollView to handle overflow
        body: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive padding based on screen width
              double horizontalPadding = constraints.maxWidth * 0.1; // 10% of screen width
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ShowConnection(status: isConnectedToLg),
                  ),
                  Padding(
                    // Use responsive padding
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Wrap form in a Container with max width for larger screens
                        Container(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Column(
                            children: [
                              customInput(ipController, "IP Address"),
                              customInput(usernameController, "Username"),
                              customInput(passwordController, "Password"),
                              customInput(portController, "Port"),
                              customInput(rigsController, "Rigs"),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      updateProviders();
                                      if (!isConnectedToLg) _connectToLG();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Text(
                                        'Connect to LG',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget customInput(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        style: TextStyle(color: ThemesDark().oppositeColor),
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: ThemesDark().oppositeColor),
          // Add border for better visibility
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ThemesDark().oppositeColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ThemesDark().oppositeColor),
          ),
          // Add padding inside the text field
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
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