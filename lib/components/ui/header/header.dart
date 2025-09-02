import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key, required this.context, required this.displayName});

  final BuildContext context;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF004D61),
      toolbarHeight: 80, // aumenta a altura do header
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: Center(
          // garante que o ícone fique no centro vertical
          child: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFFF5031), size: 40),
            onPressed: () {
              // Ação ao pressionar o ícone de menu
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 25),
          child: Center(
            child: Row(
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Color(0xFFFF5031),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_2_outlined,
                    color: Color(0xFFFF5031),
                    size: 30,
                  ),
                  onPressed: () {
                    // Ação ao pressionar o ícone de perfil
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
