import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;

import 'package:isolate_image_compress/src/constants/enums.dart';
import 'package:isolate_image_compress/src/entity/isolate_image.dart';

extension ResizeOnImage on img.Image {
  /// Resize image with resolution
  img.Image resizeWithResolution(ImageResolution resolution) {
    int? _newWidth, _newHeight;
    debugPrint('Isolate Flutter Compress: width: $width, height: $height');
    if (width < height) {
      if (height > resolution.height) {
        _newHeight = resolution.height;
      }
    } else {
      if (width > resolution.width) {
        _newWidth = resolution.width;
      }
    }
    debugPrint('Isolate Flutter Compress: _width: $_newWidth, _height: $_newHeight');
    if (_newWidth != null || _newHeight != null) {
      if (_newWidth != _newHeight && resolution.width != resolution.height) {
        return img.copyResize(this, width: _newWidth, height: _newHeight);
      } else {
        // If width and height are the same, return a sqaurecrop
        debugPrint('Isolate Flutter Compress Square resize');
        return img.copyResizeCropSquare(this, size: resolution.width);
      }
    }
    return this;
  }

  /// Resize image by width resolution
  img.Image resizeByWidth(int width) {
    //Resize the image to 1200px width by mantaining aspect ratio
    if (this.width > 1200) {
      return img.copyResize(this, width: width);
    } else {
      return this;
    }
  }
}

extension ResizeOnIsolateImage on IsolateImage {
  /// Resize image with resolution
  img.Image? resizeByResolution(ImageResolution resolution) {
    if (data?.isNotEmpty == true) {
      final _image = img.decodeImage(data!);
      if (_image != null) {
        return _image.resizeWithResolution(resolution);
      }
    }
    return null;
  }

  /// Resize image with resolution
  img.Image? resizeByWidth(int width) {
    if (data?.isNotEmpty == true) {
      final _image = img.decodeImage(data!);
      if (_image != null && _image.width > 1200) {
        return _image.resizeByWidth(width);
      }
    }
    return null;
  }

}
