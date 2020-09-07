part of http_api;

class DevToolsLink extends ApiLink {
  IO.Socket _socket;
  DevToolsLink() {
    _socket = IO.io('http://10.0.2.2:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();
    print("DEV TOOLS");

    _socket.on('connect', (_) {
      print('connect');
      _socket.emit('msg', 'test');
    });
  }

  Future<ApiResponse> next(ApiRequest request) async {
    print("Connected: ${_socket.connected}");
    _socket.emit("request", request.toJson());
    final response = await super.next(request);
    _socket.emit("response", response.toJson());

    return response;
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
