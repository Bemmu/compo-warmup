// (c) Bemmu Sepponen

package b;

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;
import flash.text.*;

class Buffer extends BitmapData {
	static var pt0 = new Point(0, 0);
	var distanceToCorner:Float;

	public function ball(x:Float, y:Float, radius:Float, color:UInt) {
		var s = new Shape();
		s.graphics.beginFill(color);
		s.graphics.drawCircle(x, y, radius);
		s.graphics.endFill();
		var quality = flash.display.StageQuality.BEST;
		drawWithQuality(s, null, null, null, null, false, quality);		
	}

	static public function darkerColor(argb, darken:Float = 0.5) {
		var a = argb >> 24;
		var r = argb >> 16 & 0xff;
		var g = argb >> 8 & 0xff;
		var b = argb & 0xff;
		r = Std.int(r * darken);
		g = Std.int(g * darken);
		b = Std.int(b * darken);
		var _rgb = (a << 24) + (r << 16) + (g << 8) + b;
		return _rgb;
	}

	var blurFilter:BlurFilter = null;
	var blurred:Buffer = null;
	public function bloom(strength = 4.0) {

		// Make a copy of bitmap (keep it around to avoid realloc)
		if (blurred == null) {
			blurred = new Buffer(width, height, true);
		}
		blurred.clear(0x00000000);
		blurred.draw(this);

		// Blur the copy (ditto)

//		if (blurFilter == null) {
			blurFilter = new BlurFilter(strength, strength, 3);
//		}
		blurred.applyFilter(blurred, blurred.rect, pt0, blurFilter);

		// Add blurred version to original
		draw(blurred, null, null, ADD);
	}

	public function gradient(smallerY:Int = 0, biggerY:Int = 100, beginColor:UInt = 0xffffff, endColor:UInt = 0x000000) {
		var br:Int = beginColor >> 16 & 0xff;
		var bg:Int = beginColor >> 8 & 0xff;
		var bb:Int = beginColor & 0xff;
		var er:Int = endColor >> 16 & 0xff;
		var eg:Int = endColor >> 8 & 0xff;
		var eb:Int = endColor & 0xff;
		var rect:Rectangle = new Rectangle(rect.x, rect.y, rect.width, 1);
		for (y in smallerY...biggerY) {
			var p:Float = (y - smallerY)/(biggerY - smallerY - 1);
			var r = Std.int(br + (er - br) * p);
			var g = Std.int(bg + (eg - bg) * p);
			var b = Std.int(bb + (eb - bb) * p);
			var rgb = (0xff << 24) + (r << 16) + (g << 8) + b;
			rect.y = y;
			fillRect(rect, rgb);
		}
	}

	public function puncture(x:Int, y:Int, w:Int, h:Int) {
		setPixel32(x, y, 0);
		setPixel32(x + w - 1, y, 0);
		setPixel32(x, y + h - 1, 0);
		setPixel32(x + w - 1, y + h - 1, 0);
	}

	//   #############
	//  #             #
	//  #             #
	//  #             #
	//   #############
	public function edgeRect(x:Int, y:Int, w:Int, h:Int,
			edgeColor = 0xff005234,
			innerColor = 0xff030803
		) {

		// Outer punctured edge
		fillRect(new Rectangle(
			x, y, w, h
		), edgeColor);
		puncture(x, y, w, h);

		// Filling
		fillRect(new Rectangle(
			x + 1, y + 1, w - 2, h - 2
		), innerColor);

		// Gutter
		var gutterCornerColor = darkerColor(edgeColor, 0.6);
		setPixel32(x + 1, y + 1, gutterCornerColor);
		setPixel32(x + w - 2, y + 1, gutterCornerColor);
		setPixel32(x + w - 2, y + h - 2, gutterCornerColor);
		setPixel32(x + 1, y + h - 2, gutterCornerColor);
		var gutterColor = darkerColor(edgeColor, 0.3);
		fillRect(new Rectangle(
			x + 1, y + 2, 1, h - 4
		), gutterColor);
		fillRect(new Rectangle(
			x + w - 2, y + 2, 1, h - 4
		), gutterColor);
		fillRect(new Rectangle(
			x + 2, y + 1, w - 4, 1
		), gutterColor);
		fillRect(new Rectangle(
			x + 2, y + h - 2, w - 4, 1
		), gutterColor);

//		fillRect();


	}

	public function plasma(t:Float) {
		for (x in 0...width) {
			for (y in 0...height) {
				var r = Std.int(Math.sin(x*0.01 + t * 0.001 + Math.sin(t*0.0020))*100 + 128);
				var g = Std.int(Math.sin(y*0.01 + t * 0.001 + Math.sin(t*0.0015))*100 + 128);
				var b = Std.int(Math.sin(x*0.01 + y*0.01 + t * 0.001 + Math.sin(t*0.0025))*100 + 128);
				var rgb = 0xff000000 + (r << 16) + (g << 8) + b;
				setPixel32(x, y, rgb);
			}
		}		
	}

	function clamp(x:Float, max = 1, min = 0) {
		return Math.max(Math.min(max, x), min);
	}

	function blur() {
		applyFilter(this, this.rect, pt0, new flash.filters.BlurFilter(8, 8, 3));
	}

	public function edgeBlur() {
		var blurred = clone();
		var blurred = new Buffer(width, height, true);
		var mask = new Buffer(width, height, true);
		mask.vignette(1, true);
		blurred.copyPixels(this, this.rect, pt0, mask);
		blurred.blur();
		draw(blurred);
	}

	// Makes a vignette either only in the alpha channel, or having full
	// alpha and setting the vignette in the color channels instead.
	public function vignette(strength:Int = 3, onlySetAlpha = false) {
		for (x in 0...width) {
			for (y in 0...height) {
				var dist = Math.sqrt((width/2-x)*(width/2-x) + (height/2-y)*(height/2-y));

				var _:Float = Math.pow(clamp(dist / distanceToCorner), strength);
				var a:Int = Std.int(_ * 255);

				if (onlySetAlpha) {
					var p:UInt = getPixel32(x, y);
					var r = 0xff & p >> 16;
					var g = 0xff & p >> 8;
					var b = 0xff & p >> 0;
					var argb = (a << 24) + (r << 16) + (g << 8) + b;
					setPixel32(x, y, argb);
				} else {
					var argb = (0xff << 24) + (a << 16) + (a << 8) + a;
					setPixel32(x, y, argb);
				}
			}
		}
	}

	public function clear(color:UInt = 0x0) {
		fillRect(rect, color);
	}

	public function scanlines(fgColor = 0xfff0f0f0, bgColor = 0xff808080, interval = 3) {
		for (x in 0...width) {
			for (y in 0...height) {
				if (y % interval == interval - 1) {
					setPixel32(x, y, fgColor);
				} else {
					setPixel32(x, y, bgColor);
				}
			}
		}
	}

	public function new(width:Int = 300, height:Int = 200, ?transparent:Bool = false, ?fillColor:UInt = 0xffccccff) {
		super(width, height, transparent, fillColor);
		distanceToCorner = Math.sqrt((width/2)*(width/2) + (height/2)*(height/2));
	}
}