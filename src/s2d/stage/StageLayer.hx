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
	var sprites:Array<Sprite> = [];
	var materials:Array<SpriteMaterial> = [];

	public function new() {
		#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
		shadowBuffer = new ShadowBuffer();
		#end
	}

	public function addSprite(sprite:Sprite) {
		if (!sprites.contains(sprite)) {
			sprites.push(sprite);
			if (!materials.contains(sprite.material))
				materials.push(sprite.material);
		}
	}

	public function removeSprite(sprite:Sprite) {
		sprites.remove(sprite);
		for (s in sprites)
			if (s.material == sprite.material)
				return;
		materials.remove(sprite.material);
	}

	#if (S2D_LIGHTING == 1)
	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffer:ShadowBuffer;
	#end

	public var lights:Array<Light> = [];

	public function addLight(light:Light) {
		if (!lights.contains(light))
			lights.push(light);
	}

	public function removeLight(light:Light) {
		lights.remove(light);
	}
	#end
}
