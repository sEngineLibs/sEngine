package s2d;

import haxe.ds.Vector;
// s2d
import s2d.SpriteAtlas;
import s2d.objects.Light;
import s2d.objects.Sprite;
#if (S2D_LIGHTING_SHADOWS == 1)
import kha.Image;
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

	@:isVar public var shadowMaps(default, null):Vector<Image> = new Vector(0);

	inline function adjustShadowMaps(d:Int) {
		shadowMaps = new Vector(shadowMaps.length + d);
		for (i in 0...shadowMaps.length)
			shadowMaps[i] = Image.createRenderTarget(S2D.width, S2D.height, RGBA32, DepthOnly);
	}

	@:access(s2d.graphics.lighting.ShadowCaster)
	inline function adjustShadowBuffers(d:Int) {
		var vCount = d;
		if (shadowVertices != null)
			vCount += shadowVertices.count();

		shadowVertices = new VertexBuffer(vCount, ShadowCaster.structure, DynamicUsage);
		shadowIndices = new IndexBuffer((vCount - 2) * 3, StaticUsage);
		final ind = shadowIndices.lock();
		var e = 0;
		for (sprite in sprites) {
			for (_ in sprite.mesh) {
				final i = e * 6;
				final v = e * 4;
				// p1 -> p2 -> e1
				ind[i + 0] = v + 0;
				ind[i + 1] = v + 1;
				ind[i + 2] = v + 2;
				// e1 -> e2 -> p2
				ind[i + 3] = v + 2;
				ind[i + 4] = v + 3;
				ind[i + 5] = v + 1;
				e++;
			}
		}
		shadowIndices.unlock();
	}

	@:access(s2d.objects.Sprite)
	inline function buildShadows(light:Light):Void {
		final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});
		final distance = light.radius * light.power;

		final vert = shadowVertices.lock();
		final length = sprites.length;
		var v = 0;
		var i = 0;
		for (sprite in sprites) {
			if (sprite.isCastingShadows) {
				final z = i / length;
				final mvp = S2D.stage.viewProjection.multmat(sprite.finalModel);
				for (edge in sprite.mesh) {
					var p1 = mvp.multvec({x: edge.x, y: edge.y});
					var p2 = mvp.multvec({x: edge.z, y: edge.w});
					var e1 = p1.add(p1.sub(lightPos).mult(distance));
					var e2 = p2.add(p2.sub(lightPos).mult(distance));

					vert[v + 0] = p1.x;
					vert[v + 1] = p1.y;
					vert[v + 2] = z;
					vert[v + 3] = sprite.shadowOpacity;

					vert[v + 4] = p2.x;
					vert[v + 5] = p2.y;
					vert[v + 6] = z;
					vert[v + 7] = sprite.shadowOpacity;

					vert[v + 8] = e1.x;
					vert[v + 9] = e1.y;
					vert[v + 10] = z;
					vert[v + 11] = 0.0;

					vert[v + 12] = e2.x;
					vert[v + 13] = e2.y;
					vert[v + 14] = z;
					vert[v + 15] = 0.0;

					v += 4 * 4;
				}
			}
			++i;
		}
		shadowVertices.unlock();
	}

	inline function drawShadows() {
		var i = 0;
		for (light in lights) {
			if (light.isCastingShadows) {
				buildShadows(light);
				ShadowCaster.render(shadowMaps[i], this);
				++i;
			}
		}
	}
	#end
}
