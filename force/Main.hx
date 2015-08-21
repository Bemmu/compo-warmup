import flash.geom.*;
import b.*;

class Main extends Game {
	var vignette:Buffer = new Buffer(256, 256, true);
	var landscape:Buffer = new Buffer(256, 256, true);
	var stripes:Buffer = new Buffer(256, 256, true);

	var particles:Particles = null;

	// What if instead of an array of particles you would instead
	// have just a fixed grid which tells how many particles are in
	// each slot? Or even just a binary of whether there is a particle
	// there or not. Would it look bad? Anything goes as long as it
	// looks OK!

 	//      							0 255
	// Red component is X force between -127 .. 128

	var force:ForceBuffer = new ForceBuffer(256, 256);

	override function refresh() {
//		console.log("yay");

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
		particles.draw(b);
		b.edgeBlur(5);

//		b.draw(vignette);//, null, null, flash.display.BlendMode.HARDLIGHT);

		particles.tick();
	}

	override function new() {
		super();

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

		particles = new Particles();
		particles.burst(128, 128, 0, Math.PI * 8, 1, 1, 40, 1000, 0);
	}

	static function main() {
		new Main();
	}
}