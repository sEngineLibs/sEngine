package se.s2d;

import se.s2d.SpriteAtlas;
import se.s2d.objects.Sprite;
#if (S2D_LIGHTING == 1)
import se.s2d.objects.Light;
#if (S2D_LIGHTING_SHADOWS == 1)
import se.s2d.graphics.ShadowBuffer;
#end
#end

class Layer {
	var stage:Stage;

	public var sprites:Array<Sprite> = [];
	public var spriteAtlases:Array<SpriteAtlas> = [];

	public function new(?stage:Stage) {
		if (stage != null)
			this.stage = stage;
		else
			this.stage = Stage.current;
		this.stage.layers.push(this);
		#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
		shadowBuffer = new ShadowBuffer();
		#end
	}

	public function addSprite(sprite:Sprite) {
		@:privateAccess sprite._id = sprites.length;
		sprites.push(sprite);
	}

	public function addSpriteAtlas(atlas:SpriteAtlas) {
		spriteAtlases.push(atlas);
	}

	#if (S2D_LIGHTING == 1)
	public var lights:Array<Light> = [];

	public function addLight(light:Light) {
		lights.push(light);
	}

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffer:ShadowBuffer;
	#end
	#end
}
