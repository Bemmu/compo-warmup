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
	public function ball(x:Float, y:Float, radius:Float, color:UInt) {
		var s = new Shape();
		s.graphics.beginFill(color);
		s.graphics.drawCircle(x, y, radius);
		s.graphics.endFill();
		var quality = flash.display.StageQuality.BEST;
		drawWithQuality(s, null, null, null, null, false, quality);		
	}

	public function edgeRect() {

		//   #############
		//  #             #
		//  #             #
		//  #             #
		//   #############
	}

	public function clear(color:UInt = 0x0) {
		fillRect(rect, color);
	}
}