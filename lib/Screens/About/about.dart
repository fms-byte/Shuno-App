//Shuno

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shuno/CustomWidgets/gradient_containers.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double separationHeight = MediaQuery.sizeOf(context).height * 0.035;

    return GradientContainer(
      child: Stack(
        children: [
          Positioned(
            left: MediaQuery.sizeOf(context).width / 2,
            top: MediaQuery.sizeOf(context).width / 5,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: const Image(
                fit: BoxFit.fill,
                image: AssetImage(
                  'assets/icon-white-trans.png',
                ),
              ),
            ),
          ),
          const GradientContainer(
            child: null,
            opacity: true,
          ),
          Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondary,
              elevation: 0,
              title: Text(
                AppLocalizations.of(context)!.about,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const SizedBox(
                          width: 150,
                          child: Image(
                            image: AssetImage('assets/ic_launcher.png'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('v$appVersion'),
                    ],
                  ),
                  SizedBox(
                    height: separationHeight,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    child: Column(
                      children: [
                        const Text(
                          'Android App Development Project : 6th Semester ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),

                        const Text('Jahangir and Farhan',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            launchUrl(
                              Uri.parse(
                                'https://github.com/jhm69/Shuno',
                              ),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width / 4,
                            child: Image(
                              image: Theme.of(context).brightness ==
                                  Brightness.dark
                                  ? const AssetImage(
                                'assets/GitHub_Logo_White.png',
                              )
                                  : const AssetImage('assets/GitHub_Logo.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: separationHeight,
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
