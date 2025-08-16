import 'package:day_night/models/user.dart';
import 'package:flutter/material.dart';
import '../../controllers/user/user_controller.dart';
import 'package:provider/provider.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, _) {
        final user = controller.user;
        if (user == null) {
          // Automatically load the demo user if not loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.user == null) {
              controller.setUser(
                User(
                  fullName: 'רועי, צהריים טובים',
                  phoneNumber: '1234567890',
                  email: 'roi@example.com',
                  sex: 'Male',
                  dob: DateTime(1990, 1, 1),
                  idNumber: '123456789',
                  thumbnail: 'https://randomuser.me/api/portraits/men/1.jpg',
                  address: 'אזור תל אביב, ישראל',
                ),
              );
            }
          });
          // Show a placeholder while loading
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SizedBox(
          height: 120, // Limit the height of the header
          child: Container(
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              textDirection: Directionality.of(context),
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: Directionality.of(context),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        textDirection: Directionality.of(context),
                        children: [
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            user.address ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textDirection: Directionality.of(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: user.thumbnail != null ? NetworkImage(user.thumbnail!) : null,
                  radius: 32,
                  child: user.thumbnail == null ? const Icon(Icons.person, size: 32, color: Colors.white) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
