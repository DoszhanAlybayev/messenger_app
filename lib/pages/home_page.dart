import 'package:flutter/material.dart';
import 'package:messenger_app/services/auth/auth_service.dart';
import 'package:messenger_app/services/chat_service.dart';
import 'package:messenger_app/pages/chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // УДАЛИТЕ ЭТИ СТРОКИ:
  // final AuthService _authService = AuthService();
  // final ChatService _chatService = ChatService();


  // Перенесите инициализацию сервисов внутрь метода build
  // или сделайте их локальными переменными в тех методах, где они используются.
  // Для простоты и чтобы избежать повторного создания, можно создать их здесь:
  // (Но это не соответствует best practice для StatefulWidget,
  //  поэтому для StatelessWidget лучше передавать их по необходимости или использовать Provider)


  // Однако, чтобы код был более чистым, давайте инициализируем их прямо в build,
  // если HomePage действительно StatelessWidget.
  // Альтернатива: сделать HomePage StatefulWidget, если вы хотите иметь их как поля состояния.
  // Для вашего случая, где сервисы не меняют состояние виджета, StatelessWidget вполне подходит.

  @override
  Widget build(BuildContext context) {
    // Инициализируем сервисы внутри build метода
    // Они будут создаваться каждый раз при перестроении виджета,
    // но для сервисов, которые просто предоставляют API к Firebase, это нормально.
    final AuthService authService = AuthService(); // Без подчеркивания _
    final ChatService chatService = ChatService(); // Без подчеркивания _

    void logout() {
      authService.signOut(); // Вызываем метод на экземпляре без подчеркивания
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Главная"),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _buildUserList(context, chatService, authService), // Передаем сервисы в _buildUserList
    );
  }

  // Метод, который строит список пользователей
  // Теперь он будет принимать экземпляры сервисов
  Widget _buildUserList(BuildContext context, ChatService chatService, AuthService authService) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatService.getUsersStream(), // Используем переданный chatService
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Ошибка StreamBuilder: ${snapshot.error}');
          return Center(child: Text("Ошибка загрузки пользователей: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];
        final String? currentUserId = authService.getCurrentUser()?.uid; // Используем переданный authService

        if (currentUserId == null) {
          return const Center(child: Text("Пользователь не авторизован или UID отсутствует."));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            if (user["uid"] == currentUserId) {
              return Container();
            } else {
              return _buildUserListItem(user, context);
            }
          },
        );
      },
    );
  }

  // Виджет для одного элемента списка пользователя
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return ListTile(
      title: Text(userData["email"]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverUserEmail: userData["email"],
              receiverUserID: userData["uid"],
            ),
          ),
        );
      },
    );
  }
}