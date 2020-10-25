import 'dart:io';

import 'package:flutter/material.dart';
import 'package:telegram_service_example/app/widgets/app_scaffold.dart';

class LogOutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            size: 50,
            color: Colors.redAccent,
          ),
          Text(
            "Ops!\n You was logged out!.\n Please restart application to sing-in again.",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            child: Text("Terminate application"),
            onPressed: () => exit(0),
          )
        ],
      ),
    );
  }
}
