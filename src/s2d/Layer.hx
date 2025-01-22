package s2d;

import kha.math.FastVector2;
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
import s2d.graphics.lighting.ShadowDrawer;
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
		@:privateAccess sprite.index = sprites.length;
		sprites = sprites.push(sprite);
	}

	public inline function addSpriteAtlas(atlas:SpriteAtlas) {
		spriteAtlases = spriteAtlases.push(atlas);
	}

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowVertices:VertexBuffer;
	var shadowIndices:IndexBuffer;
	var shadowMaps:Vector<Image>;

	inline function resizeShadowMaps(width:Int, height:Int) {
		shadowMaps = new Vector(shadowMaps.length, Image.createRenderTarget(width, height, L8));
		drawLayerShadows();
	}

	@:access(s2d.objects.Light)
	inline function adjustShadowMaps(light:Light) {
		var i = 0;
		for (light in lights) {
			if (light.isMappingShadows) {
				light.shadowMapID = i;
				++i;
			}
		}
		shadowMaps = new Vector(i, Image.createRenderTarget(S2D.width, S2D.width, L8));
		drawLightShadows(light);
	}

	@:access(s2d.objects.Sprite)
	@:access(s2d.graphics.lighting.ShadowDrawer)
	inline function adjustShadowBuffers(d:Int) {
		var vCount = d;
		if (shadowVertices != null)
			vCount += shadowVertices.count();

		shadowVertices = new VertexBuffer(vCount, ShadowDrawer.structure, DynamicUsage);
		shadowIndices = new IndexBuffer((vCount - 2) * 3, StaticUsage);
		final ind = shadowIndices.lock();
		var e = 0;
		for (sprite in sprites) {
			for (_ in sprite.mesh) {
				// each edge produces 2 triangles
				final i = e * 6; // 6 indices
				final v = e * 4; // 4 vertices
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
	inline function mapShadows(light:Light):Void {
		final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});
		final distance = light.radius * light.power;

		final vert = shadowVertices.lock();
		var offset = 0;
		for (sprite in sprites) {
			if (sprite.isCastingShadows) {
				final mvp = S2D.stage.viewProjection.multmat(sprite.finalModel);
				final normalMatrix = sprite.finalModel.inverse().transpose();
				for (edge in sprite.mesh) {
					var v1 = mvp.multvec(edge.v1);
					var v2 = mvp.multvec(edge.v2);
					var l:FastVector2 = { // light direction
						x: lightPos.x - (v1.x + v2.x) / 2,
						y: lightPos.y - (v1.y + v2.y) / 2
					};
					var normalTransformed = normalMatrix.multvec(edge.normal).normalized();
					if (l.dot(normalTransformed) < 0) {
						var e1 = v1.add(v1.sub(lightPos).mult(distance));
						var e2 = v2.add(v2.sub(lightPos).mult(distance));

						vert[offset + 0] = v1.x;
						vert[offset + 1] = v1.y;
						vert[offset + 2] = sprite.finalZ;
						vert[offset + 3] = sprite.shadowOpacity;

						vert[offset + 4] = v2.x;
						vert[offset + 5] = v2.y;
						vert[offset + 6] = sprite.finalZ;
						vert[offset + 7] = sprite.shadowOpacity;

						vert[offset + 8] = e1.x;
						vert[offset + 9] = e1.y;
						vert[offset + 10] = sprite.finalZ;
						vert[offset + 11] = 0.0;

						vert[offset + 12] = e2.x;
						vert[offset + 13] = e2.y;
						vert[offset + 14] = sprite.finalZ;
						vert[offset + 15] = 0.0;
					} else {
						vert[offset + 0] = 0.0;
						vert[offset + 1] = 0.0;
						vert[offset + 2] = 0.0;
						vert[offset + 3] = 0.0;

						vert[offset + 4] = 0.0;
						vert[offset + 5] = 0.0;
						vert[offset + 6] = 0.0;
						vert[offset + 7] = 0.0;

						vert[offset + 8] = 0.0;
						vert[offset + 9] = 0.0;
						vert[offset + 10] = 0.0;
						vert[offset + 11] = 0.0;

						vert[offset + 12] = 0.0;
						vert[offset + 13] = 0.0;
						vert[offset + 14] = 0.0;
						vert[offset + 15] = 0.0;
					}
					offset += 4 * 4;
				}
			}
		}
		shadowVertices.unlock();
	}

	inline function drawLightShadows(light:Light) {
		this.mapShadows(light);
		@:privateAccess ShadowDrawer.render(this.shadowMaps[light.shadowMapID], this);
	}

	inline function drawLayerShadows() {
		for (light in lights)
			if (light.isMappingShadows)
				drawLightShadows(light);
	}
	#end
}
