package s2d;

import kha.arrays.Float32Array;
// s2d
import s2d.SpriteAtlas;
import s2d.objects.Light;
import s2d.objects.Sprite;

@:access(s2d.objects.Object)
class Layer {
	public var lights:Array<Light> = [];
	public var sprites:Array<Sprite> = [];
	public var spriteAtlases:Array<SpriteAtlas> = [];

	static final maxLights:Int = 16;
	static final lightStructSize:Int = 8;

	public inline function new() {
		lightsData = new Float32Array(1 + maxLights * lightStructSize);
	}

	public inline function addLight(light:Light) {
		lights.push(light);
	}

	public inline function addSprite(sprite:Sprite) {
		sprites.push(sprite);
	}

	public inline function addSpriteAtlas(atlas:SpriteAtlas) {
		spriteAtlases.push(atlas);
	}

	@:isVar var lightsData(get, null):Float32Array;

	inline function get_lightsData():Float32Array {
		lightsData[0] = lights.length;

		for (i in 0...lights.length) {
			var ind = 1 + i * lightStructSize;
			var light = lights[i];

			lightsData[ind + 0] = light.x;
			lightsData[ind + 1] = light.y;
			lightsData[ind + 2] = light.z;
			lightsData[ind + 3] = light.color.R;
			lightsData[ind + 4] = light.color.G;
			lightsData[ind + 5] = light.color.B;
			lightsData[ind + 6] = light.power;
			lightsData[ind + 7] = light.radius;
		}
		return lightsData;
	}
}
