import 'dart:async';
import 'dart:math';
import 'package:socket_connection/bloc/chat_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  Socket socket;
  ChatBloc _chatBloc;
  int number;
  Timer _timer;

  SocketService(ChatBloc chatBloc) {
    _chatBloc = chatBloc;
    number = getRandomNumber(5);
  }

  createSocketConnection() {
    socket = io("http://10.0.0.198:4000", <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });

    socket.connect();

    this.socket.on('connect', (data) {
      print('Connected ' + data.toString());
      socket.emit("new user", "Sam $number");
    });

    this.socket.on('disconnect', (data) {
      print('Disconnected ' + data);
    });
    this.socket.on('connect_error', (data) {
      print('Connect Error ' + data);
    });

    this.socket.on('error', (data) {
      print('Error ' + data);
    });

    this.socket.on("chat message", (data) {
      print("Message " + data.toString());
      _chatBloc.addMessage(data.toString().trim());
    });

    this.socket.on("typing", (data) {
      print("Typing " + data.toString());
      _timer?.cancel();
      _chatBloc.setTyping(data.toString().trim());
      _timer = Timer(Duration(milliseconds: 1000), () {
        _chatBloc.setTyping(null);
      });
    });
  }

  sendMessage(String message) {
    this.socket.emit('chat message', ["Sam $number", message]);
  }

  checkTyping(String msg) {
    this.socket.emit("typing", "Sam $number");
  }

  int getRandomNumber(int max) {
    Random random = Random();
    return random.nextInt(max);
  }

  dispose() {
    _timer?.cancel();
    socket?.dispose();
  }
}
