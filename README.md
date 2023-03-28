## 💬 Polygon-Generative-NFT(prototype)

本レポジトリは Polygon-Generative-NFT の完成版を示したものになります。

以下の手順を実行することで Polygon-Generative-NFT の挙動を確認できます。

### レポジトリのクローン

[こちら](https://github.com/unchain-tech/Polygon-Mobile-dApp.git)から Polygon-Generative-NFT をクローンします。

その後下のコマンドを実行することで必要なパッケージをインストールしましょう。

```
yarn
```

## コントラクトのテスト、デプロイ

まずは[こちら](https://app.unchain.tech/learn/Polygon-Mobile-dApp/ja/3/1/)を参考に、Alchemy と metamask の準備をしましょう。

次に packages/contract に自分のウォレットアドレスの recovery phrase と Alchemy の HTTP Key(polygon)を指定します。`.secret`,`.env`
ファイルを作成しましょう。前者には metamask の recovery phrase を、後者には alchemy の HTTP key を入力します。
`.secret`

```
Metamask_Recovery_Phrase
```

`.env`

```
POLYGON_URL=Alchemy_HTTP_Key
```

では最後にコントラクトのデプロイを下のコマンドを実行することで行なっていきましょう。

```
yarn contract migrate:matic
```

これでコントラクトの準備は終了です。

## フロントの立ち上げ

まずは`packages/client`に`smartcontract`というディレクトリを作成して、その中に先ほど migrate した際に得た`TodoContract.json`というファイルをコピーして貼り付けましょう。

次に[こちら](https://app.unchain.tech/learn/Polygon-Generative-NFT/ja/3/2/)の section ３-lesson ２ を参考にしながら環境変数などを設定していきましょう。

全ての準備が整ったら、エミュレータや実機を接続していることを確認して下のコマンドを実行してフロントを立ち上げましょう。

```
yarn client start
```
