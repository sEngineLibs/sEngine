package s2d.objects;

import kha.math.FastVector2;
#if (S2D_LIGHTING_SHADOWS == 1)
import haxe.ds.Vector;
#end
import kha.math.FastVector4;

using s2d.core.utils.extensions.VectorExt;

class Sprite extends StageObject {
	var index:Int = -1;
	var mesh:Vector<Edge> = new Vector(0);

	public var cropRect:FastVector4 = new FastVector4(0.0, 0.0, 1.0, 1.0);
	#if (S2D_SPRITE_INSTANCING == 1)
	@:isVar public var atlas(default, set):SpriteAtlas;
	#else
	public var atlas:SpriteAtlas;
	#end
	#if (S2D_LIGHTING_SHADOWS == 1)
	public var isCastingShadows:Bool = true;
	public var shadowOpacity:Float = 1.0;
	#end

	public inline function new(atlas:SpriteAtlas) {
		super(atlas.layer);
		this.atlas = atlas;
		layer.addSprite(this);
	}

	public inline function setMesh(value:Array<Array<FastVector2>>) {
		var edgeCounter = 0;
		for (m in value)
			edgeCounter += m.length;

		#if (S2D_LIGHTING_SHADOWS == 1)
		// extend layer shadow buffers if needed
		final d = edgeCounter - mesh.length;
		if (d != 0)
			@:privateAccess layer.adjustShadowBuffers(d * 4);
		#end

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
	}

	private function computeNormal(v1:FastVector2, v2:FastVector2, polygon:Array<FastVector2>):FastVector2 {
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

	inline function onZChanged() {
		var i = 0;
		for (sprite in layer.sprites) {
			if (sprite.finalZ >= z) {
				layer.sprites.rearrange(index, i);
				index = i;
				return;
			}
			++i;
		}
	}

	inline function onTransformationChanged() {
		#if (S2D_LIGHTING_SHADOWS == 1)
		@:privateAccess layer.drawLayerShadows();
		#end
	}

	#if (S2D_SPRITE_INSTANCING == 1)
	inline function set_atlas(value:SpriteAtlas) {
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

	public inline function new(v1:FastVector2, v2:FastVector2, normal:FastVector2) {
		this.v1 = v1;
		this.v2 = v2;
		this.normal = normal;
	}
}
