import 'package:flutter/material.dart';
import 'package:chaleno/chaleno.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Scraped Wiki Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? pageTitle, pageContent;
  List<String?>? pageLinks;

  void scrapData() async {
    const url = 'https://en.wikipedia.org/wiki/Web_scraping';
    var response = await Chaleno().load(url);

    pageTitle = response?.getElementsByClassName('mw-page-title-main')[0].text;
    pageContent =
        response?.getElementsByClassName('mw-parser-output>p')[0].text;
    pageLinks = response
        ?.getElementsByClassName('toc>ul>li>a')
        .map((e) => e.text)
        .toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    scrapData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  pageTitle ?? 'loading...',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 20),
                Text(
                  pageContent ?? '',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 20),
                Text(
                  'Contents',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: pageLinks?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Text(
                        pageLinks?[index] ?? '',
                        style: Theme.of(context).textTheme.bodyText1,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
