import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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
      home: const CardSwipe(),
    );
  }
}


class CardSwipe extends StatefulWidget {
  const CardSwipe({super.key});

  @override
  State<CardSwipe> createState() => _CardSwipeState();
}

class _CardSwipeState extends State<CardSwipe> {
  late List<String> fileNames;

  @override
  void initState() {
    super.initState();
    _resetCards();
  }

  void _resetCards() {
    fileNames = [
      'https://cdn.pixabay.com/photo/2013/07/18/10/56/domino-163523_960_720.jpg',
      'https://cdn.pixabay.com/photo/2012/12/27/19/41/halloween-72939_960_720.jpg',
      'https://cdn.pixabay.com/photo/2015/12/12/22/35/snowman-1090261_960_720.jpg',
      'https://cdn.pixabay.com/photo/2023/02/13/18/00/bird-7787970_960_720.jpg',
      'https://cdn.pixabay.com/photo/2016/05/26/14/39/parrot-1417286_960_720.png',
      'https://cdn.pixabay.com/photo/2014/11/08/01/20/bald-eagle-521492_960_720.jpg',
      'https://cdn.pixabay.com/photo/2023/02/13/05/58/doodle-7786568_960_720.png'
    ];
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: MyAppBar(_resetCards),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5733), Color(0xFF5733)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: Stack(
                          children: [
                            for (final fileName in fileNames)
                              SwipeableCard(
                                imageAssetName: fileName,
                                onSwiped: () {
                                  setState(() {
                                    fileNames.remove(fileName);
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: [
                            for (final fileName in fileNames)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  fileName,
                                  fit: BoxFit.cover,
                                  width: 150,
                                ),
                              ),
                          ],
                        ),
                      ),

                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  final String imageAssetName;

  const Card({required this.imageAssetName, super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            image: NetworkImage(imageAssetName),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class SwipeableCard extends StatefulWidget {
  final String imageAssetName;
  final VoidCallback onSwiped;

  const SwipeableCard(
      {required this.onSwiped, required this.imageAssetName, super.key});

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late double _dragStartX;
  bool _isSwipingLeft = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _animation = _controller.drive(Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1, 0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: GestureDetector(
        onHorizontalDragStart: _dragStart,
        onHorizontalDragUpdate: _dragUpdate,
        onHorizontalDragEnd: _dragEnd,
        child: Card(imageAssetName: widget.imageAssetName),
      ),
    );
  }


  void _dragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
  }


  void _dragUpdate(DragUpdateDetails details) {
    var isSwipingLeft = (details.localPosition.dx - _dragStartX) < 0;
    if (isSwipingLeft != _isSwipingLeft) {
      _isSwipingLeft = isSwipingLeft;
      _updateAnimation(details.localPosition.dx);
    }

    setState(() {
      final size = context.size;

      if (size == null) {
        return;
      }

      // Calculate the amount dragged in unit coordinates (between 0 and 1)
      // using this widgets width.
      _controller.value =
          (details.localPosition.dx - _dragStartX).abs() / size.width;
    });
  }


  void _dragEnd(DragEndDetails details) {
    final size = context.size;

    if (size == null) {
      return;
    }

    var velocity = (details.velocity.pixelsPerSecond.dx / size.width).abs();
    _animate(velocity: velocity);
  }

  void _updateAnimation(double dragPosition) {
    _animation = _controller.drive(Tween<Offset>(
      begin: Offset.zero,
      end: _isSwipingLeft ? const Offset(-1, 0) : const Offset(1, 0),
    ));
  }

  void _animate({double velocity = 0}) {
    var description =
    const SpringDescription(mass: 50, stiffness: 1, damping: 1);
    var simulation =
    SpringSimulation(description, _controller.value, 1, velocity);
    _controller.animateWith(simulation).then<void>((_) {
      widget.onSwiped();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  MyAppBar(this._resetCards,{Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);
  var _resetCards;
  @override
  final Size preferredSize;

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutBack);
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(child: const Text('Styled Picture Cards')),
      actions: [
        Container(width: 100,
          child: ScaleTransition(
            scale: _animation,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(fontSize: 16),
                elevation: 4,
              ),
              child: const Text('Refill'),
              onPressed: () {
                setState(() {
                  widget._resetCards();
                });
              },
            ),
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
