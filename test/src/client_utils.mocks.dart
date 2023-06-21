// Mocks generated by Mockito 5.4.1 from annotations
// in grpc/test/src/client_utils.dart.
// Do not manually edit this file.

// @dart=2.19

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:http2/src/hpack/hpack.dart' as _i4;
import 'package:http2/transport.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeClientTransportStream_0 extends _i1.SmartFake
    implements _i2.ClientTransportStream {
  _FakeClientTransportStream_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamSink_1<S> extends _i1.SmartFake implements _i3.StreamSink<S> {
  _FakeStreamSink_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ClientTransportConnection].
///
/// See the documentation for Mockito's code generation for more information.
class MockClientTransportConnection extends _i1.Mock
    implements _i2.ClientTransportConnection {
  MockClientTransportConnection() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isOpen => (super.noSuchMethod(
        Invocation.getter(#isOpen),
        returnValue: false,
      ) as bool);
  @override
  set onActiveStateChanged(_i2.ActiveStateHandler? callback) =>
      super.noSuchMethod(
        Invocation.setter(
          #onActiveStateChanged,
          callback,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i3.Future<void> get onInitialPeerSettingsReceived => (super.noSuchMethod(
        Invocation.getter(#onInitialPeerSettingsReceived),
        returnValue: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Stream<int> get onPingReceived => (super.noSuchMethod(
        Invocation.getter(#onPingReceived),
        returnValue: _i3.Stream<int>.empty(),
      ) as _i3.Stream<int>);
  @override
  _i3.Stream<void> get onFrameReceived => (super.noSuchMethod(
        Invocation.getter(#onFrameReceived),
        returnValue: _i3.Stream<void>.empty(),
      ) as _i3.Stream<void>);
  @override
  _i2.ClientTransportStream makeRequest(
    List<_i4.Header>? headers, {
    bool? endStream = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #makeRequest,
          [headers],
          {#endStream: endStream},
        ),
        returnValue: _FakeClientTransportStream_0(
          this,
          Invocation.method(
            #makeRequest,
            [headers],
            {#endStream: endStream},
          ),
        ),
      ) as _i2.ClientTransportStream);
  @override
  _i3.Future<dynamic> ping() => (super.noSuchMethod(
        Invocation.method(
          #ping,
          [],
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> finish() => (super.noSuchMethod(
        Invocation.method(
          #finish,
          [],
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);
  @override
  _i3.Future<dynamic> terminate([int? errorCode]) => (super.noSuchMethod(
        Invocation.method(
          #terminate,
          [errorCode],
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);
}

/// A class which mocks [ClientTransportStream].
///
/// See the documentation for Mockito's code generation for more information.
class MockClientTransportStream extends _i1.Mock
    implements _i2.ClientTransportStream {
  MockClientTransportStream() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<_i2.TransportStreamPush> get peerPushes => (super.noSuchMethod(
        Invocation.getter(#peerPushes),
        returnValue: _i3.Stream<_i2.TransportStreamPush>.empty(),
      ) as _i3.Stream<_i2.TransportStreamPush>);
  @override
  int get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: 0,
      ) as int);
  @override
  _i3.Stream<_i2.StreamMessage> get incomingMessages => (super.noSuchMethod(
        Invocation.getter(#incomingMessages),
        returnValue: _i3.Stream<_i2.StreamMessage>.empty(),
      ) as _i3.Stream<_i2.StreamMessage>);
  @override
  _i3.StreamSink<_i2.StreamMessage> get outgoingMessages => (super.noSuchMethod(
        Invocation.getter(#outgoingMessages),
        returnValue: _FakeStreamSink_1<_i2.StreamMessage>(
          this,
          Invocation.getter(#outgoingMessages),
        ),
      ) as _i3.StreamSink<_i2.StreamMessage>);
  @override
  set onTerminated(void Function(int?)? value) => super.noSuchMethod(
        Invocation.setter(
          #onTerminated,
          value,
        ),
        returnValueForMissingStub: null,
      );
  @override
  void terminate() => super.noSuchMethod(
        Invocation.method(
          #terminate,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void sendHeaders(
    List<_i4.Header>? headers, {
    bool? endStream = false,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #sendHeaders,
          [headers],
          {#endStream: endStream},
        ),
        returnValueForMissingStub: null,
      );
  @override
  void sendData(
    List<int>? bytes, {
    bool? endStream = false,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #sendData,
          [bytes],
          {#endStream: endStream},
        ),
        returnValueForMissingStub: null,
      );
}
