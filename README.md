## metalpha_arch 
flutter 架构组件 包括 MAViewModel MALiveData 及 MABaseView，主要作用将业务逻辑和UI解藕。

### MAViewModel
MAViewModel作用处理业务逻辑，并为MABaseView 提供可观测的数据MALiveData。
使用示例：

```dart
class HomeModel extends MAViewModel {
	
	/// 可观测的数据
  MALiveData count = MALiveData();

  HomeModel(BuildContext context) : super(context);

  @override
  void initData() {
  	 // 完成初始化数据工作
    count.setValue(1);
  }
	
	/// 提供给UI操作的数据的
  void incrementCounter() {
    var countValue = count.getValue() + 1;
    Future.delayed(const Duration(seconds: 3), () => count.setValue(countValue));

  }
	/// 释放资源
  @override
  void dispose() {}
}
```


### MABaseView 
MABaseView 为针对State 的mixin 类，为Ui State 提供 MAViewModel

使用示例：

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

///通过 with MABaseView<MyHomePage, HomeModel>给UI 提供 HomeModel，要实现createModel方法。
class _MyHomePageState extends State<MyHomePage> with MABaseView<MyHomePage, HomeModel> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // initState阶段使用getValue直接，从MALiveData中获取数据 
    _counter = model.count.getValue();
     // 观察MALiveData中数据变化，第二lifecycleOwner会将观察者与State的生命周期绑定，当state 执行dispose后，观察者会自动取消注册。 
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
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyHomePage(title: "第二个"))),
                icon: const Icon(Icons.nat)),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
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
```

### MALiveData<T> 可观测的数据 
MALiveData 是数据持有类，可通过`listen`方法，观测的数据 数据变化，listen的第一个参数为数据变化的回调，可选参数`lifecycleOwner` 类型为MABaseView，指定lifecycleOwner时 数据变化的回调会在 MABaseView dispose时自动取消注册，如果MALiveData 不指定lifecycleOwner，则需要手动移除数据变化的回调。 

可以在任意位置创建（全局或者MAViewModel），全局使用可以作为全局状态共享。在MAViewModel可以为特定的UI提供数据。

```dart
class UserInfo {
  String name;

  UserInfo(this.name, this.account);

  String account;
}

MALiveData<UserInfo> userInfo = MALiveData();

void setUserInfo(UserInfo info) {
  // 更新数据
  userInfo.setValue(info);
}

void observer(UserInfo info) {
  print("name=${info.name} & account= ${info.account}");
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
```



