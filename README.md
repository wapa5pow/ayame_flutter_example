# ayame_flutter_example

WebRTC Signaling Server Ayame用のFlutterクライアントサンプルです。

## 使い方

Ayameを使えるようにするため[WebRTC シグナリングサービス Ayame Lite ベータ版](https://ayame-lite.shiguredo.jp/beta)にアクセスしてGitHubでSign inしてください。
ここではシグナリングキーをメモしておきます。

ルームへの接続情報は以下のようなコードにあるので書き換えます。
roomIdは認証ありにするために`@`を含んだIdをよしなにします。
keyをさきほどメモしたものに書き換えます。
（シグナリングキーはすでに再生しているので以下は無効です）

```
final registerMessage = jsonEncode(<String, String>{
  "type": "register",
  "clientId": "${Random().nextInt(pow(2, 32).toInt())}",
  "roomId": "wapa5pow@ayame-test-sdk",
  "key": "vkfKgOwAwiNkwn5rPfc7lwfEEvedwkSnDnMpEmk6pmHrJ0WD",
});
```

### 実機にインストールする場合

シミュレータでカメラがいい感じに動かないので、実機にインストールして確認しています。

Androidの場合はそのままビルドすればインストールできます。

iOSの場合はBundle IDと証明書をいいかんじにしてインストールします。


