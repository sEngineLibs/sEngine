package s2d.graphics;

import kha.Image;
import haxe.ds.Vector;

abstract GBuffer(Vector<Image>) {
	public static var length = 4;

	public var albedoMap(get, never):Image;
	public var normalMap(get, never):Image;
	public var emissionMap(get, never):Image;
	public var ormMap(get, never):Image;

	public inline function new(width:Int, heigth:Int) {
		this = new Vector(length);
		resize(width, heigth);
	}

	public inline function resize(width:Int, heigth:Int) {
		for (i in 0...length)
			this[i] = Image.createRenderTarget(width, heigth, RGBA32, DepthOnly);
	}

	inline function get_albedoMap():Image {
		return this[0];
	}

	inline function get_normalMap():Image {
		return this[1];
	}

	inline function get_emissionMap():Image {
		return this[2];
	}

	inline function get_ormMap():Image {
		return this[3];
	}
}
