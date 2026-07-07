import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playNotification() async {
    try {
      await _player.play(AssetSource('sounds/bell-notif.wav'));
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}
