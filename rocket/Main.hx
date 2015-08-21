import flash.geom.*;
import flash.display.*;
import b.*;

class State {
	public static function pack(x:UInt, y:UInt, xs:UInt, ys:UInt, a:UInt) {
		return ((x&0x3ff)<<22) + ((y&0x3ff)<<12) + (((xs+8)&0xf)<<8) + (((ys+8)&0xf)<<4) + (a&0xf);
	}

	public static function x(s) {
		return (s>>22) & 0x3ff;
	}

	public static function y(s) {
		return (s>>12) & 0x3ff;
	}

	public static function xs(s) {
		return ((s>>8) & 0xf) - 8;
	}

	public static function ys(s) {
		return ((s>>4) & 0xf) - 8;
	}

	public static function a(s) {
		return s & 0xf;
	}


	public static function aRad(s) {
		return a(s)/16.0 * Math.PI * 2;
	}

	// Can do one of four things:
	//
	// 0 Accelerate
	// 1 Turn left
	// 2 Turn right
	// 3 Do nothing
	public static function accelerate(s:UInt) {
		var xi = 0, yi = 0;
		switch(a(s)) {
			case 0:
				xi = 3;
			case 1:
				xi = 3;
				yi = -1;
			case 2:
				xi = 2;
				yi = -2;
			case 3:
				xi = 1;
				yi = -3;
			case 4:
				xi = 0;
				yi = -3;
			case 5:
				xi = -1;
				yi = -3;
			case 6:
				xi = -2;
				yi = -2;
			case 7:
				xi = -3;
				yi = -1;
			case 8:
				xi = -3;
				yi = 0;
			case 9:
				xi = -3;
				yi = 1;
			case 10:
				xi = -2;
				yi = 2;
			case 11:
				xi = -1;
				yi = 3;
			case 12:
				xi = 0;
				yi = 3;
			case 13:
				xi = 1;
				yi = 3;
			case 14:
				xi = 2;
				yi = 2;
			case 15:
				xi = 3;
				yi = 1;
		}

		// Accelerate only if max acceleration not crossed
		var _xs = xs(s) + xi;
		var _ys = ys(s) + yi;

		var valid = _xs >= -7 && _xs <= 7 && _ys >= -7 && _ys <= 7;
		if (!valid) {
			_xs = xs(s);
			_ys = ys(s);
		}

		return doNothing(pack(
			x(s),
			y(s),
			_xs,
			_ys,
			a(s)
		));
	}

	public static function turn(s:UInt, left:Bool) {
		var _a = a(s);

		if (left) {
			_a += 1;
			if (_a == 16) _a = 0;
		} else {
			_a -= 1;
			if (_a == -1) _a = 15;
		}

		return doNothing(pack(
			x(s),
			y(s),
			xs(s),
			ys(s),
			_a
		));		
	}

	public static function doNothing(s:UInt) {

		// Gravity
		var _ys = ys(s) < 7 ? ys(s) + 1 : ys(s);

		// Momentum
		var _x = x(s) + xs(s);
		var _y = y(s) + ys(s);

		// Move only if that would not take outside borders
		var valid = _x >= 0 && _x <= 0x3ff && _y >=0 && _y <= 0x3ff;
		if (!valid) {
			_x = x(s);
			_y = y(s);
		}

		return pack(
			_x,
			_y,
			xs(s),
			_ys,
			a(s)
		);
	}

}

class Main extends Game {
	/* state space is 10 * 10 * 1000 * 1000 * 12 is about 1.2 billion nodes */

	// 2 147 483 648 possible states

	var state:UInt = State.pack(500, 500, 0, 0, 4);

	function drawRocket() {
		var a = State.aRad(state);
		var r = 10;
		var color = 0x0;
		var s = new Shape();
		s.graphics.beginFill(color);
		s.graphics.moveTo(State.x(state) + Math.cos(a)*r, State.y(state) - Math.sin(a)*r);
		s.graphics.lineTo(State.x(state) + Math.cos(a + Math.PI - Math.PI/4)*r, State.y(state) - Math.sin(a + Math.PI - Math.PI/4)*r);
		s.graphics.lineTo(State.x(state) + Math.cos(a + Math.PI + Math.PI/4)*r, State.y(state) - Math.sin(a + Math.PI + Math.PI/4)*r);
		s.graphics.endFill();
		var quality = flash.display.StageQuality.BEST;
		b.drawWithQuality(s, null, null, null, null, false, quality);		
	}

	override function refresh() {
		b.clear(0x555555);
		drawRocket();
		state = State.accelerate(state);
//		state = State.doNothing(state);
//		state = State.turn(state, true);
//		state = State.turn(state, false);
	}

	override function new() {
		super();
		consoleVisible = false;
	}

	static function main() {
		new Main();
	}
}