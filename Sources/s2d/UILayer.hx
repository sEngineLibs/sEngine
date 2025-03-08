package s2d;

import kha.graphics4.TextureFormat;
import se.App;
import se.Texture;
import s2d.geometry.RectI;
import s2d.geometry.SizeI;
import s2d.effects.ShaderEffect;

@:structInit
@:allow(s2d.Element)
class UILayer {
	var texture:Texture;

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
				texture = new Texture(textureSize.width, textureSize.height, format, NoDepthAndStencil, samples);
			else
				texture = new Texture(App.windows[0].width, App.windows[0].height, format, NoDepthAndStencil, samples);
		} else {
			texture.unload();
			texture = null;
		}
	}

	inline function set_enabled(value:Bool):Bool {
		enabled = value;
		updateTexture();
		return value;
	}

	inline function set_textureSize(value:SizeI):SizeI {
		textureSize = value;
		updateTexture();
		return value;
	}

	inline function set_format(value:TextureFormat):TextureFormat {
		format = value;
		updateTexture();
		return value;
	}

	inline function set_samples(value:UInt):UInt {
		samples = value;
		updateTexture();
		return value;
	}
}
