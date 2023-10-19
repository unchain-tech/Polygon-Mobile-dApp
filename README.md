## 💬 Polygon-Mobile-dApp(prototype)

本レポジトリは Polygon-Mobile-dApp の完成版を示したものになります。

以下の手順を実行することで Polygon-Mobile-dApp の挙動を確認できます。

### レポジトリのクローン

[こちら](https://github.com/unchain-tech/Polygon-Mobile-dApp.git)から Polygon-Mobile-dApp をクローンします。

その後下のコマンドを実行することで必要なパッケージをインストールしましょう。

```
yarn
```

## コントラクトのデプロイ

まずは[こちら](https://app.unchain.tech/learn/Polygon-Mobile-dApp/ja/1/3/)を参考に、Alchemy と metamask の準備をしましょう。

次に`packages/contract`に`.env`ファイルを作成して下のように記述しましょう。`YOUR_PRIVATE_KEY`にはmetamaskの秘密鍵を指定して下さい。`YOUR_ALCHEMY_KEY`にはAlchemyのAPIキーを指定してください。

`.env`

```
PRIVATE_KEY=YOUR_PRIVATE_KEY
STAGING_ALCHEMY_KEY=YOUR_ALCHEMY_KEY
```

では最後にコントラクトのデプロイを行いましょう。下のコマンドを実行してください。

```
yarn contract deploy
```

これでコントラクトの準備は終了です。

## フロントの立ち上げ

[こちら](https://app.unchain.tech/learn/Polygon-Mobile-dApp/ja/1/1/)の Section1-Lesson1 ✨ Flutter の環境構築をする を参考にしながらFlutterの環境構築を行ないましょう。

次に、`packages/client`に`smartcontract`というディレクトリを作成して、その中に先ほどデプロイした際に得た`TodoContract.json`というファイルをコピーして貼り付けましょう。

最後に`packages/client`に`.env`ファイルを作成して下のように記述しましょう。`YOUR_DEPLOYED_CONTRACT_ADDRESS`には、先ほどデプロイした際に得たコントラクトアドレスを指定してください。`PRIVATE_KEY`はpackages/contract/.envと同じものを指定して下さい。

`.env`

```
CONTRACT_ADDRESS=YOUR_DEPLOYED_CONTRACT_ADDRESS
PRIVATE_KEY=YOUR_PRIVATE_KEY
```

全ての準備が整ったら、エミュレータや実機を接続していることを確認して下のコマンドを実行してフロントを立ち上げましょう。

```
yarn client start
```
