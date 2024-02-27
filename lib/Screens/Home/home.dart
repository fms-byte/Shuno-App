//Shuno


import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shuno/CustomWidgets/drawer.dart';
import 'package:shuno/CustomWidgets/gradient_containers.dart';
import 'package:shuno/CustomWidgets/miniplayer.dart';
import 'package:shuno/CustomWidgets/snackbar.dart';
import 'package:shuno/Helpers/backup_restore.dart';
import 'package:shuno/Helpers/downloads_checker.dart';
import 'package:shuno/Helpers/github.dart';
import 'package:shuno/Helpers/route_handler.dart';
import 'package:shuno/Helpers/update.dart';
import 'package:shuno/Screens/Common/routes.dart';
import 'package:shuno/Screens/Home/home_screen.dart';
import 'package:shuno/Screens/Library/library.dart';
import 'package:shuno/Screens/Player/audioplayer.dart';
import 'package:shuno/Screens/Search/search.dart';
import 'package:shuno/Services/ext_storage_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  String? appVersion;

  bool checkUpdate =
      Hive.box('settings').get('checkUpdate', defaultValue: false) as bool;
  bool autoBackup =
      Hive.box('settings').get('autoBackup', defaultValue: false) as bool;
  List sectionsToShow = Hive.box('settings').get(
    'sectionsToShow',
    defaultValue: ['Home', 'Search', 'Library'],
  ) as List;
  DateTime? backButtonPressTime;
  final bool useDense = false;

  void callback() {
    sectionsToShow = Hive.box('settings').get(
      'sectionsToShow',
      defaultValue: ['Home', 'Search', 'Library'],
    ) as List;
    onItemTapped(0);
    setState(() {});
  }

  void onItemTapped(int index) {
    _selectedIndex.value = index;
    _controller.jumpToTab(
      index,
    );
  }

  // Future<bool> handleWillPop(BuildContext? context) async {
  //   if (context == null) return false;
  //   final now = DateTime.now();
  //   final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
  //       backButtonPressTime == null ||
  //           now.difference(backButtonPressTime!) > const Duration(seconds: 3);

  //   if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
  //     backButtonPressTime = now;
  //     ShowSnackBar().showSnackBar(
  //       context,
  //       AppLocalizations.of(context)!.exitConfirm,
  //       duration: const Duration(seconds: 2),
  //       noAction: true,
  //     );
  //     return false;
  //   }
  //   return true;
  // }

  void checkVersion() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appVersion = packageInfo.version;

      if (checkUpdate) {
        Logger.root.info('Checking for update');
        GitHub.getLatestVersion().then((String version) async {
          if (compareVersion(
            version,
            appVersion!,
          )) {
            // List? abis =
            //     await Hive.box('settings').get('supportedAbis') as List?;

            // if (abis == null) {
            //   final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
            //   final AndroidDeviceInfo androidDeviceInfo =
            //       await deviceInfo.androidInfo;
            //   abis = androidDeviceInfo.supportedAbis;
            //   await Hive.box('settings').put('supportedAbis', abis);
            // }

            Logger.root.info('Update available');
            ShowSnackBar().showSnackBar(
              context,
              AppLocalizations.of(context)!.updateAvailable,
              duration: const Duration(seconds: 15),
              action: SnackBarAction(
                textColor: Theme.of(context).colorScheme.secondary,
                label: AppLocalizations.of(context)!.update,
                onPressed: () {
                  Navigator.pop(context);
                  launchUrl(
                    Uri.parse('https://github.com/shuno-cms'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            );
          } else {
            Logger.root.info('No update available');
          }
        });
      }
      if (autoBackup) {
        final List<String> checked = [
          AppLocalizations.of(
            context,
          )!
              .settings,
          AppLocalizations.of(
            context,
          )!
              .downs,
          AppLocalizations.of(
            context,
          )!
              .playlists,
        ];
        final List playlistNames = Hive.box('settings').get(
          'playlistNames',
          defaultValue: ['Favorite Songs'],
        ) as List;
        final Map<String, List> boxNames = {
          AppLocalizations.of(
            context,
          )!
              .settings: ['settings'],
          AppLocalizations.of(
            context,
          )!
              .cache: ['cache'],
          AppLocalizations.of(
            context,
          )!
              .downs: ['downloads'],
          AppLocalizations.of(
            context,
          )!
              .playlists: playlistNames,
        };
        final String autoBackPath = Hive.box('settings').get(
          'autoBackPath',
          defaultValue: '',
        ) as String;
        if (autoBackPath == '') {
          ExtStorageProvider.getExtStorage(
            dirName: 'Shuno/Backups',
            writeAccess: true,
          ).then((value) {
            Hive.box('settings').put('autoBackPath', value);
            createBackup(
              context,
              checked,
              boxNames,
              path: value,
              fileName: 'shuno_AutoBackup',
              showDialog: false,
            );
          });
        } else {
          createBackup(
            context,
            checked,
            boxNames,
            path: autoBackPath,
            fileName: 'shuno_AutoBackup',
            showDialog: false,
          );
        }
      }
    });
    downloadChecker();
  }

  final PageController _pageController = PageController();
  final PersistentTabController _controller = PersistentTabController();

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool rotated = MediaQuery.sizeOf(context).height < screenWidth;
    final miniplayer = MiniPlayer();
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            if (rotated)
              SafeArea(
                child: ValueListenableBuilder(
                  valueListenable: _selectedIndex,
                  builder:
                      (BuildContext context, int indexValue, Widget? child) {
                    return NavigationRail(
                      minWidth: 70.0,
                      groupAlignment: 0.0,
                      backgroundColor:
                          // Colors.transparent,
                          Theme.of(context).cardColor,
                      selectedIndex: indexValue,
                      onDestinationSelected: (int index) {
                        onItemTapped(index);
                      },
                      labelType: screenWidth > 1050
                          ? NavigationRailLabelType.selected
                          : NavigationRailLabelType.none,
                      selectedLabelTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelTextStyle: TextStyle(
                        color: Theme.of(context).iconTheme.color,
                      ),
                      selectedIconTheme: Theme.of(context).iconTheme.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                      unselectedIconTheme: Theme.of(context).iconTheme,
                      useIndicator: screenWidth < 1050,
                      indicatorColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      leading: homeDrawer(
                        context: context,
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      destinations: sectionsToShow.map((e) {
                        switch (e) {
                          case 'Home':
                            return NavigationRailDestination(
                              icon: const Icon(Icons.home_rounded),
                              label: Text(AppLocalizations.of(context)!.home),
                            );

                          case 'Search':
                            return NavigationRailDestination(
                              icon: const Icon(Icons.search),
                              label: Text(AppLocalizations.of(context)!.search),
                            );

                          case 'Library':
                            return NavigationRailDestination(
                              icon: const Icon(Icons.my_library_music_rounded),
                              label:
                                  Text(AppLocalizations.of(context)!.library),
                            );
                          default:
                            return NavigationRailDestination(
                              icon: const Icon(Icons.home_rounded),
                              label: Text(AppLocalizations.of(context)!.home),
                            );
                        }
                      }).toList(),
                    );
                  },
                ),
              ),
            Expanded(
              child: PersistentTabView.custom(
                context,
                controller: _controller,
                itemCount: sectionsToShow.length,
                navBarHeight: (rotated ? 55 : 55 + 70) + (useDense ? 0 : 15),
                onItemTapped: onItemTapped,
                routeAndNavigatorSettings:
                    CustomWidgetRouteAndNavigatorSettings(
                  routes: namedRoutes,
                  onGenerateRoute: (RouteSettings settings) {
                    if (settings.name == '/player') {
                      return PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) => const PlayScreen(),
                      );
                    }
                    return HandleRoute.handleRoute(settings.name);
                  },
                ),
                customWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    miniplayer,
                    if (!rotated)
                      ValueListenableBuilder(
                        valueListenable: _selectedIndex,
                        builder: (
                          BuildContext context,
                          int indexValue,
                          Widget? child,
                        ) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            height: 60,
                            child: BottomNavigationBar(
                              currentIndex: indexValue,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.9),
                              onTap: (index) {
                                onItemTapped(index);
                              },
                              items: _navBarItems(context),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                screens: sectionsToShow.map((e) {
                  switch (e) {
                    case 'Home':
                      return const SafeArea(child: HomeScreen());
                    case 'Library':
                      return const LibraryPage();
                    case 'Search':
                      return const SearchPage(query: "");
                    default:
                      return const SafeArea(child: HomeScreen());
                  }
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _navBarItems(BuildContext context) {
    return sectionsToShow.map((section) {
      // Mapping each section to a BottomNavigationBarItem
      switch (section) {
        case 'Home':
          return BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: AppLocalizations.of(context)!.home,
          );
        case 'Search':
          return BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppLocalizations.of(context)!.search,
          );
        case 'Library':
          return BottomNavigationBarItem(
            icon: const Icon(Icons.my_library_music_rounded),
            label: AppLocalizations.of(context)!.library,
          );
        default:
          return BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: AppLocalizations.of(context)!.home,
          );
      }
    }).toList();
  }
}
