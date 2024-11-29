# flutter_arch

## arch

flutter 架构组件 包括 ViewModel LiveData 及 BaseViewState，主要作用将业务逻辑和UI解藕。

### ViewModel

ViewModel作用处理业务逻辑，并为BaseViewState 提供可观测的数据LiveData。
使用示例：

```dart
class HomeModel extends ViewModel {

  /// 可观测的数据
  LiveData count = LiveData();

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

### BaseViewState

BaseViewState 为针对State 的mixin 类，为Ui State 提供 ViewModel

使用示例：

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

///通过 with BaseViewState<MyHomePage, HomeModel>给UI 提供 HomeModel，要实现createModel方法。
class _MyHomePageState extends State<MyHomePage> with BaseViewState<MyHomePage, HomeModel> {
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
                onPressed: () =>
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyHomePage(title: "第二个"))),
                icon: const Icon(Icons.nat)),
            Text(
              '$_counter',
              style: Theme
                  .of(context)
                  .textTheme
                  .headline4,
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

### LiveData<T> 可观测的数据

LiveData 是数据持有类，可通过`listen`方法，观测的数据 数据变化，listen的第一个参数为数据变化的回调，
可选参数`lifecycleOwner` 类型为BaseViewState，指定lifecycleOwner时 数据变化的回调会在 BaseViewState
dispose时自动取消注册，如果LiveData 不指定lifecycleOwner，则需要手动移除数据变化的回调。

可以在任意位置创建（全局或者ViewModel），全局使用可以作为全局状态共享。在ViewModel可以为特定的UI提供数据。

```dart
class UserInfo {
  String name;

  UserInfo(this.name, this.account);

  String account;
}

LiveData<UserInfo> userInfo = LiveData();

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

## base  添加基于 MVVM 架构页面基类

## event_bus 添加基于架构组件的 事件总线

## global state 内存本地双缓存且可观测的全局状态

## global loading 全局的异步阻塞交互的 loading

## toast 组件 支持自定义toast视图 和 长短时间toast 多个toast同时显示


