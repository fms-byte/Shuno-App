import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shuno/CustomWidgets/gradient_containers.dart';
import 'package:shuno/CustomWidgets/snackbar.dart';
import 'package:shuno/Helpers/github.dart';
import 'package:shuno/Helpers/update.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    setState(
      () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(
              context,
            )!
                .about,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10.0,
                    10.0,
                    10.0,
                    10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .version,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .versionSub,
                        ),
                        onTap: () {
                          ShowSnackBar().showSnackBar(
                            context,
                            AppLocalizations.of(
                              context,
                            )!
                                .checkingUpdate,
                            noAction: true,
                          );

                          GitHub.getLatestVersion().then(
                            (String latestVersion) async {
                              if (compareVersion(
                                latestVersion,
                                appVersion!,
                              )) {
                                List? abis = await Hive.box('settings')
                                    .get('supportedAbis') as List?;

                                if (abis == null) {
                                  final DeviceInfoPlugin deviceInfo =
                                      DeviceInfoPlugin();
                                  final AndroidDeviceInfo androidDeviceInfo =
                                      await deviceInfo.androidInfo;
                                  abis = androidDeviceInfo.supportedAbis;
                                  await Hive.box('settings')
                                      .put('supportedAbis', abis);
                                }
                                ShowSnackBar().showSnackBar(
                                  context,
                                  AppLocalizations.of(context)!.updateAvailable,
                                  duration: const Duration(seconds: 15),
                                  action: SnackBarAction(
                                    textColor:
                                        Theme.of(context).colorScheme.secondary,
                                    label: AppLocalizations.of(context)!.update,
                                    onPressed: () {
                                      Navigator.pop(context);
                                      launchUrl(
                                        Uri.parse(
                                          'https://sangwan5688.github.io/download/',
                                        ),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .latest,
                                );
                              }
                            },
                          );
                        },
                        trailing: Text(
                          'v$appVersion',
                          style: const TextStyle(fontSize: 12),
                        ),
                        dense: true,
                      ),

                    ],
                  ),
                ),
              ]),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.madeBy,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
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
    );
  }
}
