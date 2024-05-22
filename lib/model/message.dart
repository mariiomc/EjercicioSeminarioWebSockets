class Message {
  String message;
  String sentByMe;
  String hora;

  Message({required this.message, required this.sentByMe, required this.hora});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json["message"],
      sentByMe: json["sentByMe"],
      hora: json["hora"]
    );
  }
}
