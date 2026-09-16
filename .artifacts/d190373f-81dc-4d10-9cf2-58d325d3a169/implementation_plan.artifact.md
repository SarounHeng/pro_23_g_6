# Implementation Plan - Add Background Image to Home Banner

Update the banner slider on the `HomeScreen` to display background images from the `SliderModel` while maintaining text legibility.

## Proposed Changes

### UI Enhancement

#### [MODIFY] [home_screen.dart](file:///C:/Users/Rotha/Downloads/flutter_II_pro_23_II-main/flutter_II_pro_23_II-main/lib/screen/home/home_screen.dart)
- Update the `PageView.builder`'s `itemBuilder` to use a `Stack`.
- Background: `Image.network` with `BoxFit.cover`, wrapped in `ClipRRect` for rounded corners.
- Overlay: A `Container` with a `LinearGradient` (from transparent to dark teal/black) to ensure the white text remains readable.
- Content: Maintain the `Column` with `banner.title` and `banner.subtitle`.

## Verification Plan

### Manual Verification
- Launch the app and verify that each banner slide now shows a unique background image.
- Ensure the text is still clearly visible over the images.
- Verify that the auto-scroll and dot indicators still function correctly.
