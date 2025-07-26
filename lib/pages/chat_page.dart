import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger_app/services/auth/auth_service.dart'; // <-- Правильный путь к AuthService
import 'package:messenger_app/services/chat_service.dart';     // <-- Правильный путь к ChatService
// ... остальной код chat_page.dart ...

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Scroll controller для автоматической прокрутки к последнему сообщению
  final ScrollController _scrollController = ScrollController();

  void sendMessage() async {
    // Отправляем сообщение, только если текстовое поле не пустое
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      // Очищаем текстовое поле после отправки
      _messageController.clear();
      // Прокручиваем к последнему сообщению
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Используем Future.delayed, чтобы дать ListView обновиться
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUserEmail)),
      body: Column(
        children: [
          // Область сообщений
          Expanded(
            child: _buildMessageList(),
          ),

          // Поле ввода сообщения
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Метод для построения списка сообщений
  Widget _buildMessageList() {
    String currentUserId = _authService.getCurrentUser()!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverUserID, currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Ошибка в чате: ${snapshot.error}'); // Для отладки
          return Center(child: Text('Ошибка загрузки сообщений: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Прокрутка к последнему сообщению при загрузке и обновлении
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });


        return ListView(
          controller: _scrollController, // Прикрепляем контроллер
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  // Метод для построения одного элемента сообщения
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Выравнивание сообщений (отправитель справа, получатель слева)
    var alignment = (data['senderId'] == _authService.getCurrentUser()!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: (data['senderId'] == _authService.getCurrentUser()!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(data['senderEmail'].split('@')[0], style: const TextStyle(fontSize: 12, color: Colors.grey)), // Отображаем только имя до @
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (data['senderId'] == _authService.getCurrentUser()!.uid)
                  ? Colors.blue[100]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(data['message'], style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Метод для построения поля ввода сообщения и кнопки
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Текстовое поле
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Введите сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              obscureText: false,
            ),
          ),

          // Кнопка отправки
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}