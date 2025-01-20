package s2d.objects;

// s2d
import kha.math.FastVector4;

@:access(s2d.graphics.Lighting)
class Sprite extends StageObject {
	public var cropRect:FastVector4 = new FastVector4(0.0, 0.0, 1.0, 1.0);

	public inline function new(atlas:SpriteAtlas) {
		super();
		this.atlas = atlas;
		atlas.layer.addSprite(this);
	}

	#if (S2D_SPRITE_INSTANCING != 1)
	public var atlas:SpriteAtlas;
	#else
	@:isVar public var atlas(default, set):SpriteAtlas;

	inline function set_atlas(value:SpriteAtlas) {
		value.addSprite(this);
		atlas = value;
		return value;
	}
	#end
}
