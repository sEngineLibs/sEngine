package se;

import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import se.graphics.Context1D;
import se.graphics.Context2D;
import se.graphics.Context3D;

@:forward(width, height, format, unload)
extern abstract Texture(Image) from Image to Image {
	var self(get, never):kha.Image;

	public var context1D(get, never):Context1D;
	public var context2D(get, never):Context2D;
	public var context3D(get, never):Context3D;

	public inline function new(width:Int, height:Int, ?format:TextureFormat, ?depthStencil:DepthStencilFormat, ?aaSamples:Int) {
		this = kha.Image.createRenderTarget(width, height, format, depthStencil, aaSamples);
	}

	@:to
	inline function get_self():kha.Image {
		return this;
	}

	inline function get_context1D():Context1D {
		return self.g1;
	}

	inline function get_context2D():Context2D {
		return self.g2;
	}

	inline function get_context3D():Context3D {
		return self.g4;
	}
}
