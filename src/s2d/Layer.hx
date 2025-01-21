package s2d;

import haxe.ds.Vector;
// s2d
import s2d.SpriteAtlas;
import s2d.objects.Light;
import s2d.objects.Sprite;
#if (S2D_LIGHTING_SHADOWS == 1)
import kha.math.FastVector2;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
// s2d
import s2d.graphics.lighting.ShadowCaster;
#end

using s2d.core.utils.extensions.VectorExt;

class Layer {
	public var lights:Vector<Light> = new Vector(0);
	public var sprites:Vector<Sprite> = new Vector(0);
	public var spriteAtlases:Vector<SpriteAtlas> = new Vector(0);

	public inline function new() {}

	public inline function addLight(light:Light) {
		lights = lights.push(light);
	}

	public inline function addSprite(sprite:Sprite) {
		sprites = sprites.push(sprite);
	}

	public inline function addSpriteAtlas(atlas:SpriteAtlas) {
		spriteAtlases = spriteAtlases.push(atlas);
	}

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowVertices:VertexBuffer;
	var shadowIndices:IndexBuffer;

	@:access(s2d.graphics.lighting.ShadowCaster)
	inline function adjustShadowBuffers(d:Int) {
		var vCount;
		if (shadowVertices != null)
			vCount = shadowVertices.count() + d;
		else
			vCount = d;

		shadowVertices = new VertexBuffer(vCount, ShadowCaster.structure, DynamicUsage);
		shadowIndices = new IndexBuffer((vCount - 2) * 3, StaticUsage);

		var ind = shadowIndices.lock();
		var b = 0;
		for (sprite in sprites) {
			for (i in 0...sprite.mesh.length) {
				var base = b + i * 4;
				// p1 -> e1 -> p2
				ind[b * 6 + i * 6] = base;
				ind[b * 6 + i * 6 + 1] = base + 2;
				ind[b * 6 + i * 6 + 2] = base + 1;
				// e1 -> e2 -> p2
				ind[b * 6 + i * 6 + 3] = base + 2;
				ind[b * 6 + i * 6 + 4] = base + 3;
				ind[b * 6 + i * 6 + 5] = base + 1;
			}
			b += sprite.mesh.length * 4;
		}
		shadowIndices.unlock();
	}

	@:access(s2d.objects.Sprite)
	inline function castShadows(light:Light):Void {
		final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});

		final vert = shadowVertices.lock();
		var i = 0;
		for (sprite in sprites) {
			final model = sprite._model;
			for (edge in sprite.mesh) {
				var p1:FastVector2 = model.multvec({x: edge.x, y: edge.y});
				var p2:FastVector2 = model.multvec({x: edge.z, y: edge.w});
				var e1 = p1.add(p1.sub(lightPos).mult(light.radius * light.power));
				var e2 = p2.add(p2.sub(lightPos).mult(light.radius * light.power));

				vert[i + 0] = p1.x;
				vert[i + 1] = p1.y;
				vert[i + 2] = e1.x;
				vert[i + 3] = e1.y;
				vert[i + 4] = p2.x;
				vert[i + 5] = p2.y;
				vert[i + 6] = e2.x;
				vert[i + 7] = e2.y;

				i += 4 * 2;
			}
		}
		shadowVertices.unlock();
	}
	#end
}
