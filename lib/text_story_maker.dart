library story_maker;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'components/footer_tools_widget.dart';
import 'components/overlay_item_widget.dart';
import 'components/size_slider_widget.dart';
import 'components/text_field_widget.dart';
import 'components/text_story_top_tools_widget.dart';
import 'constants/font_styles.dart';
import 'constants/gradients.dart';
import 'constants/item_type.dart';
import 'extensions/context_extension.dart';
import 'models/editable_items.dart';

class TextStoryMaker extends StatefulWidget {
  const TextStoryMaker({
    Key? key,
    this.animationsDuration = const Duration(milliseconds: 300),
    this.doneButtonChild,
    this.hintText,
  }) : super(key: key);

  final Duration animationsDuration;
  final Widget? doneButtonChild;
  final String? hintText;

  @override
  _TextStoryMakerState createState() => _TextStoryMakerState();
}

class _TextStoryMakerState extends State<TextStoryMaker> {
  static GlobalKey previewContainer = GlobalKey();
  bool _isTextInput = false;
  String _currentText = '';
  Color _selectedTextColor = const Color(0xffffffff);
  int _selectedBackgroundGradient = 0;
  double _selectedFontSize = 26;
  int _selectedFontFamily = 0;
  late PageController _familyPageController;
  late PageController _textColorsPageController;
  late PageController _gradientsPageController;
  final _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _editingController.dispose();
    _familyPageController.dispose();
    _textColorsPageController.dispose();
    _gradientsPageController.dispose();
    super.dispose();
  }

  void _init() {
    _familyPageController = PageController(viewportFraction: .125);
    _textColorsPageController = PageController(viewportFraction: .1);
    _gradientsPageController = PageController(viewportFraction: .175);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextHeightBehavior(
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: previewContainer,
                    child: Stack(
                      children: [
                        Container(
                          height: context.height,
                          width: context.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: FractionalOffset.topLeft,
                              end: FractionalOffset.centerRight,
                              colors: _selectedBackgroundGradient == 0
                                  ? [Colors.black, Colors.black]
                                  : gradientColors[_selectedBackgroundGradient],
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: widget.animationsDuration,
                          child: Container(
                            height: context.height,
                            width: context.width,
                            color: Colors.black.withOpacity(0.4),
                            child: Stack(
                              children: [
                                TextFieldWidget(
                                  controller: _editingController,
                                  onChanged: (_) {},
                                  onSubmit: (_) {},
                                  fontSize: _selectedFontSize,
                                  fontFamilyIndex: _selectedFontFamily,
                                  textColor: _selectedTextColor,
                                  hintText: widget.hintText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizeSliderWidget(
                    animationsDuration: widget.animationsDuration,
                    selectedValue: _selectedFontSize,
                    onChanged: (input) {
                      setState(
                        () {
                          _selectedFontSize = input;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            TextStoryToolsWidget(
              selectedBackgroundGradientIndex: _selectedBackgroundGradient,
              animationsDuration: widget.animationsDuration,
              onPickerTap: _onChangeBackgroundPressed,
              onFontChangePressed: _onChangeFontPressed,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FooterToolsWidget(
                onDone: _onDone,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onChangeFontPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedFontFamily != 0 && _selectedFontFamily % (fontFamilyList.length - 1) == 0) {
        _selectedFontFamily = 0;
      } else {
        _selectedFontFamily++;
      }
    });
  }

  void _onChangeBackgroundPressed() {
    HapticFeedback.lightImpact();
    setState(
      () {
        if (_selectedBackgroundGradient != 0 && _selectedBackgroundGradient % (gradientColors.length - 1) == 0) {
          _selectedBackgroundGradient = 0;
        } else {
          _selectedBackgroundGradient++;
        }
      },
    );
  }

  Future<void> _onDone() async {
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      if (_editingController.text.isNotEmpty) {
        final boundary = previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary?;
        final image = await boundary!.toImage(pixelRatio: 3);
        final directory = (await getApplicationDocumentsDirectory()).path;
        final byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final pngBytes = byteData.buffer.asUint8List();
        final imgFile = File('$directory/${DateTime.now()}.png');
        await imgFile.writeAsBytes(pngBytes).then((value) {
          // done: return imgFile
          Navigator.of(context).pop(imgFile);
        });
      } else {
        Navigator.of(context).pop();
      }
    });
  }
}
