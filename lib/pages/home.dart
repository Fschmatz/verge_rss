import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:verge_rss/classes/feed.dart';
import 'package:verge_rss/configs/settingsPage.dart';
import 'package:verge_rss/widgets/newsTile.dart';
import 'package:webfeed/webfeed.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const String feedUrl = 'https://www.theverge.com/rss/index.xml';
  List<RssItem> articlesList = [];
  bool loading = true;

  @override
  void initState() {
    getRssData();
    super.initState();
  }

  Future<void> getRssData() async {
    var client = http.Client();
    var response = await client.get(Uri.parse(feedUrl));
    var channel = RssFeed.parse(response.body);
    setState(() {
      articlesList = channel.items!.toList();
      loading = false;
    });
    client.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Android Police'),
        actions: [
          IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Theme.of(context)
                    .textTheme
                    .headline6!
                    .color!
                    .withOpacity(0.7),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => SettingsPage(),
                      fullscreenDialog: true,
                    ));
              }),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: loading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              )
            : RefreshIndicator(
                onRefresh: getRssData,
                color: Theme.of(context).accentColor,
                child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      ListView.separated(
                        separatorBuilder: (context, index) {
                          if (!articlesList[index]
                              .categories![1]
                              .value
                              .contains('Sponsored')) {
                            return const Divider();
                          }
                          return SizedBox.shrink();
                        },
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: articlesList.length,
                        itemBuilder: (context, index) {
                          if (!articlesList[index]
                              .categories![1]
                              .value
                              .contains('Sponsored')) {
                            return NewsTile(
                              feed: Feed(
                                  data: articlesList[index].pubDate!.toString(),
                                  title: articlesList[index].title!,
                                  link: articlesList[index].link!),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ]),
              ),
      ),
    );
  }
}
