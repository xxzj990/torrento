import 'package:torrento/torrento.dart';

void main(List<String> args) async {
  QbitTorrentController obj = QbitTorrentController('http://192.168.0.102:8080');
  await obj.logIn('natesh', 'password');
  await obj.getFilesOfTorrent('fb71eea2959ea406b0feeca4c28cf1c15495e80f');

  await obj.addTorrent(
      'magnet:?xt=urn:btih:0d18397945bcc9f495818aa2c823ab167dc8da5c&dn=The.Lion.King.2019.1080p.BluRay.H264.AAC-RARBG', null);

  var torrents = await obj.getTorrentsList(filter: TorrentFilter.paused);

  torrents.forEach((t) => print('${t['name']} : ${t['hash']}'));

  print('Starting all torrents');
  await obj.startAllTorrents();

  print(await obj.getVersion());

  await obj.logOut();
}
