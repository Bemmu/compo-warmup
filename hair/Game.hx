import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;
import flash.text.*;
import b.*;

typedef Hair = {
	var length:Int;
	var a:Float; // angle this hair pokes out from head
	var xOffset:Float;
	var yOffset:Float;
	var radiusOffset:Float;
	var wScale:Float;
	var color:UInt;
}

class Game {
	var b:Buffer;
	var p = new Particles();
	var hairstyle:Array<Hair> = [];
	var console:Console = new Console();

	function hairdo() {
		for (i in 0...1600) {
			var d = 0.5 + Math.random()*0.5;
			var r = Std.int(Math.min(0xff, 0xbb * d));
			var g = Std.int(Math.min(0xff, 0x98 * d));
			var b = Std.int(Math.min(0xff, 0x6e * d));

			hairstyle.push({
				length : 10 + Std.int(Math.random() * 20),
				a : Math.random() * 1,
				xOffset : Math.random() - 0.5,
				yOffset : Math.random() - 0.5,
				radiusOffset : 1.01 + Math.random() * 0.1,
				wScale : 1.0,// + Math.random() * 2
				color : (r << 16) + (g << 8) + b
			});
		}
	}

	function refresh(e:flash.events.Event) {
		b.clear();
		p.reset();

		var t = Date.now().getTime();

		var radius = 55;
		var xCenter = b.width/2;
		var yCenter = b.height/2;
		b.ball(xCenter, yCenter, radius, 0xffffff);

		var portion = 0.5;
		var portionOffset = Math.PI / 2;

		var a = Math.PI/2 + Math.sin(t * 0.001) * 0.1;
		var w:Float; // angular rate
		w = Math.cos(t * 0.001) * 0.1; // derivative of sin is cos

		var x:Float;
		var y:Float;
		for (hair in hairstyle) {

			x = xCenter + Math.cos(a + portionOffset) * radius * hair.radiusOffset;
			y = yCenter + Math.sin(a + portionOffset) * radius * hair.radiusOffset;

//			b.ball(x, y, 3, 0x0000);

			var particle = p.makeParticle();
			particle.lifetime = hair.length;
			particle.x = x + hair.xOffset;
			particle.y = y + hair.yOffset;
			particle.xs = Math.cos(a + portionOffset + hair.a) + 3 * Math.sin(w * hair.wScale);
			particle.ys = Math.sin(a + portionOffset + hair.a) + 3 * Math.cos(w * hair.wScale);
			particle.gravity = 0.02;
			particle.floorY = 1000;
			particle.color = hair.color;

			a += Math.PI * 2 * portion / hairstyle.length;
		}

		// Eyes
		b.ball(xCenter + Math.cos(a - 0.5) * radius * 0.5, yCenter + Math.sin(a - 0.5) * radius * 0.5, 5, 0);
		b.ball(xCenter + Math.cos(a + 0.5) * radius * 0.5, yCenter + Math.sin(a + 0.5) * radius * 0.5, 5, 0);

		// Mouth
		for (i in 0...10) {
			var _a = a - 1 + i * 0.2 + Math.PI;
			b.ball(xCenter + Math.cos(_a) * radius * 0.5, yCenter + Math.sin(_a) * radius * 0.5, 3, 0);
		}

		for (i in 0...100) {
			p.draw(b);
			p.pushOutsideCircle(xCenter, yCenter, radius);
			p.tick();
		}
	}

	function new() {
		b = new Buffer(960, 600);
		flash.Lib.current.addChild(new Bitmap(b));
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, refresh);

		hairdo();
	}

	static function main() {
		var what = new Game();
	}
}