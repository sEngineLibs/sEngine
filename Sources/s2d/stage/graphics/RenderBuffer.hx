package s2d.stage.graphics;

import haxe.ds.Vector;
import se.Texture;

class RenderBuffer {
	// ping-pong
	var srcInd:Int = 0;
	var tgtInd:Int = 1;

	public var buffer:Vector<Texture>;

	public var src(get, never):Texture;
	public var tgt(get, never):Texture;

	public var depthMap:Texture;

	#if (S2D_LIGHTING == 1)
	#if (S2D_LIGHTING_DEFERRED == 1)
	public var albedoMap:Texture;
	public var normalMap:Texture;
	public var emissionMap:Texture;
	public var ormMap:Texture;
	#end

	#if (S2D_LIGHTING_SHADOWS == 1)
	public var shadowMap:Texture;
	#end
	#end
	public function new(width:Int, heigth:Int) {
		buffer = new Vector(2);
		resize(width, heigth);
	}

	public function resize(width:Int, heigth:Int) {
		// ping-pong
		buffer[0] = new Texture(width, heigth, RGBA128);
		buffer[1] = new Texture(width, heigth, RGBA128);
		#if (S2D_LIGHTING == 1)
		#if (S2D_LIGHTING_DEFERRED == 1)
		// gbuffer
		albedoMap = new Texture(width, heigth, RGBA32);
		normalMap = new Texture(width, heigth, RGBA32);
		emissionMap = new Texture(width, heigth, RGBA32);
		ormMap = new Texture(width, heigth, RGBA32);
		#end
		#if (S2D_LIGHTING_SHADOWS == 1)
		shadowMap = new Texture(width, heigth, L8);
		#end
		#end
		// depth map
		depthMap = new Texture(width, heigth, A32, DepthOnly);
	}

	public function swap() {
		srcInd = 1 - srcInd;
		tgtInd = 1 - tgtInd;
	}

	inline function get_src():Texture {
		return buffer[srcInd];
	}

	inline function get_tgt():Texture {
		return buffer[tgtInd];
	}
}
