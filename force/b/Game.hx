package b;

import flash.display.*;
import flash.filters.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.ui.*;
import flash.media.*;

class Game {
	var w = 256;
	var h = 256;
	var scale = 2;

	var b:Buffer = null;
	var display:Buffer = null;
	var overlay:Buffer = null;
	var consoleBuffer:Buffer = null;
	var console = null;
	var m = new Matrix();
	var consoleMatrix = new Matrix(1, 0, 0, 1, 11, 181);

	var frame:Int = 0;
	var t:Float;
	public var consoleVisible = true;

	public function enterFrame(e:flash.events.Event) {
		frame++;
		t = Date.now().getTime();

		refresh();

		consoleBuffer.clear(0x00000000);

		if (consoleVisible) {
			console.draw(consoleBuffer, consoleMatrix);
			b.draw(consoleBuffer);
		}

		display.draw(b, m, null, null);
		display.draw(overlay, null, null, OVERLAY);
	}

	public function refresh() {
		// Override me in subclass
	}

	public function new() {
		display = new Buffer(w * scale, h * scale); 
		consoleBuffer = new Buffer(w, h, true); 
		flash.Lib.current.addChild(new Bitmap(display));

		overlay = new Buffer(w * scale, h * scale);
		overlay.scanlines(0xffbfbfbf);

		m.scale(scale, scale);

		b = new Buffer(w, h);
		flash.Lib.current.stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		console = new Console(w - 20, h - 100);
	}
}