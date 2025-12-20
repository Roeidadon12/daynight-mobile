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
          // Show empty state when no user is logged in
          return const SizedBox.shrink();
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
