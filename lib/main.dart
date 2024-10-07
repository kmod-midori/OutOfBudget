import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:out_of_budget/db.dart';
import 'package:out_of_budget/pages/accounts_page.dart';
import 'package:out_of_budget/pages/edit_account_page.dart';
import 'package:out_of_budget/pages/edit_transaction_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDb = await initDb();
  Get.put(appDb);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Out of Budget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pvController = usePageController();
    final currentPage = useState(0);

    Widget? fab;
    switch (currentPage.value) {
      case 0:
        fab = FloatingActionButton(
          onPressed: () {
            Get.to(() => EditTransactionPage());
          },
          tooltip: '记录收支',
          child: const Icon(Icons.add),
        );
        break;
      default:
        fab = null;
    }

    List<Widget> actions = [];
    switch (currentPage.value) {
      case 0:
        actions.add(IconButton(
          icon: const Icon(Icons.add_card),
          onPressed: () {
            Get.to(() => EditAccountPage());
          },
        ));
        break;
      default:
        break;
    }

    String title = "";
    switch (currentPage.value) {
      case 0:
        title = "账户总览";
        break;
      case 1:
        title = "统计";
        break;
      case 2:
        title = "设置";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: actions,
      ),
      body: PageView.builder(
        controller: pvController,
        itemCount: 3,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return const AccountsPage();
            case 1:
              return const Text("1");
            case 2:
              return const Text("2");
          }
          return null;
        },
      ),
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance), label: '账户'),
          NavigationDestination(icon: Icon(Icons.line_axis), label: '统计'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
        onDestinationSelected: (index) {
          pvController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          currentPage.value = index;
        },
        selectedIndex: currentPage.value,
      ),
    );
  }
}
