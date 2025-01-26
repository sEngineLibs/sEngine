package s2d;

import haxe.ds.Vector;
// s2d
import s2d.SpriteAtlas;
import s2d.objects.Light;
import s2d.objects.Sprite;
#if (S2D_LIGHTING_SHADOWS == 1)
import s2d.graphics.ShadowBuffer;
#end

using s2d.core.extensions.VectorExt;

class Layer {
	public var lights:Vector<Light> = new Vector(0);
	public var sprites:Vector<Sprite> = new Vector(0);
	public var spriteAtlases:Vector<SpriteAtlas> = new Vector(0);

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffer:ShadowBuffer;
	#end

	public function new() {
		#if (S2D_LIGHTING_SHADOWS == 1)
		shadowBuffer = new ShadowBuffer();
		#end
	}

	public function addLight(light:Light) {
		lights = lights.push(light);
	}

	public function addSprite(sprite:Sprite) {
		@:privateAccess sprite.index = sprites.length;
		sprites = sprites.push(sprite);
	}

	public function addSpriteAtlas(atlas:SpriteAtlas) {
		spriteAtlases = spriteAtlases.push(atlas);
	}
}
