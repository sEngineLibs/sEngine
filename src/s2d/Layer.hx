package s2d;

import haxe.ds.Vector;
// s2d
import s2d.SpriteAtlas;
import s2d.objects.Sprite;
#if (S2D_LIGHTING == 1)
import s2d.objects.Light;
#if (S2D_LIGHTING_SHADOWS == 1)
import s2d.graphics.ShadowBuffer;
#end
#end
using s2d.core.extensions.VectorExt;

class Layer {
	@:isVar public var stage(default, set):Stage;
	public var sprites:Vector<Sprite> = new Vector(0);
	public var spriteAtlases:Vector<SpriteAtlas> = new Vector(0);

	public function new(stage:Stage) {
		stage.layers.push(this);
		#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
		shadowBuffer = new ShadowBuffer();
		#end
	}

	public function addSprite(sprite:Sprite) {
		@:privateAccess sprite.index = sprites.length;
		sprites = sprites.push(sprite);
	}

	public function addSpriteAtlas(atlas:SpriteAtlas) {
		spriteAtlases = spriteAtlases.push(atlas);
	}

	#if (S2D_LIGHTING == 1)
	public var lights:Vector<Light> = new Vector(0);

	public function addLight(light:Light) {
		lights = lights.push(light);
	}

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffer:ShadowBuffer;
	#end
	#end
	function set_stage(value:Stage) {
		if (stage != null && stage != value && !stage.layers.contains(this)) {
			stage = value;
			stage.layers.push(this);
		}
		return value;
	}
}
