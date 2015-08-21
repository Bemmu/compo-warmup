import flash.geom.*;
import b.*;

@:bitmap("collision_map.png") class CollisionMap extends flash.display.BitmapData {}

class Main extends Game {

	var physPerFrame = 1000;
	var cMap = new CollisionMap(0,0);
	var ball = {
		x : 420.,
		y : 50.,
		prevX : 420.,
		prevY : 50.,
		xs : 0.,
		ys : 0.
	};
	var gravity = 0.0000001;

	function newBall() {
		ball.x = 440.;
		ball.y = 50.;
		ball.xs = 0.;
		ball.ys = 0.;
		ball.prevX = ball.x;
		ball.prevY = ball.y;
	}

	function physics() {
		ball.prevX = ball.x;
		ball.prevY = ball.y;

		ball.y += ball.ys;
		ball.x += ball.xs;
		if (ball.y < 1.) {
			ball.y = 1;
			ball.ys = 0;
		}
		if (ball.y > cMap.height - 2) {
			newBall();
		}

		var c = cMap.getPixel(Std.int(ball.x), Std.int(ball.y));		
		var b = c & 0xff;
		var g = (c >> 8) & 0xff;
		var r = (c >> 16) & 0xff;

		var inAir = r > 0x9f && g > 0x9f && b < 0x30;

		// Collision!
		if (!inAir) {
			var a = (r-64)/127. * Math.PI;
			trace(a);
			ball.xs = Math.cos(a) * 1./physPerFrame;
			ball.ys = Math.sin(a) * 1./physPerFrame;
			ball.x = ball.prevX;
			ball.y = ball.prevY;
		}

		ball.ys += gravity;
	}

	override function refresh() {
		b.clear(0x555555);
		b.draw(cMap);

		b.ball(Std.int(ball.x), Std.int(ball.y), 5, 0xff0000);
		for (i in 0...physPerFrame) {
			physics();
		}
	}

	override function new() {
		super();
		consoleVisible = false;
		newBall();
	}

	static function main() {
		new Main();
	}
}