package se;

import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import se.graphics.Context1D;
import se.graphics.Context2D;
import se.graphics.Context3D;

@:forward(unload, width, height)
extern abstract Texture(Image) from Image to Image {
	var self(get, never):kha.Image;

	public var context1D(get, never):Context1D;
	public var context2D(get, never):Context2D;
	public var context3D(get, never):Context3D;

	public inline function new(width:Int, height:Int, ?format:TextureFormat, ?depthStencil:DepthStencilFormat, aaSamples:Int = 1) {
		this = kha.Image.createRenderTarget(width, height, format, depthStencil, aaSamples);
	}

	public inline function generateMipmaps(levels:Int = 1) {
		self.generateMipmaps(levels);
	}

	public inline function setDepthStencilFrom(image:Image) {
		self.setDepthStencilFrom(image);
	}

	@:to
	private inline function get_self():kha.Image {
		return this;
	}

	private inline function get_context1D():Context1D {
		return self.g1;
	}

	private inline function get_context2D():Context2D {
		return self.g2;
	}

	private inline function get_context3D():Context3D {
		return self.g4;
	}
}
