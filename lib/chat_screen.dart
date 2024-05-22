import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_flutter/controller/chat_controller.dart';
import 'package:web_socket_flutter/model/message.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen( {Key? key}) : super(key: key);


  @override
    _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>{
  Color purple = Color.fromARGB(255, 108, 92, 231);
  Color black = Color.fromARGB(255, 5, 5, 5);
  TextEditingController msgInputController = TextEditingController();
    TextEditingController hourController = TextEditingController();

  TextEditingController textController = TextEditingController();

late IO.Socket socket;
ChatController chatController = ChatController();

@override
  void initState() {
    socket = IO.io(
      'http://localhost:4000',
       IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());
    socket.connect();
    setUpSocketListener();
    super.initState();
    print("Socket connected: ${socket.connected} --- Socket id: ${socket.id}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => Container(
                padding: EdgeInsets.all(10),
              child: Text("Connected User ${chatController.connectedUser}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
              )
              ),
                ),
            ),
            ),
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index){
                    var currentItem = chatController.chatMessages[index];
                  return MessageItem(
                    sentByMe: currentItem.sentByMe == socket.id,
                    message: currentItem.message,
                    hora: currentItem.hora,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.red,
                child: TextField(
                  style: TextStyle(
                    color: Colors.white
                  ),
                  cursorColor: purple,
                  controller: msgInputController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Container(
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:purple,
                      ),
                      //color: purple,
                      child: IconButton(
                        onPressed: () {
                          DateTime now = DateTime.now();
                          hourController.text = '${now.hour}:${now.minute}';
                          sendMessage(msgInputController.text, hourController.text);
                          msgInputController.text="";
                          
                        },
                        icon: Icon(Icons.send, color: Colors.white,),
                      )
                    )
                  )
                ),
              ),
            ),
            Expanded(
            child: Row(
              children: [
                // Campo de entrada de texto
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    controller: textController, // Un controlador para capturar el texto introducido
                    decoration: InputDecoration(
                      hintText: 'Introduce un texto',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Separación entre el campo de entrada de texto y el botón
                // Botón
                // Container(
                //   child: IconButton(
                //         onPressed: () {
                //           createConnection(textController.text);
                //           textController.text="";
                //         },
                //         icon: Icon(Icons.send, color: Colors.white,),
                //       )
                // ),
              ],
            ),
          )

          ],
        ),
      ),
    );
  }
  
  void sendMessage(String text, String hour) {
    print(socket);
    print(socket.id);
    print(socket.connected);
  var messageJson = {
    "message": text,
    "sentByMe": socket.id ?? "",
    "hora": hour, 
  };
  print('Mensaje: $messageJson');
  socket.emit('message', messageJson);
  chatController.chatMessages.add(Message.fromJson(messageJson));
}

// void createConnection(String room) {
//     socket = IO.io(
//       'http://localhost:4000/${room}',
//        IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .disableAutoConnect()
//           .build());
//     socket.connect();
//     setUpSocketListener();
//     super.initState();
//     print("Socket connected: ${socket.connected} --- Socket id: ${socket.id}");
//   }

  void setUpSocketListener() {
    socket.on('message-receive', (data){
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data){
      print(data);
      chatController.connectedUser.value = data;
  });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sentByMe, required this.message, required this.hora})
      : super(key: key);

  final bool sentByMe;
  final String message;
  final String hora;

  @override
  Widget build(BuildContext context) {
    Color purple = Color(0xFF6c5ce7);
    Color white = Colors.white;

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: sentByMe ? purple : white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message ?? '', // Usar el operador null-aware para evitar null
              style: TextStyle(
                color: sentByMe ? white : purple,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 5),
            Text(
              hora ?? '?',
              style: TextStyle(
                color: (sentByMe ? white : purple).withOpacity(0.7),
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
