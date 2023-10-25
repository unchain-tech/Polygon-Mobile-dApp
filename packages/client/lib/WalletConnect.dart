import 'package:flutter/material.dart';

class WalletConnect extends StatelessWidget {
  const WalletConnect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Connect'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Wallet Connectのロジックを追加
            debugPrint('Wallet Connect');
          },
          child: const Text(
            'Wallet Connect',
            style: TextStyle(fontSize: 24),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
          ),
        ),
      ),
    );
  }
}
