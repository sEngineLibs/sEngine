package s2d;

import kha.arrays.Float32Array;
// s2d
import s2d.core.Buffer;
import s2d.SpriteAtlas;
import s2d.objects.Light;
import s2d.objects.Sprite;

@:access(s2d.objects.Object)
class Layer {
	public var lights:Buffer<Light> = [];
	public var sprites:Buffer<Sprite> = [];
	public var spriteAtlases:Buffer<SpriteAtlas> = [];

	public inline function new() {}

	public inline function addLight(light:Light) {
		lights += light;
	}

	public inline function addSprite(sprite:Sprite) {
		sprites += sprite;
	}

	public inline function addSpriteAtlas(atlas:SpriteAtlas) {
		spriteAtlases += atlas;
	}
}
