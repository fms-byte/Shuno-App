//Shuno

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:shuno/CustomWidgets/empty_screen.dart';
import 'package:shuno/CustomWidgets/gradient_containers.dart';
import 'package:shuno/CustomWidgets/image_card.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List notification = [];
  bool added = false;

  Future<void> getSongs() async {
    notification = [
      {
        'id': 1,
        'title': 'Welcome to Shuno',
        'content':
            "Enjoy your music with Shuno, Don't forget to like and share",
        'image': 'https://images.unsplash.com/photo-1632873663943-3e3e3e3e3e3e'
      }
    ];
    added = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!added) {
      getSongs();
    }

    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Notification'),
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                notification = [];
              },
              tooltip: AppLocalizations.of(context)!.clearAll,
              icon: const Icon(Icons.clear_all_rounded),
            ),
          ],
        ),
        body: notification.isEmpty
            ? emptyScreen(
                context,
                3,
                AppLocalizations.of(context)!.nothingTo,
                15,
                AppLocalizations.of(context)!.showHere,
                50.0,
                AppLocalizations.of(context)!.playSomething,
                23.0,
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                shrinkWrap: true,
                itemCount: notification.length,
                itemExtent: 70.0,
                itemBuilder: (context, index) {
                  return notification.isEmpty
                      ? const SizedBox()
                      : Dismissible(
                          key: Key(notification[index]['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: const ColoredBox(
                            color: Colors.redAccent,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete_outline_rounded),
                                ],
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            notification.removeAt(index);
                            setState(() {});
                            Hive.box('cache').put('recentSongs', notification);
                          },
                          child: ListTile(
                            leading: imageCard(
                              imageUrl: notification[index]['image'].toString(),
                            ),
                            title: Text(
                              '${notification[index]["title"]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${notification[index]["content"]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              // Toast message to sho
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${notification[index]["title"]}',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
      ),
    );
  }
}
