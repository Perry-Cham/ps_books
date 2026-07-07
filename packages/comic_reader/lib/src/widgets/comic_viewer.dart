// lib/src/widgets/comic_viewer.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../models/comic_model.dart';

/// A widget that displays a comic book with pages that can be swiped through.
///
/// The [ComicViewer] uses [PhotoViewGallery] to provide a responsive and
/// interactive comic reading experience with zoom capabilities and page navigation.
/// It displays a full-screen comic viewer with optional controls for navigation.
class ComicViewer extends StatefulWidget {
  /// The comic model containing the comic data including pages to display.
  final ComicModel comic;

  /// The initial page index to display when the viewer is first opened.
  /// Defaults to 0 (first page).
  final int initialPage;

  /// Whether to show navigation controls like the app bar and page slider.
  /// Defaults to true.
  final bool showControls;

  /// The background color of the comic viewer.
  /// Defaults to black for a standard comic reading experience.
  final Color backgroundColor;

  /// Creates a comic viewer widget.
  ///
  /// The [comic] parameter is required and contains the comic data to display.
  /// [initialPage] specifies which page to show first (zero-indexed).
  /// [showControls] determines if navigation UI elements should be displayed.
  /// [backgroundColor] sets the viewer's background color.

  final void Function(double progress)? onProgressChanged;
  final void Function(double progress)? onPageChanged;
  final bool showAppBar;
  const ComicViewer({
    super.key,
    required this.comic,
    this.initialPage = 0,
    this.showControls = true,
    this.showAppBar = true,
    this.backgroundColor = Colors.black,
    this.onProgressChanged,
    this.onPageChanged,
  });

  @override
  State<ComicViewer> createState() => _ComicViewerState();
}

/// The state class for [ComicViewer] that manages the page controller and UI state.
class _ComicViewerState extends State<ComicViewer> {
  /// Controls the current page being displayed and handles page transitions.
  late PageController _pageController;

  /// Tracks the index of the currently displayed page.
  late int _currentPage;

  /// Determines whether the navigation controls are currently visible.
  /// Controls are toggled by tapping on the comic page.
  bool _isControlsVisible = true;

  bool scroll = false;


  /// Initializes the state of the comic viewer.
  ///
  /// Sets up the page controller with the initial page provided in the widget
  /// and initializes the current page tracking variable.
  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  /// Cleans up resources when the widget is removed from the tree.
  ///
  /// Disposes the page controller to prevent memory leaks.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Toggles the visibility of the navigation controls.
  ///
  /// This method is called when the user taps on the comic page.
  /// It switches the visibility state of the controls overlay.
  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  /// Navigates to the next page if available.
  void _nextPage() {
    if (_currentPage < widget.comic.comicPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigates to the previous page if available.
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Builds the comic viewer UI.
  ///
  /// Creates a scaffold containing:
  /// - A [PhotoViewGallery] for displaying and interacting with comic pages
  /// - Navigation controls that appear at the top and bottom when visible
  /// - Page indicator and slider for navigation between pages
  @override
  Widget build(BuildContext context) {
    if (widget.comic.comicPages.isEmpty) {
      return const Center(child: Text('No pages found'));
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowRight): _nextPage,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _previousPage,
        const SingleActivator(LogicalKeyboardKey.space): _nextPage,
        const SingleActivator(LogicalKeyboardKey.arrowDown): _nextPage,
        const SingleActivator(LogicalKeyboardKey.arrowUp): _previousPage,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: widget.backgroundColor,
          body: Stack(
            children: [
              // Comic pages
             GestureDetector(
                onTap: _toggleControls,
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  scrollDirection: scroll ? Axis.vertical : Axis.horizontal,
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider:
                          FileImage(File(widget.comic.comicPages[index])),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  itemCount: widget.comic.comicPages.length,
                  loadingBuilder: (context, event) => Center(
                      child: Center(
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                    ),
                  )),
                  pageController: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    widget.onPageChanged?.call(index.toDouble());
                    widget.onProgressChanged?.call((index + 1) / widget.comic.comicPages.length);
                  },
                  backgroundDecoration:
                      BoxDecoration(color: widget.backgroundColor),
                ),
              ),


              // Controls
              if (widget.showControls && _isControlsVisible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: const Color(0x80000000),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page indicator
                        Text(
                          'Page ${_currentPage + 1} of ${widget.comic.comicPages.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8.0),

                        // Page slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Slider(
                            value: _currentPage.toDouble(),
                            min: 0,
                            max:
                                (widget.comic.comicPages.length - 1).toDouble(),
                            divisions: widget.comic.comicPages.length - 1,
                            onChanged: (double value) {
                              _pageController.jumpToPage(value.toInt());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // App bar with title
              if (widget.showControls && _isControlsVisible && widget.showAppBar)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: const Color(0x80000000),
                    elevation: 0,
                    title: Text(widget.comic.comicName),
                    actions: [
                      PopupMenuButton(
                        onSelected: (v) {
                          switch (v) {
                            case 'scroll':
                              setState(() {
                                scroll = true;
                              });
                              break;
                            case 'page':
                              setState(() {
                                scroll = false;
                              });
                          }
                        },
                        icon: Icon(Icons.book),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'scroll',
                            child: Text('Scroll'),
                          ),
                          PopupMenuItem(
                            value: 'page',
                            child: Text('Page'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
