package s2d.objects;

import haxe.ds.Vector;
import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastVector4;
#if (S2D_LIGHTING_SHADOWS == 1)
import s2d.graphics.lighting.ShadowPass;
#end

using s2d.core.utils.extensions.VectorExt;

class Sprite extends StageObject {
	var index:UInt;
	var mesh:Vector<Edge> = new Vector(0);

	public var cropRect:FastVector4 = new FastVector4(0.0, 0.0, 1.0, 1.0);
	#if (S2D_SPRITE_INSTANCING == 1)
	@:isVar public var atlas(default, set):SpriteAtlas;
	#else
	public var atlas:SpriteAtlas;
	#end

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffersOffset:UInt;
	var shadowBuffersLength:UInt;

	@:isVar public var isCastingShadows(default, set):Bool = false;
	@:isVar public var shadowOpacity(default, set):Float = 1.0;

	function set_isCastingShadows(value:Bool) {
		if (!isCastingShadows && value)
			@:privateAccess layer.shadowBuffers.addSprite(this);
		else if (isCastingShadows && !value)
			@:privateAccess layer.shadowBuffers.removeSprite(this);
		isCastingShadows = value;
		return value;
	}

	function set_shadowOpacity(value:Float) {
		shadowOpacity = value;
		updateShadowBuffersValue(3, shadowOpacity);
		return value;
	}
	#end

	public function new(atlas:SpriteAtlas) {
		super(atlas.layer);
		this.atlas = atlas;
		layer.addSprite(this);
	}

	public function setMesh(value:Array<Array<FastVector2>>) {
		var edgeCounter = 0;
		for (p in value)
			edgeCounter += p.length;
		final d = edgeCounter - mesh.length;

		// build mesh
		mesh = new Vector(edgeCounter);
		var offset = 0;
		for (j in 0...value.length) {
			final m = value[j];
			for (i in 0...m.length) {
				var v1 = m[i];
				var v2 = m[(i + 1) % m.length];
				var edgeNormal = computeNormal(v1, v2, m);
				mesh[offset + i] = new Edge(v1, v2, edgeNormal);
			}
			offset += m.length;
		}

		#if (S2D_LIGHTING_SHADOWS == 1)
		// extend layer shadow buffers if needed
		if (d != 0)
			@:privateAccess layer.shadowBuffers.updateSpriteMesh(this);
		#end
	}

	function computeNormal(v1:FastVector2, v2:FastVector2, polygon:Array<FastVector2>):FastVector2 {
		var dx = v2.x - v1.x;
		var dy = v2.y - v1.y;

		var normal = new FastVector2(-dy, dx);
		var prevEdge = polygon[(polygon.indexOf(v1) - 1 + polygon.length) % polygon.length];
		var nextEdge = polygon[(polygon.indexOf(v2) + 1) % polygon.length];

		// crossproduct
		if ((nextEdge.x - v2.x) * (prevEdge.y - v1.y) - (nextEdge.y - v2.y) * (prevEdge.x - v1.x) < 0) {
			normal.x = -normal.x;
			normal.y = -normal.y;
		}

		return normal.normalized();
	}

	#if (S2D_LIGHTING_SHADOWS == 1)
	function updateShadowBuffersValue(index:Int, value:FastFloat) {
		final structSize = @:privateAccess ShadowPass.structure.byteSize() >> 2;
		var offset = shadowBuffersOffset;
		for (buffer in @:privateAccess layer.shadowBuffers.buffers) {
			final v = @:privateAccess buffer.vertexData;
			for (_ in mesh) {
				for (i in 0...4) {
					v[offset + index] = value;
					offset += structSize;
				}
			}
		}
	}
	#end

	function onZChanged() {
		// rearrange layer sprites
		var i = 0;
		for (sprite in layer.sprites) {
			if (sprite.finalZ <= finalZ) {
				layer.sprites.rearrange(index, i);
				index = i;
				break;
			}
			++i;
		}
		// update corresponding shadow vertices if needed
		#if (S2D_LIGHTING_SHADOWS == 1)
		if (isCastingShadows)
			updateShadowBuffersValue(2, finalZ);
		#end
	}

	function onTransformationChanged() {
		#if (S2D_LIGHTING_SHADOWS == 1)
		if (isCastingShadows)
			@:privateAccess layer.shadowBuffers.updateSpriteShadows(this);
		#end
	}

	#if (S2D_SPRITE_INSTANCING == 1)
	function set_atlas(value:SpriteAtlas) {
		value.addSprite(this);
		atlas = value;
		return value;
	}
	#end
}

@:structInit
class Edge {
	public var v1:FastVector2;
	public var v2:FastVector2;
	public var normal:FastVector2;

	public function new(v1:FastVector2, v2:FastVector2, normal:FastVector2) {
		this.v1 = v1;
		this.v2 = v2;
		this.normal = normal;
	}
}
