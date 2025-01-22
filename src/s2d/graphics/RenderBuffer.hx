package s2d.graphics;

import kha.Image;
import haxe.ds.Vector;

class RenderBuffer {
	var buffer:Vector<Image>;

	// ping-pong
	var srcInd:Int = 0;
	var tgtInd:Int = 1;

	public var src(get, never):Image;
	public var tgt(get, never):Image;

	public var depthMap(get, never):Image;

	#if (S2D_LIGHTING_DEFERRED == 1)
	static inline final length = 7;

	public var albedoMap(get, never):Image;
	public var normalMap(get, never):Image;
	public var emissionMap(get, never):Image;
	public var ormMap(get, never):Image;

	inline function get_albedoMap():Image {
		return buffer[2];
	}

	inline function get_normalMap():Image {
		return buffer[3];
	}

	inline function get_emissionMap():Image {
		return buffer[4];
	}

	inline function get_ormMap():Image {
		return buffer[5];
	}

	inline function get_depthMap():Image {
		return buffer[6];
	}
	#else
	static inline final length = 3;

	inline function get_depthMap():Image {
		return buffer[2];
	}
	#end

	public inline function new(width:Int, heigth:Int) {
		buffer = new Vector(length);
		resize(width, heigth);
	}

	public inline function resize(width:Int, heigth:Int) {
		// ping-pong
		for (i in 0...2)
			buffer[i] = Image.createRenderTarget(width, heigth, RGBA32);
		// gbuffer
		for (i in 2...length - 1)
			buffer[i] = Image.createRenderTarget(width, heigth, RGBA32);
		// depth map
		buffer[length - 1] = Image.createRenderTarget(width, heigth, L8, DepthOnly);
	}

	public inline function swap() {
		srcInd = 1 - srcInd;
		tgtInd = 1 - tgtInd;
	}

	inline function get_src():Image {
		return buffer[srcInd];
	}

	inline function get_tgt():Image {
		return buffer[tgtInd];
	}
}
