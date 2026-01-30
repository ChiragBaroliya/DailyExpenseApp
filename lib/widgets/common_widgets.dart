import 'package:flutter/material.dart';

// Shared simple widgets for the app

Widget smallVerticalGap() => const SizedBox(height: 8);
Widget mediumVerticalGap() => const SizedBox(height: 16);

class EmptyPlaceholder extends StatelessWidget {
  final String message;
  const EmptyPlaceholder({super.key, this.message = 'Nothing here yet'});

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}
