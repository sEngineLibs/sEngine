package s2d.objects;

#if (S2D_LIGHTING_SHADOWS == 1)
import haxe.ds.Vector;
import kha.math.FastVector2;
#end
import kha.math.FastVector4;

@:access(s2d.graphics.Lighting)
class Sprite extends StageObject {
	public var cropRect:FastVector4 = new FastVector4(0.0, 0.0, 1.0, 1.0);

	#if (S2D_SPRITE_INSTANCING == 1)
	@:isVar public var atlas(default, set):SpriteAtlas;

	inline function set_atlas(value:SpriteAtlas) {
		value.addSprite(this);
		atlas = value;
		return value;
	}
	#else
	public var atlas:SpriteAtlas;
	#end

	#if (S2D_LIGHTING_SHADOWS == 1)
	public var shadowVertices:Vector<FastVector2> = new Vector(0);
	#end

	public inline function new(atlas:SpriteAtlas) {
		super();
		this.atlas = atlas;
		atlas.layer.addSprite(this);
	}
}
