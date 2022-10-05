import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chaleno/chaleno.dart';
import 'package:puppeteer/puppeteer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                  pageTitle ?? 'Loading...',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(height: 20),
                Text(
                  pageContent ?? '',
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
                ElevatedButton(
                  child: const Text('Go to Puppeteer'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecondRoute()),
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  String? pageContent;

  void scrapData() async {
    final browser = await puppeteer.launch(
      executablePath:
          '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    );

    // try catch block is used to handle exceptions
    try {
      final page = await browser.newPage();

      await page.goto('https://www.pinterest.com/search/pins/?q=flutter',
          timeout: Duration.zero);

      var items = page.waitForSelector('img');

      var list = await items;

      pageContent = await list!.propertyValue('src');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      await browser.close();
    }
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
          title: const Text('Scraping with Puppeteer'),
        ),
        body: SafeArea(
          child: pageContent == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: pageContent?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Text(
                      pageContent!,
                      style: Theme.of(context).textTheme.bodyText1,
                    );
                  },
                ),
        ));
  }
}
