import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GraphView(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Offset _offset = Offset(10, 10); //Panドラッグ時のポジション
  double _radians = 0.0; //Scaleの回転値
  double _scale = 1.0; //Scaleのスケール値
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          maxScale: 10,
          child: GestureDetector(
            // 回転とスケールの値を更新
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                _radians = details.rotation;
                _scale = details.scale;
              });
            },
            child: Transform.rotate(
              angle: _radians, // 回転の値
              child: Transform.scale(
                scale: _scale, // スケールの値
                child: Image.network(
                    'https://pbs.twimg.com/profile_images/1318213516935917568/mbU5hOLy_400x400.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GraphView extends StatefulWidget {
  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> with WidgetsBindingObserver {
  // 画像ウィジェットのY座標取得用のGlobalKey
  GlobalKey imageGlobalKeyO = GlobalKey();

  // ダミーContainer(画像ウィジェット下側)のY座標取得用のGlobalKey
  GlobalKey containerGlobalKeyO = GlobalKey();

  // --------------------------------------------------------------------------
  late TransformationController _transformationController;
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController()
      ..addListener(() {
        final scale = _transformationController.value.getMaxScaleOnAxis();
        final isZoomedIn = scale > 1.0;
        if (isZoomedIn != _isZoomedIn) {
          setState(() {
            _isZoomedIn = isZoomedIn;
          });
        }
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('InteractiveViewer Test'),
        ),
        body: Center(
          // child: _interactiveviewerPattern_A(
          //     imageGlobalKeyO: imageGlobalKeyO,
          //     containerGlobalKeyO: containerGlobalKeyO),

          // ----------------------------------------------------------------------------
          child: GestureDetector(
            onDoubleTapDown: (details) {
              // 拡大中の場合は初期状態に戻す
              if (_isZoomedIn) {
                _transformationController.value = Matrix4.identity();
                return;
              }
              // 拡大した分の座標を移動させる
              const zoomScale = 3.0;
              _transformationController.value = Matrix4.identity()
                ..translate(
                  -(details.localPosition.dx * (zoomScale - 1)),
                  -(details.localPosition.dy * (zoomScale - 1)),
                )
                ..scale(zoomScale);
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 3.0,
              child: Image.network(
                "https://picsum.photos/250?image=9",
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _interactiveviewerPattern_A extends StatelessWidget {
  const _interactiveviewerPattern_A({
    super.key,
    required this.imageGlobalKeyO,
    required this.containerGlobalKeyO,
  });

  final GlobalKey<State<StatefulWidget>> imageGlobalKeyO;
  final GlobalKey<State<StatefulWidget>> containerGlobalKeyO;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      // 何も設定しなければ、拡大率は最大2.5、最小0.8
      // 但し、縮小を可能にするには、この設定が必要
      boundaryMargin: EdgeInsets.all(double.infinity),

      // ピンチイン・ピンチアウト終了後の処理
      onInteractionEnd: (details) {
        // 画像ウィジェットのGlobalKeyからRenderBox型のインスタンスを作成
        RenderBox imageBoxO =
            imageGlobalKeyO.currentContext!.findRenderObject() as RenderBox;
        // 画像上端のy座標を取得
        double imageBoxPositionYO = imageBoxO.localToGlobal(Offset.zero).dy;
        // 画像の縦幅を取得 ※これはピンチイン・ピンチアウトしても変化しない
        double imageHeightO = imageBoxO.size.height;

        print("画像上端のy座標: $imageBoxPositionYO");
        print("画像の縦幅: $imageHeightO");

        // ダミーContainerのGlobalKeyからRenderBox型のインスタンスを作成
        RenderBox containerBoxO =
            containerGlobalKeyO.currentContext!.findRenderObject() as RenderBox;
        // ダミーContainerののy座標を取得
        double containerBoxPositionYO =
            containerBoxO.localToGlobal(Offset.zero).dy;

        print("画像下部のダミーコンテナのy座標: $containerBoxPositionYO}");

        // GlobalKeyから計算した拡大率
        print(
            "GlobalKeyから計算した拡大率: ${(containerBoxPositionYO - imageBoxPositionYO) / imageHeightO}");
      },

      child: Column(
        children: [
          // 画像ウィジェット
          Image.network(
            "https://picsum.photos/250?image=9",
            key: imageGlobalKeyO,
          ),

          // 画像の下端位置把握のために設置するダミーContainer
          Container(
            key: containerGlobalKeyO,
          ),
        ],
      ),
    );
  }
}
