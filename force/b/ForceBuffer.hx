package b;

// There are forces that are location-specific, like gravity/repulsion/wind. It doesn't which
// particle you are as long as you are there. But then there are some which do depend on who you
// are, such as springs, which will be different based on which other particle you are connected to.
//
// This is for representing such location-specific forces as a buffer where each pixel has its own
// force, where repulsive or gravity forces can be painted at certain locations. 
//
// The whole force buffer can also be visually represented as red & green values by drawing it to
// a Buffer.
//
// Grid point x = 0 contains forces for pixel x = 0 .. 0.9999
//
// Maybe if you rendered something like plasma or perlin noise to this, you'd get cool swirling

class ForceBuffer {
	var xsGrid:Array<Array<Float>>;
	var ysGrid:Array<Array<Float>>;

	public function new(width:Int = 300, height:Int = 200) {
		// X & Y forces at each grid location
		xsGrid = [for (x in 0...width) [for (y in 0...height) 0.0]];
		ysGrid = [for (x in 0...width) [for (y in 0...height) 0.0]];
	}

	public function xsAt(x:Int, y:Int) {
		if (x < 0) return 1.0;
		if (x >= 256) return -1.0;
		if (y < 0 || y >= 256) return 0.0;
		return xsGrid[x][y];
	}

	public function ysAt(x:Int, y:Int) {
		if (x < 0 || x >= 256) return 0.0;
		if (y < 0) return 1.0;
		if (y >= 256) return -1.0;
		return ysGrid[x][y];
	}

	public function add(x:Int, y:Int, xs:Float, ys:Float) {
		xsGrid[x][y] += xs;
		ysGrid[x][y] += ys;
	}

	public function addRepulsion(x:Int, y:Int) {
		// Should draw it up to the distance where it would be...
		// Well at 60fps if it only moves once per second, then
		// lower than that I don't care. So less than 0.01666...
		// you don't need to draw.

		// Are these repulsive forces supposed to fall of squared
		// or linearly?

		// So need to solve for
		// 0.1666 = 1/d^2
		// That's distance of about 8 pixels
		// So if you draw a box of 16 x 16 then that will include all
		// at the corner the distance will be 11 and going straight right it would be 8


		// ???
		// Also what does strength mean here exactly ..

		for (_y in y - 8...y + 8) {
			for (_x in x - 8...x + 8) {				
				var strength = 1.0/( (_y-y)*(_y-y) + (_x-x)*(_x-x) );

				// Get unit vector in the correct direction
				var vx:Float = _x - x;
				var vy:Float = _y - y;
				var magnitude = Math.sqrt(vx*vx + vy*vy);
				vx /= magnitude;
				vy /= magnitude;

				// Scale it to correct strength and save
				add(_x, _y, vx * strength, vy * strength);
			}
		}
	}
}
