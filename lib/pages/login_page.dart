import 'package:flutter/material.dart';
import 'package:messenger_app/services/auth/auth_service.dart'; // Правильный путь к AuthService
import 'package:messenger_app/pages/register_page.dart'; // Правильный путь к RegisterPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Контроллеры для полей ввода
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Флаг для управления состоянием загрузки (для индикатора)
  bool _isLoading = false;

  @override
  void dispose() {
    // Освобождаем ресурсы контроллеров при удалении виджета
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Вход")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Поле для ввода Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            // Поле для ввода пароля
            TextField(
              controller: passwordController,
              obscureText: true, // Скрываем вводимый текст
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            const SizedBox(height: 20),
            // Кнопка "Войти"
            ElevatedButton(
              onPressed: _isLoading ? null : () async { // Отключаем кнопку, если идет загрузка
                final authService = AuthService(); // Создаем экземпляр AuthService
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                // Показываем индикатор загрузки
                setState(() {
                  _isLoading = true;
                });

                try {
                  // Пытаемся выполнить вход
                  await authService.signInWithEmailAndPassword(email, password);
                  // Если вход успешен, AuthGate автоматически перенаправит на HomePage.
                  // Здесь не нужно вызывать setState(_isLoading = false), т.к. виджет будет dispose.
                } on Exception catch (e) {
                  // Если произошла ошибка, и виджет все еще в дереве, скрываем загрузку
                  if (mounted) { // Проверка mounted перед setState
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  // Показываем сообщение об ошибке пользователю
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().split(':').last.trim())),
                  );
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Индикатор загрузки
                  : const Text('Войти'),
            ),
            // Кнопка для перехода на страницу регистрации
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('Еще нет аккаунта? Зарегистрируйтесь'),
            ),
          ],
        ),
      ),
    );
  }
}