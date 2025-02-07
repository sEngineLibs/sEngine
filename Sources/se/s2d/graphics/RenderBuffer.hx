package se.s2d.graphics;

import haxe.ds.Vector;
import kha.Image;

class RenderBuffer {
	// ping-pong
	var srcInd:Int = 0;
	var tgtInd:Int = 1;

	public var buffer:Vector<Image>;

	public var src(get, never):Image;
	public var tgt(get, never):Image;

	public var depthMap:Image;

	#if (S2D_LIGHTING == 1)
	#if (S2D_LIGHTING_DEFERRED == 1)
	public var albedoMap:Image;
	public var normalMap:Image;
	public var emissionMap:Image;
	public var ormMap:Image;
	#end

	#if (S2D_LIGHTING_SHADOWS == 1)
	public var shadowMap:Image;
	#end
	#end
	public function new(width:Int, heigth:Int) {
		buffer = new Vector(2);
		resize(width, heigth);
	}

	public function resize(width:Int, heigth:Int) {
		// ping-pong
		buffer[0] = Image.createRenderTarget(width, heigth, RGBA128);
		buffer[1] = Image.createRenderTarget(width, heigth, RGBA128);
		#if (S2D_LIGHTING == 1)
		#if (S2D_LIGHTING_DEFERRED == 1)
		// gbuffer
		albedoMap = Image.createRenderTarget(width, heigth, RGBA32);
		normalMap = Image.createRenderTarget(width, heigth, RGBA32);
		emissionMap = Image.createRenderTarget(width, heigth, RGBA32);
		ormMap = Image.createRenderTarget(width, heigth, RGBA32);
		#end
		#if (S2D_LIGHTING_SHADOWS == 1)
		shadowMap = Image.createRenderTarget(width, heigth, L8);
		#end
		#end
		// depth map
		depthMap = Image.createRenderTarget(width, heigth, A32, DepthOnly);
	}

	public function swap() {
		srcInd = 1 - srcInd;
		tgtInd = 1 - tgtInd;
	}

	function get_src():Image {
		return buffer[srcInd];
	}

	function get_tgt():Image {
		return buffer[tgtInd];
	}
}
