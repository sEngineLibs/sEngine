package s2d;

import kha.FastFloat;
import kha.math.FastMatrix3;
import haxe.ds.Vector;
import kha.Image;
import kha.math.FastVector2;
import kha.arrays.Float32Array;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
// s2d
import s2d.Layer;
import s2d.objects.Light;
import s2d.objects.Sprite;
import s2d.graphics.lighting.ShadowPass;

class ShadowBuffers {
	var layer:Layer;
	var indices:IndexBuffer;
	var buffers:Vector<LightShadowBuffer>;

	function new(layer) {
		this.layer = layer;
		buffers = new Vector(0);
	}

	function resize(width:Int, height:Int) {
		for (buffer in buffers)
			buffer.resize(width, height);
	}

	function addLightShadowBuffer(light:Light) {
		var _buffers = new Vector(buffers.length + 1);
		var count = 0;
		for (_ in buffers)
			_buffers[count] = buffers[count];
		_buffers[buffers.length] = new LightShadowBuffer(light);
		buffers = _buffers;
	}

	function removeLightShadowBuffer(value:LightShadowBuffer) {
		value.free();
		var _buffers = new Vector(buffers.length - 1);
		var _count = 0;
		var count = 0;
		for (_ in buffers) {
			if (count != value.index) {
				_buffers[_count] = buffers[count];
				++_count;
			}
			++count;
		}
		buffers = _buffers;
	}

	@:access(s2d.objects.Sprite)
	function adjust() {
		var vertCount = 0;
		for (sprite in layer.sprites) {
			if (sprite.isCastingShadows) {
				sprite.shadowBufferOffset = vertCount;
				for (_ in sprite.mesh)
					vertCount += 4;
			}
		}
		if (vertCount > 4) {
			indices = new IndexBuffer((vertCount - 2) * 3, StaticUsage);
			final ind = indices.lock();
			var e = 0;
			for (sprite in layer.sprites) {
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
			};
			indices.unlock();
			for (buffer in buffers)
				buffer.adjust(vertCount);
		}
	}

	@:access(s2d.objects.Sprite)
	function updateSprite(sprite:Sprite) {
		for (buffer in buffers)
			buffer.updateSprite(sprite);
	}

	function lock() {
		for (buffer in buffers)
			buffer.lock();
	}

	function unlock() {
		for (buffer in buffers)
			buffer.unlock();
	}
}

@:allow(s2d.ShadowBuffers)
class LightShadowBuffer {
	var index:UInt;
	var light:Light;

	var map:Image;
	var vertices:VertexBuffer;
	var vertexData:Float32Array;

	@:access(s2d.objects.Light)
	function new(light:Light) {
		this.light = light;
		light.shadowBuffer = this;
	}

	function lock() {
		vertexData = vertices.lock();
	}

	function unlock() {
		vertices.unlock();
	}

	function free() {
		map.unload();
		vertices.delete();
	}

	function resize(width:Int, height:Int) {
		var img = Image.createRenderTarget(width, height, L8);
		img.g2.begin();
		img.g2.drawScaledImage(map, 0, 0, width, height);
		img.g2.end();
		map.unload();
		map = img;
	}

	@:access(s2d.graphics.lighting.ShadowPass)
	function adjust(vertexCount:Int) {
		if (vertices != null)
			if (vertices.count() == vertexCount)
				return;
			else
				vertices.delete();
		vertices = new VertexBuffer(vertexCount, ShadowPass.structure, DynamicUsage);
	}

	@:access(s2d.objects.Sprite)
	function mapSpriteShadows(sprite:Sprite, lightPos:FastVector2, lightDis:FastFloat) {
		final structSize = @:privateAccess ShadowPass.structure.byteSize() >> 2;
		final mvp = S2D.stage.viewProjection.multmat(sprite.finalModel);
		final nmodel = sprite.finalModel.inverse().transpose();

		var offset = sprite.shadowBufferOffset;
		for (edge in sprite.mesh) {
			var v1 = mvp.multvec(edge.v1);
			var v2 = mvp.multvec(edge.v2);
			var lightDir:FastVector2 = {
				x: lightPos.x - (v1.x + v2.x) / 2,
				y: lightPos.y - (v1.y + v2.y) / 2
			};
			var normal = nmodel.multvec(edge.normal).normalized();
			if (lightDir.dot(normal) < 0) {
				var e1 = v1.add(v1.sub(lightPos).mult(lightDis));
				var e2 = v2.add(v2.sub(lightPos).mult(lightDis));
				for (v in [v1, v2, e1, e2]) {
					vertexData[offset + 0] = v.x;
					vertexData[offset + 1] = v.y;
					offset += structSize;
				}
			} else {
				for (i in 0...4) {
					vertexData[offset + 0] = 0.0;
					vertexData[offset + 1] = 0.0;
					offset += structSize;
				}
			}
		}
	}

	@:access(s2d.objects.Sprite)
	function updateSprite(sprite:Sprite) {
		final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});
		final lightDis = light.radius * light.power;
		mapSpriteShadows(sprite, lightPos, lightDis);
	}

	function updateLight() {
		final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});
		final lightDis = light.radius * light.power;
		for (sprite in light.layer.sprites)
			mapSpriteShadows(sprite, lightPos, lightDis);
	}
}
