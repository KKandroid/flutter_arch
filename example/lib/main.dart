import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/flutter_arch.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with BaseViewState<MyHomePage, HomeModel> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // initState阶段使用getValue直接，从LiveData中获取数据
    _counter = model.count.getValue();
    // 观察LiveData中数据变化，第二lifecycleOwner会将观察者与State的生命周期绑定，当state 执行dispose后，观察者会自动取消注册。
    model.count.listen((t) {
      // 根据需要去更新UI
      setState(() {
        _counter = t;
      });
    }, lifecycleOwner: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            IconButton(
                iconSize: 100,
                color: Colors.amber,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyHomePage(title: "第二个"))),
                icon: const Icon(Icons.nat)),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 通过model 操作数据。
        onPressed: () => model.incrementCounter(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 实现该方法 会在initState阶段执行 创建Model
  @override
  HomeModel createModel() => HomeModel(context);
}

class HomeModel extends ViewModel {
  /// 可观测的数据
  LiveData<int> count = LiveData(0);

  HomeModel(BuildContext context) : super(context);

  @override
  void initData() {
    // 完成初始化数据工作
    count.setValue(1);
  }

  /// 提供给UI操作的数据的
  void incrementCounter() {
    var countValue = count.getValue() + 1;
    Future.delayed(
        const Duration(seconds: 3), () => count.setValue(countValue));
  }

  /// 释放资源
  @override
  void dispose() {}
}

class UserInfo {
  String name;

  UserInfo(this.name, this.account);

  String account;
}

LiveData<UserInfo> userInfo = LiveData(UserInfo("jack", "123"));

void setUserInfo(UserInfo info) {
  // 更新数据
  userInfo.setValue(info);
}

void observer(UserInfo info) {
  if (kDebugMode) {
    print("name=${info.name} & account= ${info.account}");
  }
}

void listenUserInfo() {
  // 直接获取
  userInfo.getValue();
  // 监听变化 lifecycleOwner 类型
  userInfo.listen(observer, lifecycleOwner: null);
}

void removeObserver() {
  // 手动移除
  userInfo.removeObserver(observer);
}
