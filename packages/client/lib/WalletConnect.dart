import 'package:client/TodoList.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

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

  Future<String?> connectWallet() async {
    if (_walletConnect == null) {
      await _initWalletConnect();
    }

    // セッション（dAppとMetamask間の接続）を開始します。
    final ConnectResponse connectResponse = await _walletConnect!.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
            chains: ['eip155:80001'],
            methods: ['eth_signTransaction'],
            events: ['chainChanged']),
      },
    );
    final Uri? uri = connectResponse.uri;
    if (uri == null) {
      return null;
    }

    final String encodedUri = Uri.encodeComponent('$uri');
    _url = encodedUri;

    await launchUrlString(deepLinkUrl, mode: LaunchMode.externalApplication);

    // セッションが確立されるまで待機します。
    _sessionData = await connectResponse.session.future;

    // セッションを認証したアカウントを取得します。
    final String account = NamespaceUtils.getAccount(
      _sessionData!.namespaces.values.first.accounts.first,
    );

    return account;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Connect'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            connectWallet().then((value) {
              debugPrint('Connected $value');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const TodoList()));
            }).catchError((error) {
              debugPrint('Error $error');
            });
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
