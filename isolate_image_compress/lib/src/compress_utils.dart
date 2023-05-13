import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image/image.dart';
import 'package:isolate_flutter/isolate_flutter.dart';

import 'package:isolate_image_compress/src/constants/enums.dart';
import 'package:isolate_image_compress/src/entity/isolate_image.dart';
import 'package:isolate_image_compress/src/compress_format/index.dart';

class CompressParams {
  /// [image] - the image used for compression.
  final IsolateImage? image;

  /// [imageData] - the image data used for compression.
  final Uint8List? imageData;

  /// [maxSize] - compressed file size limit (Bytes).
  final int? maxSize;

  /// [quality] - default quality , effective if maxSize is null
  final int? quality;

  /// [width] - compressed file with limit (int).
  final int? width;

  /// [maxResolution] - the maximum resolution compressed.
  final ImageResolution? maxResolution;

  /// [format] - the image format you want to compress.
  final ImageFormat? format;

  /// Parameters used for compression
  ///
  /// - [image] - the image data used for compression (required).
  /// - [maxSize] - compressed file size limit (Bytes) (optional).
  /// - [quality] - default quality, effective if [maxSize] is null (optional).
  /// - [maxResolution] - the maximum resolution compressed. Default is [ImageResolution.uhd] - 4K, Ultra HD | 3840 x 2160.
  /// - [width] - image is resized to width if original width > width
  /// - [format] - the image format you want to compress (optional).
  CompressParams(
      {this.image,
      this.imageData,
      this.maxSize,
      this.quality,
      this.width,
      this.maxResolution = ImageResolution.uhd,
      this.format})
      : assert(image != null || imageData != null);
}

Future<Uint8List> _compressImage(CompressParams params) async {
  final _maxSize = params.maxSize;
  final _width = params.width;
  final _quality = params.quality;

  // read image data
  final Uint8List _fileData =
      params.imageData ?? params.image?.data ?? Uint8List(0);
  final fileSize = (_maxSize == null) ? _fileData.length : _maxSize;
  debugPrint('Compress_utils: fileSize: $fileSize');
  debugPrint('Compress_utils: _fileData.length: $_fileData.length');
  if (_fileData.isEmpty || _fileData.length <= fileSize) {
    // not compression
    return _fileData;
  } else {
    final _maxResolution = params.maxResolution;

    Decoder? _decoder =
        (params.format != null ? _getDecoder(params.format!) : null) ??
            findDecoderForData(_fileData);
    if (_decoder is JpegDecoder) {
      return compressJpegImage(_fileData,
          maxSize: _maxSize, quality: _quality, width: _width, maxResolution: _maxResolution);
    } else if (_decoder is PngDecoder) {
      return compressPngImage(_fileData,
          maxSize: _maxSize, width: _width, maxResolution: _maxResolution);
    } else if (_decoder is TgaDecoder) {
      return compressTgaImage(_fileData,
          maxSize: _maxSize, width: _width, maxResolution: _maxResolution);
    } else if (_decoder is GifDecoder) {
      return compressGifImage(_fileData,
          maxSize: _maxSize, width: _width, maxResolution: _maxResolution);
    }

    return Uint8List(0);
  }
}

Decoder? _getDecoder(ImageFormat format) {
  switch (format) {
    case ImageFormat.jpeg:
      return JpegDecoder();
    case ImageFormat.png:
      return PngDecoder();
    case ImageFormat.tga:
      return TgaDecoder();
    case ImageFormat.gif:
      return GifDecoder();
    default:
      return null;
  }
}

// --- Extension --- //

extension CompressOnIsolateImage on IsolateImage {
  /// Compress image.
  ///
  /// - [maxSize] - compressed file size limit (Bytes). (optional).
  /// - [maxResolution] - the maximum resolution compressed. (optional).
  /// - [quality] - default quality, effective if [maxSize] is null (optional).
  /// - [width] - width size fixed by mantaining aspectRatio  (optional).
  /// - [format] - the image format you want to compress. (optional).
  Future<Uint8List?> compress(
      {int? maxSize,
      int? quality,
      ImageResolution? maxResolution,
      int? width,
      ImageFormat? format}) async {
    final CompressParams _params = CompressParams(
        image: this,
        maxSize: maxSize,
        quality: quality,
        maxResolution: maxResolution,
        width: width,
        format: format);
    return IsolateFlutter.createAndStart(_compressImage, _params,
        debugLabel: 'isolate_image_compress');
  }
}

extension CompressOnUint8List on Uint8List {
  /// Compress image data.
  ///
  /// - [maxSize] - compressed file size limit (Bytes). (optional).
  /// - [maxResolution] - the maximum resolution compressed. (optional).
  /// - [quality] - default quality, effective if [maxSize] is null (optional).
  /// - [width] - image is resized to width if original width > width
  /// - [format] - the image format you want to compress. (optional).
  Future<Uint8List?> compress(
      {int? maxSize, int? quality, ImageResolution? resolution, int? width, ImageFormat? format}) async {
    final CompressParams _params = CompressParams(
        imageData: this,
        maxSize: maxSize,
        quality: quality,
        width: width,
        maxResolution: resolution,
        format: format);
    return IsolateFlutter.createAndStart(_compressImage, _params,
        debugLabel: 'isolate_image_compress');
  }
}

extension CompressOnListInt on List<int> {
  /// Compress image data.
  ///
  /// - [maxSize] - compressed file size limit (Bytes). (optional).
  /// - [quality] - default quality, effective if [maxSize] is null (optional).
  /// - [maxResolution] - the maximum resolution compressed. (optional).
  /// - [format] - the image format you want to compress. (optional).
  Future<Uint8List?> compress(
      {int? maxSize, int? quality, ImageResolution? resolution, int? width, ImageFormat? format}) async {
    final CompressParams _params = CompressParams(
        imageData: Uint8List.fromList(this),
        maxSize: maxSize,
        quality: quality,
        width: width,
        maxResolution: resolution,
        format: format);
    return IsolateFlutter.createAndStart(_compressImage, _params,
        debugLabel: 'isolate_image_compress');
  }
}
