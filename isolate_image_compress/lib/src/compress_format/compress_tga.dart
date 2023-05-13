import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:isolate_image_compress/src/log_utils.dart';
import 'package:isolate_image_compress/src/resize_utils.dart';
import 'package:isolate_image_compress/src/constants/enums.dart';

/// Compress Tga Image - return empty(*Uint8List(0)*) if image can't be compressed.
///
/// Params:
/// - [data] The image data to compress.
/// - [maxSize] limit file size you want to compress (Bytes). If it is null, return [data].
/// - [maxResolution] limit image resolution you want to compress ([ImageResolution]). Default is [ImageResolution.uhd].
Future<Uint8List> compressTgaImage(Uint8List data,
    {int? maxSize, ImageResolution? maxResolution, int? width}) async {
  if (maxSize == null) {
    return data;
  }

  ImageResolution? _resolution = maxResolution ?? ImageResolution.uhd;

  Image? _image = decodeImage(data);
  if (_image == null) {
    return Uint8List(0);
  } else {
    List<int>? _data;
    do {
      if (_resolution != null) {
        _image = _image!.resizeWithResolution(_resolution);
        print(
            'resizeWithResolution: ${_resolution.width} - ${_resolution.height}');
      }
      if (width != null) {
        _image = _image!.resizeByWidth(width);;
        print(
            'resizeByWidth: ${width}');
      }
      _data = encodeTga(_image!);
      print('encodeTga - length: ${_data.length}');
      if (_data.length < maxSize) {
        break;
      }

      _resolution = _resolution?.prev();
    } while (_resolution != null);

    return _data.length < maxSize ? Uint8List.fromList(_data) : Uint8List(0);
  }
}
