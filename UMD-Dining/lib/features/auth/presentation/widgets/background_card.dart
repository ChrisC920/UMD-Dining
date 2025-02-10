import 'package:flutter/material.dart';

class BackgroundCard extends StatefulWidget {
  const BackgroundCard({
    super.key,
    required this.currentPageIndex,
  });

  final double currentPageIndex;

  @override
  State<BackgroundCard> createState() => _BackgroundCardState();
}

class _BackgroundCardState extends State<BackgroundCard> {
  late PageController _cardPageController;
  double _cardPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController()
      ..addListener(() {
        setState(() {
          _cardPageIndex = _cardPageController.page ?? 0;
        });
      });
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  // Watch for changes in the parent's currentPageIndex
  @override
  void didUpdateWidget(BackgroundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPageIndex != oldWidget.currentPageIndex) {
      _cardPageController.animateToPage(
        widget.currentPageIndex.round(),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _updateCurrentPageIndex(int index) {
    // _cardPageController.jumpToPage(index);
    _cardPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: _cardPageIndex <= 1 ? 650 - _cardPageIndex * 400 : 250,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        child: Stack(
          children: [
            // Remove the glass effect background since we're using the container above

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Persistent back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),

                // Changing content
                Expanded(
                  child: IndexedStack(
                    index: _cardPageIndex.round(),
                    children: const [
                      // Your existing pages...
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
