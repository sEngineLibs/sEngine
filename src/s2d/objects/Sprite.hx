package s2d.objects;

#if (S2D_LIGHTING_SHADOWS == 1)
import haxe.ds.Vector;
#end
import kha.math.FastVector4;

class Sprite extends StageObject {
	public var cropRect:FastVector4 = new FastVector4(0.0, 0.0, 1.0, 1.0);
	#if (S2D_SPRITE_INSTANCING == 1)
	@:isVar public var atlas(default, set):SpriteAtlas;
	#else
	public var atlas:SpriteAtlas;
	#end
	#if (S2D_LIGHTING_SHADOWS == 1)
	public var isCastingShadows:Bool = true;
	public var shadowOpacity:Float = 1.0;
	@:isVar public var mesh(default, set):Vector<FastVector4> = new Vector(0);
	#end

	public inline function new(atlas:SpriteAtlas) {
		super(atlas.layer);
		this.atlas = atlas;
		layer.addSprite(this);
	}

	inline function reset() {}

	#if (S2D_SPRITE_INSTANCING == 1)
	inline function set_atlas(value:SpriteAtlas) {
		value.addSprite(this);
		atlas = value;
		return value;
	}
	#end

	#if (S2D_LIGHTING_SHADOWS == 1)
	@:access(s2d.Layer)
	inline function set_mesh(value:Vector<FastVector4>) {
		// each mesh edge produces 4 shadow vertices
		final d = (value.length - mesh.length) * 4;
		mesh = value;
		layer.adjustShadowBuffers(d);
		return value;
	}
	#end
}
