import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:isolate_image_compress/src/log_utils.dart';
import 'package:isolate_image_compress/src/resize_utils.dart';
import 'package:isolate_image_compress/src/constants/enums.dart';

/// Compress Jpeg Image - return empty(*Uint8List(0)*) if image can't be compressed.
///
/// Params:
/// - [data] The image data to compress.
/// - [maxSize] limit file size you want to compress (Bytes). If it is null, return [data].
/// - [maxResolution] limit image resolution you want to compress ([ImageResolution]). Default is [ImageResolution.uhd].
Future<Uint8List> compressJpegImage(Uint8List data,
    {int? maxSize, ImageResolution? maxResolution, int? width}) async {
  // If maxSize is not specified, compression quality is set to 70
  // This is the fastest compression because it is one single round of compression.
  print('encodeJpg - maxSize: $maxSize');
  if (maxSize == null) {
    const _defaultQuality = 70;
    Image? _image = decodeImage(data);
    List<int>? _data;
    if (maxResolution != null) {
      _image = _image!.resizeWithResolution(maxResolution);
      print(
          'resizeWithResolution: ${maxResolution.width} - ${maxResolution.height}');
    }
    if (width != null) {
      _image = _image!.resizeByWidth(width);;
      print(
          'resizeByWidth: ${width}');
    }
    _data = encodeJpg(_image!, quality: _defaultQuality);
    print('encodeJpg - _defaultQuality: ${_data.length}');
    return Uint8List.fromList(_data);
  }

  // quality: The JPEG quality, in the range [0, 100] where 100 is highest quality.
  // We start from 80% quality and decrease by [_step] until maxSize constrait is
  // satisfied
  const _minQuality = 0;
  const _maxQuality = 80;
  const _step = 10;

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

      _data = encodeJpg(_image!, quality: _maxQuality);
      print('encodeJpg - _maxQuality: ${_data.length}');

      if (_data.length > maxSize) {
        _data = encodeJpg(_image, quality: _minQuality);
        print('encodeJpg - _minQuality: ${_data.length}');

        if (_data.length < maxSize) {
          int _quality = _maxQuality;
          do {
            _quality -= _step;
            _data = encodeJpg(_image, quality: _quality);
            print('encodeJpg - _quality - $_quality: ${_data.length}');
          } while (_data.length > maxSize && _quality > _minQuality);

          break;
        }
      }

      _resolution = _resolution?.prev();
    } while (_resolution != null);

    return _data.length < maxSize ? Uint8List.fromList(_data) : Uint8List(0);
  }
}
