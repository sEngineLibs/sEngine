package s2d.graphics;

import kha.Image;
import haxe.ds.Vector;

class RenderBuffer {
	static final length = 2;

	var buffer:Vector<Image>;

	// ping-pong
	var srcInd:Int = 0;
	var tgtInd:Int = 1;

	public var src(get, never):Image;
	public var tgt(get, never):Image;

	public inline function new(width:Int, heigth:Int) {
		buffer = new Vector(length);
		resize(width, heigth);
	}

	public inline function resize(width:Int, heigth:Int) {
		for (i in 0...length) {
			buffer[i] = Image.createRenderTarget(width, heigth);
		}
	}

	inline function get_src():Image {
		return buffer[srcInd];
	}

	inline function get_tgt():Image {
		return buffer[tgtInd];
	}

	public inline function swap() {
		srcInd = 1 - srcInd;
		tgtInd = 1 - tgtInd;
	}
}
