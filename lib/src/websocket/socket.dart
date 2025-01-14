import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../flutter_graphql.dart';

/// Wraps a standard web socket instance to marshal and un-marshal the server /
/// client payloads into dart object representation.
class GraphQLSocket {
  GraphQLSocket(this._socket) {
    _socket
        .map<Map<String, dynamic>?>((dynamic message) => json.decode(message))
        .listen(
      (Map<String, dynamic>? message) {
        final String type = message!['type'] ?? 'unknown';
        final dynamic payload = message['payload'] ?? <String, dynamic>{};
        final String id = message['id'] ?? 'none';

        switch (type) {
          case MessageTypes.GQL_CONNECTION_ACK:
            _subject.add(ConnectionAck());
            break;
          case MessageTypes.GQL_CONNECTION_ERROR:
            _subject.add(ConnectionError(payload));
            break;
          case MessageTypes.GQL_CONNECTION_KEEP_ALIVE:
            _subject.add(ConnectionKeepAlive());
            break;
          case MessageTypes.GQL_DATA:
            final dynamic data = payload['data'];
            final dynamic errors = payload['errors'];
            _subject.add(SubscriptionData(id, data, errors));
            break;
          case MessageTypes.GQL_ERROR:
            _subject.add(SubscriptionError(id, payload));
            break;
          case MessageTypes.GQL_COMPLETE:
            _subject.add(SubscriptionComplete(id));
            break;
          default:
            _subject.add(UnknownData(message));
        }
      },
    );
  }

  final StreamController<GraphQLSocketMessage> _subject =
      StreamController<GraphQLSocketMessage>.broadcast();

  final WebSocket _socket;

  void write(final GraphQLSocketMessage message) {
    _socket.add(
      json.encode(
        message,
        toEncodable: (dynamic m) => m.toJson(),
      ),
    );
  }

  Stream<ConnectionAck> get connectionAck => _subject.stream
      .where((GraphQLSocketMessage message) => message is ConnectionAck)
      .cast<ConnectionAck>();

  Stream<ConnectionKeepAlive> get connectionKeepAlive => _subject.stream
      .where((GraphQLSocketMessage message) => message is ConnectionKeepAlive)
      .cast<ConnectionKeepAlive>();

  Stream<ConnectionError> get connectionError => _subject.stream
      .where((GraphQLSocketMessage message) => message is ConnectionError)
      .cast<ConnectionError>();

  Stream<UnknownData> get unknownData => _subject.stream
      .where((GraphQLSocketMessage message) => message is UnknownData)
      .cast<UnknownData>();

  Stream<SubscriptionData> get subscriptionData => _subject.stream
      .where((GraphQLSocketMessage message) => message is SubscriptionData)
      .cast<SubscriptionData>();

  Stream<SubscriptionError> get subscriptionError => _subject.stream
      .where((GraphQLSocketMessage message) => message is SubscriptionError)
      .cast<SubscriptionError>();

  Stream<SubscriptionComplete> get subscriptionComplete => _subject.stream
      .where((GraphQLSocketMessage message) => message is SubscriptionComplete)
      .cast<SubscriptionComplete>();
}
