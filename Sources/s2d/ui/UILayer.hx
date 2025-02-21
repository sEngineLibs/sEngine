package s2d.ui;

import kha.Image;
import kha.graphics4.TextureFormat;
import se.system.Application;
import s2d.geometry.RectI;
import s2d.geometry.SizeI;
import s2d.ui.effects.ShaderEffect;

@:structInit
@:allow(s2d.ui.UIElement)
class UILayer {
	var texture:Image;

	@:isVar public var enabled(default, set):Bool = false;
	@:isVar public var textureSize(default, set):SizeI = new SizeI(-1, -1);
	@:isVar public var format(default, set):TextureFormat = RGBA32;
	@:isVar public var samples(default, set):UInt = 1;

	public var effect:ShaderEffect;
	public var sourceRect:RectI;

	public function new() {}

	function updateTexture() {
		if (enabled) {
			if (textureSize.width > 0 && textureSize.height > 0)
				texture = Image.createRenderTarget(textureSize.width, textureSize.height, format, NoDepthAndStencil, samples);
			else
				texture = Image.createRenderTarget(Application.window.width, Application.window.height, format, NoDepthAndStencil, samples);
		} else {
			texture.unload();
			texture = null;
		}
	}

	function set_enabled(value:Bool):Bool {
		enabled = value;
		updateTexture();
		return value;
	}

	function set_textureSize(value:SizeI):SizeI {
		textureSize = value;
		updateTexture();
		return value;
	}

	function set_format(value:TextureFormat):TextureFormat {
		format = value;
		updateTexture();
		return value;
	}

	function set_samples(value:UInt):UInt {
		samples = value;
		updateTexture();
		return value;
	}
}
