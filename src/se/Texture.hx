package se;

import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import se.graphics.Context1D;
import se.graphics.Context2D;
import se.graphics.Context3D;

@:forward()
extern abstract Texture(Image) from Image to Image {
	var self(get, never):kha.Image;

	public var ctx1D(get, never):Context1D;
	public var ctx2D(get, never):Context2D;
	public var ctx3D(get, never):Context3D;

	public inline function new(width:Int, height:Int, ?format:TextureFormat, ?depthStencil:DepthStencilFormat, ?aaSamples:Int) {
		this = kha.Image.createRenderTarget(width, height, format, depthStencil, aaSamples);
	}

	@:to
	private inline function get_self():kha.Image {
		return this;
	}

	private inline function get_ctx1D():Context1D {
		return self.g1;
	}

	private inline function get_ctx2D():Context2D {
		return self.g2;
	}

	private inline function get_ctx3D():Context3D {
		return self.g4;
	}
}
