package s2d.stage;

import s2d.stage.SpriteMaterial;
import s2d.stage.objects.Sprite;
#if (S2D_LIGHTING == 1)
import s2d.stage.objects.Light;
#if (S2D_LIGHTING_SHADOWS == 1)
import s2d.graphics.stage.ShadowBuffer;
#end
#end
class StageLayer {
	var stage:Stage;

	public var sprites:Array<Sprite> = [];
	public var materials:Array<SpriteMaterial> = [];

	public function new() {
		#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
		shadowBuffer = new ShadowBuffer();
		#end
	}

	public function addSprite(sprite:Sprite) {
		sprite.layer = this;
	}

	public function removeSprite(sprite:Sprite) {
		sprite.layer = null;
	}

	#if (S2D_LIGHTING == 1)
	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffer:ShadowBuffer;
	#end

	public var lights:Array<Light> = [];

	public function addLight(light:Light) {
		light.layer = this;
	}

	public function removeLight(light:Light) {
		light.layer = null;
	}
	#end
}
