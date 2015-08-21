import flash.geom.*;
import flash.display.*;
import b.*;

@:bitmap("0001.png") class Guy1 extends BitmapData {}
@:bitmap("0002.png") class Guy2 extends BitmapData {}
@:bitmap("0003.png") class Guy3 extends BitmapData {}
@:bitmap("0004.png") class Guy4 extends BitmapData {}
@:bitmap("0005.png") class Guy5 extends BitmapData {}
@:bitmap("0006.png") class Guy6 extends BitmapData {}
@:bitmap("0007.png") class Guy7 extends BitmapData {}
@:bitmap("0008.png") class Guy8 extends BitmapData {}
@:bitmap("starry.png") class Starry extends BitmapData {}

class Main extends Game {

	var guy:Blob;
	var sheet:BitmapData = new BitmapData(64*8, 64, true, 0);
	var vignette:Buffer;
	var starry = new Starry(0, 0);
	var tp:Buffer = new Buffer(320, 200, true);

	override function refresh() {
		var t = Date.now().getTime();
		b.draw(starry);
		b.edgeBlur();
//		b.copyPixels(sheet, sheet.rect, new Point(0, 0));
		guy.draw(b);
		guy.tick();
		return;

//		tp.plasma(t);

//		var m = new Matrix(1, 0, 0, 1, Math.cos(t*0.01) * 1.5, Math.sin(t*0.012) * 1.5);
		tp.draw(starry);
		tp.applyFilter(tp , tp.rect, new Point(0,0), new flash.filters.BlurFilter());

//		tp.clear(0xffffffff);
		tp.vignette(1, true);

		//b.copyChannel(sourceBitmapData:flash.display.BitmapData, sourceRect:flash.geom.Rectangle, destPoint:flash.geom.Point, sourceChannel:UInt, destChannel:UInt
		b.draw(starry);
		b.draw(tp);
//		b.draw(testPattern, new Matrix(1, 0, 0, 0.9, 0, 0));
//		b.draw(starry);
//		b.draw(source:flash.display.IBitmapDrawable, ?matrix:flash.geom.Matrix, ?colorTransform:flash.geom.ColorTransform, ?blendMode:flash.display.BlendMode, ?clipRect:flash.geom.Rectangle, ?smoothing:Bool


//		tp.draw(testPattern);

//		b.draw(tp);

//		b.plasma(t);
//		b.draw(vignette, null, null, flash.display.BlendMode.LAYER);
//		b.edgeBlur();
	}

	override function new() {
		super();
		consoleMatrix.translate(0, b.height - 40);
		sheet.copyPixels(new Guy1(0, 0), sheet.rect, new Point(64 * 0, 0));
		sheet.copyPixels(new Guy2(0, 0), sheet.rect, new Point(64 * 1, 0));
		sheet.copyPixels(new Guy3(0, 0), sheet.rect, new Point(64 * 2, 0));
		sheet.copyPixels(new Guy4(0, 0), sheet.rect, new Point(64 * 3, 0));
		sheet.copyPixels(new Guy5(0, 0), sheet.rect, new Point(64 * 4, 0));
		sheet.copyPixels(new Guy6(0, 0), sheet.rect, new Point(64 * 5, 0));
		sheet.copyPixels(new Guy7(0, 0), sheet.rect, new Point(64 * 6, 0));
		sheet.copyPixels(new Guy8(0, 0), sheet.rect, new Point(64 * 7, 0));
		Blob.setSheet(sheet);
		Blob.defineAnimation("rot", 0, 0, 8, 5);
		guy = new Blob();
		guy.anim("rot");

//		vignette = new Buffer(b.width, b.height, true);
//		vignette.vignette(7);
//		consoleVisible = false;
	}

	static function main() {
		new Main();
	}
}