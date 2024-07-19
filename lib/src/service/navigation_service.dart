import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NavigationService {
  final GlobalKey<NavigatorState> getnavigationKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigationKey => getnavigationKey;
}
