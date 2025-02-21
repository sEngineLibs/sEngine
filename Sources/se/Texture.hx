package se;

import kha.graphics1.Graphics as G1;
import kha.graphics4.Graphics as G4;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import se.graphics.G2;

@:forward(width, height, format)
abstract Texture(Image) from Image to Image {
	public var g1(get, never):G1;
	public var g2(get, never):G2;
	public var g4(get, never):G4;

	public inline function new(width:Int, height:Int, ?format:TextureFormat, ?depthStencil:DepthStencilFormat, ?antiAliasingSamples:Int) {
		this = kha.Image.createRenderTarget(width, height, format, depthStencil, antiAliasingSamples);
	}

	inline function get_g1():G1 {
		return (this : kha.Image).g1;
	}

	inline function get_g2():G2 {
		return (this : kha.Image).g2;
	}

	inline function get_g4():G4 {
		return (this : kha.Image).g4;
	}
}
