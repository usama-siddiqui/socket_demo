import 'package:rxdart/rxdart.dart';

class ChatBloc {
  final _chats = BehaviorSubject<List<String>>();
  final _typing = BehaviorSubject<String>();

  List<String> _chatList = List<String>();
  String _username;

  ChatBloc() {
    _setChat(_chatList);
    _setTyping(_username);
  }

  //Get Typing
  Stream<String> get typing => _typing.stream;

  //Set Typing
  Function(String) get _setTyping => _typing.sink.add;

  //Get Chat
  Stream<List<String>> get chats => _chats.stream;

  //Set Chat
  Function(List<String>) get _setChat => _chats.sink.add;

  addMessage(String message) {
    _chatList.add(message);
    _setChat(_chatList.reversed.toList());
  }

  setTyping(String username) {
    _username = username ?? '';
    _setTyping(username);
  }

  dispose() {
    _chats.close();
    _typing.close();
  }
}
