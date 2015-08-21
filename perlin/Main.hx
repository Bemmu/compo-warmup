import flash.geom.*;
import b.*;

class Main extends Game {
	var vignette:Buffer = new Buffer(256, 256, true);
	var landscape:Buffer = new Buffer(256, 256, true);
	var stripes:Buffer = new Buffer(256, 256, true);


	override function refresh() {


		var alpha = 255;

		for (y in 0...256) {
			for (x in 0...256) {
				var z:Float = frame * 0.01 + x * 0.02 + y * 0.03;
				var v:Float = Perlin.noise(x * 0.1, y * 0.1, z);

				// -1 should be black, 1 should be white
				var i:Int = Std.int((v + 1) * 128);
				if (i == 256) i = 255;

				var color:UInt = Color.rgba(Std.int(i/2), i, Std.int(i/2), alpha);
				if (i < 128) color = 0x5555ff + (alpha << 24);
				if (i >= 100 && i < 128) {
					var r = Perlin.lerp((i - 100)/27.0, 0x55, i/2);
					var g = Perlin.lerp((i - 100)/27.0, 0x55, i);
					var b = Perlin.lerp((i - 100)/27.0, 0xff, i/2);
					color = Color.rgba(Std.int(r), Std.int(g), Std.int(b), alpha);
				}

				landscape.setPixel32(x, y, color);
			}
		}


		b.clear(0x555555);
		var t = new flash.geom.ColorTransform(1.0, 1.0 , 1.0, 1.0);
		b.draw(stripes, null, t);
		landscape.vignette(3, true, true);
		b.draw(landscape);


//		b.draw(stripes, null, null, flash.display.BlendMode.HARDLIGHT);
		b.edgeBlur(5);

//		b.draw(vignette);//, null, null, flash.display.BlendMode.HARDLIGHT);
	}

	override function new() {
		super();
		consoleVisible = false;

		var colors = [
			Color.randomColor(),
			Color.randomColor(),
			Color.randomColor(),
			Color.randomColor(),
			Color.randomColor()
		];

		for (y in 0...256) {
			for (x in 0...256) {
				var color = colors[Std.int(y/20) % colors.length];
				stripes.setPixel(x, y, color);
			}
		}

	}

	static function main() {
		new Main();
	}
}