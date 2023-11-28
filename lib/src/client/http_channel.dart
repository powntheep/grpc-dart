import 'channel.dart';
import 'connection.dart';
import 'transport/http_transport.dart';

/// A channel to a grpc-web endpoint.
class GrpcWebHTTPClientChannel extends ClientChannelBase {
  final Uri uri;

  GrpcWebHTTPClientChannel(this.uri) : super();

  @override
  ClientConnection createConnection() {
    return HTTPClientConnection(uri);
  }
}