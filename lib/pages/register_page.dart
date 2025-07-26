import 'package:flutter/material.dart';
import 'package:messenger_app/services/auth/auth_service.dart'; // Правильный путь к AuthService

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Контроллеры для полей ввода
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Флаг для управления состоянием загрузки (для индикатора)
  bool _isLoading = false;

  @override
  void dispose() {
    // Освобождаем ресурсы контроллеров при удалении виджета
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
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
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            const SizedBox(height: 12),
            // Поле для подтверждения пароля
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Подтвердите пароль'),
            ),
            const SizedBox(height: 20),
            // Кнопка "Зарегистрироваться"
            ElevatedButton(
              onPressed: _isLoading ? null : () async { // Отключаем кнопку, если идет загрузка
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                // Проверка совпадения паролей
                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Пароли не совпадают")),
                  );
                  return; // Прерываем выполнение, если пароли не совпадают
                }

                // Показываем индикатор загрузки
                setState(() {
                  _isLoading = true;
                });

                try {
                  final authService = AuthService(); // Создаем экземпляр AuthService
                  // Пытаемся выполнить регистрацию
                  await authService.signUpWithEmailAndPassword(email, password);
                  // Если регистрация успешна, возвращаемся на страницу входа
                  Navigator.pop(context);
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
                  : const Text('Зарегистрироваться'),
            ),
            // Кнопка для перехода на страницу входа (если уже есть аккаунт)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Вернуться на страницу входа
              },
              child: const Text('Уже есть аккаунт? Войдите'),
            ),
          ],
        ),
      ),
    );
  }
}