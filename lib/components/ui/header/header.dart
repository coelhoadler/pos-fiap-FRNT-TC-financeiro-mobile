import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({
    super.key,
    required this.context,
    required this.displayName,
    this.showMenuIcon = true,
  });

  final BuildContext context;
  final String displayName;
  final bool showMenuIcon;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 4, 92, 114),
      toolbarHeight: 80, // aumenta a altura do header
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: Center(
          // garante que o ícone fique no centro vertical
          child: IconButton(
            icon: Icon(
              (showMenuIcon) ? Icons.menu : Icons.arrow_back,
              color: Color(0xFFFF5031),
              size: 40,
            ),
            onPressed: () {
              if (showMenuIcon) {
                Scaffold.of(context).openDrawer();
              } else {
                Navigator.pop(context, false);
              }
            },
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 18),
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
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
