// Copyright (c) 2018, the gRPC project authors. Please see the AUTHORS file
// for details. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:web/helpers.dart' as html;

import '../../client/call.dart';
import '../../shared/message.dart';
import '../../shared/status.dart';
import '../connection.dart';
import 'cors.dart' as cors;
import 'transport.dart';
import 'web_streams.dart';

const _contentTypeKey = 'Content-Type';

class XhrTransportStream implements GrpcTransportStream {
  final html.XMLHttpRequest _request;
  final ErrorHandler _onError;
  final Function(XhrTransportStream stream) _onDone;
  bool _headersReceived = false;
  int _requestBytesRead = 0;
  final StreamController<ByteBuffer> _incomingProcessor = StreamController();
  final StreamController<GrpcMessage> _incomingMessages = StreamController();
  final StreamController<List<int>> _outgoingMessages = StreamController();

  @override
  Stream<GrpcMessage> get incomingMessages => _incomingMessages.stream;

  @override
  StreamSink<List<int>> get outgoingMessages => _outgoingMessages.sink;

  XhrTransportStream(this._request,
      {required ErrorHandler onError, required onDone})
      : _onError = onError,
        _onDone = onDone {
    _outgoingMessages.stream.map(frame).listen((data) {
      final bytes = data.jsify();
      _request.send(bytes);
    }, cancelOnError: true);

    _request.onReadyStateChange.listen((data) {
      if (_incomingProcessor.isClosed) {
        return;
      }
      if (_request.readyState == html.XMLHttpRequest.HEADERS_RECEIVED) {
        _onHeadersReceived();
        return;
      } else if (_request.readyState == html.XMLHttpRequest.DONE) {
        _onRequestDone();
        _close();
        return;
      }
    });

    _request.onError.listen((html.ProgressEvent event) {
      if (_incomingProcessor.isClosed) {
        return;
      }
      _onError(GrpcError.unavailable('XhrConnection connection-error'),
          StackTrace.current);
      terminate();
    });

    _request.onProgress.listen((html.ProgressEvent _) {
      if (_incomingProcessor.isClosed) {
        return;
      }
      // Use response over responseText as most browsers don't support
      // using responseText during an onProgress event.
      final responseString = _request.response.toString();
      final bytes = Uint8List.fromList(
              responseString.substring(_requestBytesRead).codeUnits)
          .buffer;
      _requestBytesRead = responseString.length;
      _incomingProcessor.add(bytes);
    });

    _incomingProcessor.stream
        .transform(GrpcWebDecoder())
        .transform(grpcDecompressor())
        .listen(_incomingMessages.add,
            onError: _onError, onDone: _incomingMessages.close);
  }

  bool _validateResponseState() {
    try {
      final headers = _request.responseHeaders;

      validateHttpStatusAndContentType(_request.status, headers,
          rawResponse: _request.responseText);
      return true;
    } catch (e, st) {
      _onError(e, st);
      return false;
    }
  }

  void _onHeadersReceived() {
    _headersReceived = true;
    if (!_validateResponseState()) {
      return;
    }
    final headers = _request.responseHeaders;
    _incomingMessages.add(GrpcMetadata(headers));
  }

  void _onRequestDone() {
    if (!_headersReceived && !_validateResponseState()) {
      return;
    }
    if (_request.response == null) {
      _onError(
          GrpcError.unavailable('XhrConnection request null response', null,
              _request.responseText),
          StackTrace.current);
      return;
    }
  }

  void _close() {
    _incomingProcessor.close();
    _outgoingMessages.close();
    _onDone(this);
  }

  @override
  Future<void> terminate() async {
    _close();
    _request.abort();
  }
}

class XhrClientConnection implements ClientConnection {
  final Uri uri;

  final _requests = <XhrTransportStream>{};

  XhrClientConnection(this.uri);

  @override
  String get authority => uri.authority;
  @override
  String get scheme => uri.scheme;

  void _initializeRequest(
      html.XMLHttpRequest request, Map<String, String> metadata) {
    for (final header in metadata.keys) {
      request.setRequestHeader(header, metadata[header]!);
    }
    // Overriding the mimetype allows us to stream and parse the data
    request.overrideMimeType('text/plain; charset=x-user-defined');
    request.responseType = 'text';
  }

  @visibleForTesting
  html.XMLHttpRequest createHttpRequest() => html.XMLHttpRequest();

  @override
  GrpcTransportStream makeRequest(String path, Duration? timeout,
      Map<String, String> metadata, ErrorHandler onError,
      {CallOptions? callOptions}) {
    // gRPC-web headers.
    if (_getContentTypeHeader(metadata) == null) {
      metadata['Content-Type'] = 'application/grpc-web+proto';
      metadata['X-User-Agent'] = 'grpc-web-dart/0.1';
      metadata['X-Grpc-Web'] = '1';
    }

    var requestUri = uri.resolve(path);
    if (callOptions is WebCallOptions &&
        callOptions.bypassCorsPreflight == true) {
      requestUri = cors.moveHttpHeadersToQueryParam(metadata, requestUri);
    }

    final request = createHttpRequest();
    request.open('POST', requestUri.toString());
    if (callOptions is WebCallOptions && callOptions.withCredentials == true) {
      request.withCredentials = true;
    }
    // Must set headers after calling open().
    _initializeRequest(request, metadata);

    final transportStream =
        XhrTransportStream(request, onError: onError, onDone: _removeStream);
    _requests.add(transportStream);
    return transportStream;
  }

  void _removeStream(XhrTransportStream stream) {
    _requests.remove(stream);
  }

  @override
  Future<void> terminate() async {
    for (var request in List.of(_requests)) {
      request.terminate();
    }
  }

  @override
  void dispatchCall(ClientCall call) {
    call.onConnectionReady(this);
  }

  @override
  Future<void> shutdown() async {}

  @override
  set onStateChanged(void Function(ConnectionState) cb) {
    // Do nothing.
  }
}

MapEntry<String, String>? _getContentTypeHeader(Map<String, String> metadata) {
  for (var entry in metadata.entries) {
    if (entry.key.toLowerCase() == _contentTypeKey.toLowerCase()) {
      return entry;
    }
  }
  return null;
}

extension HeadersExt on html.XMLHttpRequest {
  Map<String, String> get responseHeaders {
    // from Closure's goog.net.Xhrio.getResponseHeaders.
    final headers = <String, String>{};
    final headersString = getAllResponseHeaders();
    if (headersString == null) {
      return headers;
    }
    final headersList = headersString.split('\r\n');
    for (var header in headersList) {
      if (header.isEmpty) {
        continue;
      }

      final splitIdx = header.indexOf(': ');
      if (splitIdx == -1) {
        continue;
      }
      final key = header.substring(0, splitIdx).toLowerCase();
      final value = header.substring(splitIdx + 2);
      if (headers.containsKey(key)) {
        headers[key] = '${headers[key]}, $value';
      } else {
        headers[key] = value;
      }
    }
    return headers;
  }
}
