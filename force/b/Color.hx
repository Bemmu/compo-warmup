package b;

class Color {
	public static function rgb(r:Int, g:Int, b:Int):UInt {
		return ((r & 255) << 16) + ((g & 255) << 8) + (b & 255);
	}

	public static function fromFloats(r:Float, g:Float, b:Float):UInt {
		return rgb(Std.int(r * 256), Std.int(g * 256), Std.int(b * 256));
	}

	public static function rgba(r:Int, g:Int, b:Int, a:Int):UInt {
		return ((a&255) << 24) + ((r & 255) << 16) + ((g & 255) << 8) + (b & 255);
	}

	public static function redComponent(rgba:UInt) {
		return (rgba >> 16) & 255;
	}

	public static function greenComponent(rgba:UInt) {
		return (rgba >> 8) & 255;
	}

	public static function blueComponent(rgba:UInt) {
		return rgba & 255;
	}

	// Inspired by https://github.com/haqu/tiny-wings
	public static function randomColor():UInt {
		var minSum = 1.75;
		var minDelta = 0.60;
		var r = 0., g = 0., b = 0., min:Float, max:Float;
		while (true) {
			r = Math.random();
			g = Math.random();
			b = Math.random();
			min = Math.min(Math.min(r, g), b);
			max = Math.max(Math.max(r, g), b);
			if (max-min < minDelta) continue;
			if (r+g+b < minSum) continue;
			break;
		}
		return fromFloats(r, g, b);
	}
}