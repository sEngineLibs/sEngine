package s2d.graphics;

import kha.Image;
import haxe.ds.Vector;

abstract PingPongBuffer(Vector<Image>) {
	public static var length = 2;

	public var src(get, never):Image;
	public var tgt(get, never):Image;

	public inline function new(width:Int, heigth:Int) {
		this = new Vector(length);
		resize(width, heigth);
	}

	public inline function resize(width:Int, heigth:Int) {
		for (i in 0...length) {
			this[i] = Image.createRenderTarget(width, heigth);
		}
	}

	public inline function swap() {
		final k = this[0];
		this[0] = this[1];
		this[1] = k;
	}

	inline function get_src():Image {
		return this[0];
	}

	inline function get_tgt():Image {
		return this[1];
	}
}
