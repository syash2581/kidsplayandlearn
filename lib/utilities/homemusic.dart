import 'package:PlayAndLearn/utilities/Constants.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeMusic {
  AudioPlayer player,player2;
  AudioCache cache,cache2;

  Duration position = new Duration();
  Duration musiclength = new Duration();

  Duration position2 = new Duration();
  Duration musiclength2 = new Duration();

  bool isPlaying = false;

  HomeMusic() {
    player = AudioPlayer();
    cache = AudioCache(fixedPlayer: player);


    player2 = AudioPlayer();
    cache2 = AudioCache(fixedPlayer: player2);
    //allows us to get music duration

    try {
      // cache.load(Constants.tunePath);
    } catch (e) {
      print(e.message);
    }
  }

  void play({String arg = "tunes/tune1.mp3"}) {
    if (!isPlaying) {
      this.player.play(arg);
      isPlaying = true;
    }

    void pause() {
      this.player.pause();
      isPlaying = false;
    }
  }
}
