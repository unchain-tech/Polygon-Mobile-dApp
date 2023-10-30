import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'TodoList.dart';
import 'TodoListModel.dart';

class WalletConnect extends StatelessWidget {
  const WalletConnect({Key? key}) : super(key: key);

  static Web3App? _walletConnect;
  static String? _url;
  static SessionData? _sessionData;

  String get deepLinkUrl => 'metamask://wc?uri=$_url';

  Future<void> _initWalletConnect() async {
    // 認証と署名のためのWeb3Appインスタンスを作成します。
    _walletConnect = await Web3App.createInstance(
      projectId: '5eb727cbee79907289c211ebe913fc54',
      metadata: const PairingMetadata(
        name: 'Polygon Mobile dApp',
        description: 'A simple todo list application',
        url: 'https://walletconnect.com/',
        icons: [
          'https://walletconnect.com/walletconnect-logo.png',
        ],
      ),
    );
  }

  Future<void> connectWallet() async {
    if (_walletConnect == null) {
      await _initWalletConnect();
    }

    try {
      // セッション（dAppとMetamask間の接続）を開始します。
      final ConnectResponse connectResponse = await _walletConnect!.connect(
        requiredNamespaces: {
          'eip155': const RequiredNamespace(
              chains: ['eip155:80001'],
              methods: ['eth_signTransaction', 'eth_sendTransaction'],
              events: ['chainChanged']),
        },
      );
      final Uri? uri = connectResponse.uri;
      if (uri == null) {
        throw Exception('Invalid URI');
      }
      final String encodedUri = Uri.encodeComponent('$uri');
      _url = encodedUri;

      // Metamaskを起動します。
      await launchUrlString(deepLinkUrl, mode: LaunchMode.externalApplication);

      // セッションが確立されるまで待機します。
      final Completer<SessionData> session = connectResponse.session;
      _sessionData = await session.future;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Connect'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await connectWallet();
              await context.read<TodoListModel>().setWalletDetails(
                  deepLinkUrl, _walletConnect!, _sessionData!);
            } catch (error) {
              debugPrint('connectWallet: $error');
            }

            // TodoListへ遷移します。
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const TodoList()));
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
