package s2d;

import kha.Image;
// s2d
import s2d.objects.Sprite;
#if (S2D_SPRITE_INSTANCING == 1)
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
// s2d
import s2d.objects.Sprite;
import s2d.graphics.Renderer;
#end

@:access(s2d.graphics.Renderer)
class SpriteAtlas {
	@:isVar public var layer(default, set):Layer;
	public var sprites:Array<Sprite> = [];

	public var albedoMap:Image;
	public var normalMap:Image;
	public var ormMap:Image;
	public var emissionMap:Image;

	public inline function new(layer:Layer) {
		this.layer = layer;
		#if (S2D_SPRITE_INSTANCING == 1)
		init();
		#end
	}

	inline function set_layer(value:Layer) {
		value.addSpriteAtlas(this);
		layer = value;
		return value;
	}

	#if (S2D_SPRITE_INSTANCING == 1)
	var vertices:Array<VertexBuffer>;

	inline function init() {
		vertices = [
			S2D.vertices,
			// sprite crop rects
			new VertexBuffer(sprites.length, Renderer.structures[1], StaticUsage, 1),
			// sprite models
			new VertexBuffer(sprites.length, Renderer.structures[2], StaticUsage, 1)
		];
	}

	public inline function addSprite(sprite:Sprite) {
		sprites.push(sprite);
		vertices[1] = new VertexBuffer(sprites.length, Renderer.structures[1], StaticUsage, 1);
		vertices[2] = new VertexBuffer(sprites.length, Renderer.structures[2], StaticUsage, 1);
		update();
	}

	inline function update() {
		// copy crop rects
		var structSize = Renderer.structures[1].byteSize() >> 2;
		var vert = vertices[1].lock();
		for (i in 0...sprites.length) {
			final sprite = sprites[i];
			vert[i * structSize + 0] = sprite.cropRect.x;
			vert[i * structSize + 1] = sprite.cropRect.y;
			vert[i * structSize + 2] = sprite.cropRect.z;
			vert[i * structSize + 3] = sprite.cropRect.w;
		}
		vertices[1].unlock();
		// copy models
		structSize = Renderer.structures[2].byteSize() >> 2;
		vert = vertices[2].lock();
		for (i in 0...sprites.length) {
			final sprite = sprites[i];
			// model0
			vert[i * structSize + 0] = sprite.model._00;
			vert[i * structSize + 1] = sprite.model._01;
			vert[i * structSize + 2] = sprite.model._02;
			// model1
			vert[i * structSize + 3] = sprite.model._10;
			vert[i * structSize + 4] = sprite.model._11;
			vert[i * structSize + 5] = sprite.model._12;
			// model2
			vert[i * structSize + 6] = sprite.model._20;
			vert[i * structSize + 7] = sprite.model._21;
			vert[i * structSize + 8] = sprite.model._22;
		}
		vertices[2].unlock();
	}
	#end
}
