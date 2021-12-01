import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../constants/gradients.dart';
import '../extensions/context_extension.dart';

class TextStoryToolsWidget extends StatelessWidget {
  final Duration animationsDuration;
  final int selectedBackgroundGradientIndex;
  final VoidCallback onPickerTap;
  final VoidCallback onFontChangePressed;

  const TextStoryToolsWidget({
    Key? key,
    required this.animationsDuration,
    this.selectedBackgroundGradientIndex = 0,
    required this.onPickerTap,
    required this.onFontChangePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: context.topPadding,
      child: Container(
        width: context.width,
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BackButton(
              color: Colors.white,
            ),
            const Spacer(),
            GestureDetector(
              onTap: onPickerTap,
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors[selectedBackgroundGradientIndex],
                  ),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.color_lens_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.text_format,
                color: Colors.white,
              ),
              onPressed: onFontChangePressed,
            ),
          ],
        ),
      ),
    );
  }
}
