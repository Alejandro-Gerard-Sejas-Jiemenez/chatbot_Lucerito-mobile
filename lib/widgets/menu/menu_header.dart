import 'package:flutter/material.dart';
import '../../styles/app_colors.dart';
import '../../styles/text_styles.dart';
import '../../data/mock_data.dart';
import '../../screens/login_screen.dart';

class MenuHeader extends StatelessWidget {
  const MenuHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 4.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(0, -45),
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, -45),
                  child: Text('Hola: ${currentUser.username}', style: TextStyles.title.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -45),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
