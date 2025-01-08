package s2d.graphics;

import kha.Image;

abstract PingPongBuffer(Array<Image>) {
	public inline function new(width:Int, height:Int) {
		this = [Image.createRenderTarget(width, height), Image.createRenderTarget(width, height)];
	}

	public var src(get, set):Image;
	public var tgt(get, set):Image;

	inline function get_src():Image {
		return this[0];
	}

	inline function set_src(value:Image):Image {
		this[0] = value;
		return value;
	}

	inline function get_tgt():Image {
		return this[1];
	}

	inline function set_tgt(value:Image):Image {
		this[1] = value;
		return value;
	}

	public inline function swap():Void {
		var tmp = this[0];
		this[0] = this[1];
		this[1] = tmp;
	}
}
