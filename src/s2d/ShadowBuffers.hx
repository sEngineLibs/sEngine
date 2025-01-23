package s2d;

#if (S2D_LIGHTING_SHADOWS == 1)
import kha.FastFloat;
import haxe.ds.Vector;
import kha.Image;
import kha.math.FastVector2;
import kha.arrays.Float32Array;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
// s2d
import s2d.objects.Light;
import s2d.objects.Sprite;
import s2d.graphics.lighting.ShadowPass;

class ShadowBuffers {
	var indices:IndexBuffer;
	var buffers:Vector<LightShadowBuffer>;

	function new() {
		buffers = new Vector(0);
		indices = new IndexBuffer(0, StaticUsage);
	}

	function resize(width:Int, height:Int) {
		for (buffer in buffers)
			buffer.resize(width, height);
	}

	function addLight(light:Light) {
		var _buffers = new Vector(buffers.length + 1);
		var count = 0;
		for (_ in buffers) {
			_buffers[count] = buffers[count];
			++count;
		}
		_buffers[buffers.length] = new LightShadowBuffer(light);
		_buffers[buffers.length].updateLightShadows();
		buffers = _buffers;
	}

	@:access(s2d.objects.Light)
	function removeLight(light:Light) {
		light.shadowBuffer.free();
		var _buffers = new Vector(buffers.length - 1);
		var _count = 0;
		var count = 0;
		for (_ in buffers) {
			if (count != light.shadowBuffer.index) {
				_buffers[_count] = buffers[count];
				++_count;
			}
			++count;
		}
		buffers = _buffers;
	}

	function addSprite(sprite:Sprite) {
		for (buffer in buffers)
			buffer.addSprite(sprite);
		updateIndices();
	}

	function removeSprite(sprite:Sprite) {
		for (buffer in buffers)
			buffer.removeSprite(sprite);
		updateIndices();
	}

	function updateSpriteMesh(sprite:Sprite) {
		for (buffer in buffers)
			buffer.updateSpriteMesh(sprite);
		updateIndices();
	}

	@:access(s2d.objects.Sprite)
	function updateSpriteShadows(sprite:Sprite) {
		for (buffer in buffers)
			buffer.updateSpriteShadows(sprite);
	}

	function updateIndices() {
		if (buffers.length > 0) {
			final vertexCount = buffers[0].vertices.count();
			if (vertexCount < 4) {
				indices = new IndexBuffer(0, StaticUsage);
			} else {
				indices = new IndexBuffer((vertexCount - 1) * 6, StaticUsage);
				final ind = indices.lock();
				var quadCounter = 0;
				for (i in 0...(vertexCount - 1)) {
					final v = i * 4; // 4 vertices per quad
					final indexOffset = quadCounter * 6; // 6 indices per quad
					// p1 -> p2 -> e1
					ind[indexOffset + 0] = v + 0;
					ind[indexOffset + 1] = v + 1;
					ind[indexOffset + 2] = v + 2;
					// e1 -> e2 -> p2
					ind[indexOffset + 3] = v + 2;
					ind[indexOffset + 4] = v + 3;
					ind[indexOffset + 5] = v + 1;
					quadCounter++;
				}
			}
		} else {
			indices = new IndexBuffer(0, StaticUsage);
		}
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

		vertices = new VertexBuffer(0, @:privateAccess ShadowPass.structure, DynamicUsage);
		vertexData = new Float32Array(0);
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

	@:access(s2d.objects.Sprite)
	function addSprite(sprite:Sprite) {
		sprite.shadowBuffersOffset = vertices.count();
		var vertexCount = 0;
		for (_ in sprite.mesh)
			vertexCount += 4;
		sprite.shadowBuffersLength = vertexCount;

		vertices.delete();
		vertices = new VertexBuffer(vertices.count() + vertexCount, @:privateAccess ShadowPass.structure, DynamicUsage);
		var v = vertices.lock();
		for (i in 0...vertexData.length)
			v[i] = vertexData[i];
		vertices.unlock();
		vertexData = v;
		updateSpriteShadows(sprite);
	}

	@:access(s2d.objects.Sprite)
	function removeSprite(sprite:Sprite) {
		vertices.delete();
		vertices = new VertexBuffer(vertices.count() - sprite.shadowBuffersLength, @:privateAccess ShadowPass.structure, DynamicUsage);
		var v = vertices.lock();
		var c = 0;
		for (i in 0...v.length) {
			if (i < sprite.shadowBuffersOffset)
				v[i] = vertexData[i];
			else
				v[i] = vertexData[i + sprite.shadowBuffersLength];
		}
		vertices.unlock();
		vertexData = v;
	}

	@:access(s2d.objects.Sprite)
	function updateSpriteMesh(sprite:Sprite) {
		var vertexCount = 0;
		for (_ in sprite.mesh)
			vertexCount += 4;
		vertices.delete();
		vertices = new VertexBuffer(vertexCount - sprite.shadowBuffersLength, @:privateAccess ShadowPass.structure, DynamicUsage);
		sprite.shadowBuffersLength = vertexCount;
		var v = vertices.lock();
		var c = 0;
		for (i in 0...v.length) {
			if (i < sprite.shadowBuffersOffset)
				v[i] = vertexData[i];
			else
				v[i] = vertexData[i + sprite.shadowBuffersLength];
		}
		vertices.unlock();
		vertexData = v;
		updateSpriteShadows(sprite);
	}

	@:access(s2d.objects.Sprite)
	function mapSpriteShadows(sprite:Sprite, lightPos:FastVector2, lightDis:FastFloat) {
		final structSize = @:privateAccess ShadowPass.structure.byteSize() >> 2;
		final mvp = S2D.stage.viewProjection.multmat(sprite.finalModel);
		final nmodel = sprite.finalModel.inverse().transpose();

		var offset = sprite.shadowBuffersOffset;
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
					vertexData[offset + 2] = sprite.finalZ;
					vertexData[offset + 3] = sprite.shadowOpacity;
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
	function updateSpriteShadows(sprite:Sprite) {
		vertexData = vertices.lock();
		final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});
		final lightDis = light.radius * light.power;
		mapSpriteShadows(sprite, lightPos, lightDis);
		vertices.unlock();
	}

	function updateLightShadows() {
		final lightPos = S2D.world2LocalSpace({x: light.x, y: light.y});
		final lightDis = light.radius * light.power;
		vertexData = vertices.lock();
		for (sprite in light.layer.sprites)
			mapSpriteShadows(sprite, lightPos, lightDis);
		vertices.unlock();
	}
}
#end
