import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;
import Star;

class Game {
	var buffer:BitmapData = null;
	var stars:Array<Star> = null;

	function refresh(e:flash.events.Event) {
		buffer.fillRect(new Rectangle(0, 0, 960, 600), 0xff000000);
		for (star in stars) {
			star.draw(buffer);
			star.z -= 0.05;
			if (star.z < 0) {
				star.z = 10.0;
			}
		}
	}

	var channel:SoundChannel;

	public function new() {
		// lame -b 320 -h engine.wav engine.mp3
		haxe.Timer.delay(function () {
			var data = haxe.Resource.getBytes("engine-sound");
			var snd = new Sound();
			snd.loadCompressedDataFromByteArray(data.getData(), data.length);
//			channel = snd.play(0, 9999);
		}, 250);

		trace("Space, the final frontier.");

		buffer = new BitmapData(960, 600);
		flash.Lib.current.addChild(new Bitmap(buffer));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);

		stars = new Array();
		var i = 10000;
		while (i > 0) {
			stars.push(new Star());
			i--;
		}
	}

	static function main() {
		var what = new Game();
	}
}