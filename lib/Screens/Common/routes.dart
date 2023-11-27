//Shuno

import 'package:shuno/Screens/About/about.dart';
import 'package:shuno/Screens/Home/home.dart';
import 'package:shuno/Screens/Library/downloads.dart';
import 'package:shuno/Screens/Library/nowplaying.dart';
import 'package:shuno/Screens/Library/playlists.dart';
import 'package:shuno/Screens/Library/recent.dart';
import 'package:shuno/Screens/Library/stats.dart';
import 'package:shuno/Screens/Login/auth.dart';
import 'package:shuno/Screens/Login/register.dart';
import 'package:shuno/Screens/Login/pref.dart';
import 'package:shuno/Screens/Settings/new_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Widget initialFuntion() {
  print(Hive.box('settings').get('userId'));
  print(Hive.box('settings').get('username'));
  print(Hive.box('settings').get('email'));
  return Hive.box('settings').get('userId') != null ? HomePage() : AuthScreen();
}

final Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => initialFuntion(),
  '/pref': (context) => const PrefScreen(),
  '/setting': (context) => const NewSettingsPage(),
  '/about': (context) => AboutScreen(),
  '/playlists': (context) => PlaylistScreen(),
  '/nowplaying': (context) => NowPlaying(),
  '/recent': (context) => RecentlyPlayed(),
  '/downloads': (context) => const Downloads(),
  '/stats': (context) => const Stats(),
  '/register': (context) => Register(),
};
