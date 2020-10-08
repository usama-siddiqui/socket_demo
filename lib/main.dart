import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:socket_connection/bloc/chat_bloc.dart';
import 'package:socket_connection/socket_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Chat Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SocketService socketService;
  final ChatBloc _chatBloc = ChatBloc();
  TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    socketService = SocketService(_chatBloc);
    socketService.createSocketConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.title, style: TextStyle(fontSize: 16)),
              _typingView(),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [_chatListView(), _bottomChatArea()],
          ),
        ));
  }

  _typingView() {
    return StreamBuilder<String>(
      stream: _chatBloc.typing,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          return Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "${snapshot.data.toString()} is typing....",
              style: TextStyle(fontSize: 12),
            ),
          );
        }
      },
    );
  }

  _chatListView() {
    return Expanded(
        child: StreamBuilder<List<String>>(
            stream: _chatBloc.chats,
            builder: (context, snapshot) {
              return ListView.builder(
                  reverse: true,
                  itemCount: snapshot?.data?.length,
                  itemBuilder: (context, position) {
                    return Bubble(
                      margin: BubbleEdges.only(top: 10, right: 5),
                      alignment: Alignment.topRight,
                      nip: BubbleNip.rightTop,
                      color: Color.fromRGBO(225, 255, 199, 1.0),
                      child: Text(snapshot?.data[position],
                          textAlign: TextAlign.right),
                    );
                  });
            }));
  }

  _bottomChatArea() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          _chatTextArea(),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              _sendButtonTap();
            },
          ),
        ],
      ),
    );
  }

  _chatTextArea() {
    return Expanded(
      child: TextField(
        controller: _chatController,
        onChanged: (String val) {
          socketService.checkTyping(val);
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 0.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.white,
              width: 0.0,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Type message...',
        ),
      ),
    );
  }

  void _sendButtonTap() {
    String message = _chatController.text.trim();
    _chatController.clear();
    socketService.sendMessage(message);
  }

  @override
  void dispose() {
    socketService.dispose();
    _chatBloc.dispose();
    _chatController.dispose();
    super.dispose();
  }
}
