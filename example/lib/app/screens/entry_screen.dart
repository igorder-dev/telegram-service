import 'package:flutter/material.dart';
import 'package:telegram_service_example/app/widgets/app_scaffold.dart';

class EntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Text(
          'Welcome!',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}
