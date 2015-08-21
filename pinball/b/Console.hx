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

@:font("visitor1.ttf") class PixelFont extends Font { }

class Console {
	var b:Buffer;
	var gradient:Buffer;
	var txtBuffer:Buffer;

	var tf:TextField;
	var x:Int;
	var y:Int;
	public var width:Int;
	public var height:Int;
	var textColor:UInt = 0x2eab2e;
	var format:TextFormat;
	var fontName:String; // extracted from font file
	var textPositionMatrix:Matrix = new Matrix(1, 0, 0, 1, 3, 2);
	var prompt = ">";
	var txt = "";
	var deletableCounter = 0;
	var cursor = "X";
	var blinkSpeed = 0.5;

	var line:String = "";

	var rightCollisionMargin = 13;
	var bottomCollisionMargin = 10;

	function nextLine() {
		add("\n" + prompt);
		line = "";
	}

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		txt = prompt;

		b = new Buffer(width, height, true);
		gradient = new Buffer(width, height, false);
		txtBuffer = new Buffer(width, height, false);
		gradient.gradient(0, gradient.height, 0xffffff, 0x666666);		

		// Extract name from the font file
		Font.registerFont(PixelFont);
		var f = new PixelFont();
		fontName = f.fontName;

		format = new flash.text.TextFormat();
		format.font = fontName;
		format.color = textColor;
		format.size = 10;
		format.leading = -2;

		// This holds the displayed text, the shadow under it is shown
		// by rendering it twice in succession and altering color in between.
		tf = new TextField();
		tf.embedFonts = true;
		tf.multiline = true;
		tf.htmlText = txt;
		tf.defaultTextFormat = format;
		tf.mouseWheelEnabled = false;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.width = width * 2; // needs to be a bit bigger, why not play safe?
		tf.height = height * 2;

		// This doesn't quite work 100%. Turns out to be tricksy.
		flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent) {
			switch (e.keyCode) {
			case Keyboard.SHIFT:
				return;
			case Keyboard.COMMAND:
				return;
			case Keyboard.ALTERNATE:
				return;
			case Keyboard.CONTROL:
				return;
			case Keyboard.ENTER:
				nextLine();
//				deletableCounter = 0;
			case Keyboard.BACKSPACE:
				if (line.length > 0) {
					txt = txt.substr(0, txt.length - 1);
					//tf.htmlText = txt;
					line = line.substr(0, line.length - 1);
//					deletableCounter--;
				}
			default:
				var ch = String.fromCharCode(e.charCode);
//				if ("ABCDEFGHIJKLMNOPQRSTUVWXYZ. ".indexOf(ch) != -1) {
					line += ch;
//					deletableCounter++;
					add(ch);
//				}
			}
		});
	}

	public function add(s:String) {

		// Would this new text fit?
		tf.htmlText = txt + s;
		txtBuffer.clear();
		txtBuffer.draw(tf);
		var rect = txtBuffer.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);
		var tooWide:Bool = rect.width >= b.width - rightCollisionMargin;
		var tooHigh:Bool = rect.height >= b.height - bottomCollisionMargin;

		if (tooWide) {
			txt += "\n";
		}

		if (tooHigh) {
//
			txt = txt.substr(txt.indexOf("\n") + 1);
//			nextLine();

//			trace("yikes");
		}

		txt += s;
		tf.htmlText = txt;
	}

	public function draw(target:BitmapData, ?matrix:Matrix) {
		var t = Date.now().getTime();

		tf.htmlText = txt;
		if (Math.ceil(t*0.001/blinkSpeed)%2 == 0) {
			tf.htmlText = txt + "@";
		}

		if (matrix == null) {
			matrix = new Matrix();
		}
		b.edgeRect(0, 0, width, height);

		// Draw text shadow
		textPositionMatrix.translate(0, 1);
		format.color = 0x000000;
		tf.setTextFormat(format);
		b.draw(tf, textPositionMatrix);
		textPositionMatrix.translate(0, -1);

		// Draw text itself
		format.color = textColor;
		tf.setTextFormat(format);
		b.draw(tf, textPositionMatrix);

		b.draw(gradient, null, null, BlendMode.OVERLAY);
		b.bloom(4 + Math.sin(t * 0.0025) * 0.3);

		// Gradient & bloom will ruin the edges, fix
		b.puncture(0, 0, width, height);

		target.draw(b, matrix);
	}
}