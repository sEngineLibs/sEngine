package s2d;

import kha.FastFloat;
import haxe.ds.Vector;
// s2d
import s2d.SpriteAtlas;
import s2d.objects.Light;
import s2d.objects.Sprite;
#if (S2D_LIGHTING_SHADOWS == 1)
import kha.Image;
import kha.math.FastVector2;
import kha.arrays.Float32Array;
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

	public function new() {}

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

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowVertices:VertexBuffer;
	var shadowVerticesData:Float32Array;
	var shadowIndices:IndexBuffer;
	var shadowMaps:Vector<Image>;

	function resizeShadowMaps(width:Int, height:Int) {
		shadowMaps = new Vector(shadowMaps.length, Image.createRenderTarget(width, height, L8));
		drawLayerShadows();
	}

	@:access(s2d.objects.Light)
	function adjustShadowMaps(light:Light) {
		var i = 0;
		for (light in lights) {
			if (light.isMappingShadows) {
				light.shadowMapIndex = i;
				++i;
			}
		}
		shadowMaps = new Vector(i, Image.createRenderTarget(S2D.width, S2D.width, L8));
		drawLightShadows(light);
	}

	@:access(s2d.objects.Sprite)
	function adjustShadowBuffers() {
		var vertCount = 0;
		for (sprite in sprites) {
			if (sprite.isCastingShadows) {
				sprite.shadowBufferOffset = vertCount;
				for (_ in sprite.mesh)
					vertCount += 4;
			}
		}
		if (shadowVertices != null && shadowIndices != null) {
			shadowVertices.delete();
			shadowIndices.delete();
		}
		if (vertCount > 4) {
			shadowVertices = @:privateAccess new VertexBuffer(vertCount, ShadowDrawer.structure, DynamicUsage);
			shadowIndices = new IndexBuffer((vertCount - 2) * 3, StaticUsage);
			final ind = shadowIndices.lock();
			var e = 0;
			for (sprite in sprites) {
				if (sprite.isCastingShadows) {
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
			}
			shadowIndices.unlock();
		} else {
			shadowVertices = null;
			shadowIndices = null;
		}
	}

	function lockShadowBuffers() {
		if (shadowVertices != null)
			shadowVerticesData = shadowVertices.lock();
	}

	function unlockShadowBuffers() {
		if (shadowVertices != null)
			shadowVertices.unlock();
	}

	@:access(s2d.objects.Sprite)
	function mapSpriteShadows(sprite:Sprite, lightPos:FastVector2, distance:FastFloat) {
		final structSize = @:privateAccess ShadowDrawer.structure.byteSize() >> 2;
		final mvp = S2D.stage.viewProjection.multmat(sprite.finalModel);
		final normalModel = sprite.finalModel.inverse().transpose();

		var offset = sprite.shadowBufferOffset;
		for (edge in sprite.mesh) {
			var v1 = mvp.multvec(edge.v1);
			var v2 = mvp.multvec(edge.v2);
			var lightDir:FastVector2 = {
				x: lightPos.x - (v1.x + v2.x) / 2,
				y: lightPos.y - (v1.y + v2.y) / 2
			};
			var normal = normalModel.multvec(edge.normal).normalized();
			if (lightDir.dot(normal) < 0) {
				var e1 = v1.add(v1.sub(lightPos).mult(distance));
				var e2 = v2.add(v2.sub(lightPos).mult(distance));
				for (v in [v1, v2, e1, e2]) {
					shadowVerticesData[offset + 0] = v.x;
					shadowVerticesData[offset + 1] = v.y;
					offset += structSize;
				}
			} else {
				for (i in 0...4) {
					shadowVerticesData[offset + 0] = 0.0;
					shadowVerticesData[offset + 1] = 0.0;
					offset += structSize;
				}
			}
		}
	}

	function mapShadows(light:Light):Void {
		if (shadowVerticesData != null) {
			final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});
			final distance = light.radius * light.power;
			for (sprite in sprites)
				if (sprite.isCastingShadows)
					mapSpriteShadows(sprite, lightPos, distance);
		}
	}

	@:access(s2d.objects.Light)
	function drawLightShadows(light:Light) {
		mapShadows(light);
		ShadowDrawer.render(shadowMaps[light.shadowMapIndex], this);
	}

	function drawLayerShadows() {
		for (light in lights)
			if (light.isMappingShadows)
				drawLightShadows(light);
	}
	#end
}
