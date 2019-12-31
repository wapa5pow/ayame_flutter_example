# ayame_flutter_example

WebRTC Signaling Server Ayame用のFlutterクライアントサンプルです。

## 使い方

Ayameを使えるようにするため[WebRTC シグナリングサービス Ayame Lite ベータ版](https://ayame-lite.shiguredo.jp/beta)にアクセスしてGitHubでSign inしてください。
ここではシグナリングキーをメモしておきます。

ルームへの接続情報は[ここ](https://github.com/wapa5pow/ayame_flutter_example/blob/master/lib/sendrecv_screen.dart#L196)にあるので、roomIdは認証ありにするために`@`を含んだIdをよしなに、keyをさきほどメモしたものに書き換えます。

### 実機にインストールする場合

シミュレータでカメラがいい感じに動かないので、実機にインストールして確認しています。

Androidの場合はそのままビルドすればインストールできます。

iOSの場合はBundle IDと証明書をいいかんじにしてインストールします。


