import 'package:torrento/src/qbittorrent/qbittorrent_interface/qbittorrent_controller.dart';

QbitTorrentController obj = QbitTorrentController('http://192.168.0.102:8080');

void main() async {
  await obj.logIn('natesh', 'password');
}
