import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/services/config_service.dart';
import 'data/services/location_service.dart';
import 'presentation/cubit/tracking_cubit.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const TrackerApp());
}

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => TrackingCubit(
          configService: ConfigService(),
          locationService: LocationService(),
        )..initialize(),
        child: const HomePage(),
      ),
    );
  }
}
