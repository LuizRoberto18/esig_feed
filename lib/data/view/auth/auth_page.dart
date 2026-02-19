import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: width * 0.35,
                      height: height * 0.15,
                      decoration: BoxDecoration(
                        color: Color(0xFFFEAE88),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(width * 0.2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        "ESIG Feed",
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: width,
                  height: height * 0.5,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Header(width: width),
                      _Forms(width: width),
                      _ActionButton(width: width, height: height),
                    ],
                  ),
                ),
                Container(
                  width: width * 0.32,
                  height: height * 0.12,
                  decoration: BoxDecoration(
                    color: Color(0xFF3695D2),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(width * 0.2),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double width;
  const _Header({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width * .1,
          child: Divider(color: Color(0xFFFEAE88), thickness: 4),
        ),
        Text(
          'Login',
          style: TextStyle(fontSize: width * 0.1, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _Forms extends StatelessWidget {
  final double width;
  const _Forms({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Usuário',
            filled: true,
            hintStyle: TextStyle(color: Colors.white),
            fillColor: Colors.transparent,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
        ),
        SizedBox(height: 24),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Senha',
            filled: true,
            hintStyle: TextStyle(color: Colors.white),
            fillColor: Colors.transparent,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double width;
  final double height;
  const _ActionButton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        fixedSize: Size(width, height * 0.05),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text("Entrar"),
    );
  }
}
