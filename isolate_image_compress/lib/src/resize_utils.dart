import 'package:image/image.dart';

import 'package:isolate_image_compress/src/constants/enums.dart';
import 'package:isolate_image_compress/src/entity/isolate_image.dart';

extension ResizeOnImage on Image {
  /// Resize image with resolution
  Image resizeWithResolution(ImageResolution resolution) {
    int? _newWidth, _newHeight;
    if (width < height) {
      if (height > resolution.height) {
        _newHeight = resolution.height;
      }
    } else {
      if (width > resolution.width) {
        _newWidth = resolution.width;
      }
    }
    if (_newWidth != null || _newHeight != null) {
      return copyResize(this, width: _newWidth, height: _newHeight);
    }

    return this;
  }

  /// Resize image by maxWidth resolution
  Image resizeWithMaxWidth(int maxWidth) {
    //Resize the image to 1200px width by mantaining aspect ratio
    return copyResize(this, width: width);
  }
}

extension ResizeOnIsolateImage on IsolateImage {
  /// Resize image with resolution
  Image? resizeWithResolution(ImageResolution resolution) {
    if (data?.isNotEmpty == true) {
      final _image = decodeImage(data!);
      if (_image != null) {
        return _image.resizeWithMaxWidth(resolution);
      }
    }
    return null;
  }

  /// Resize image with resolution
  Image? resizeWithResolution(int maxWidth) {
    if (data?.isNotEmpty == true) {
      final _image = decodeImage(data!);
      if (_image != null) {
        return _image.resizeWithResolution(maxWidth);
      }
    }
    return null;
  }

}
