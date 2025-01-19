package s2d.objects;

// s2d
import s2d.math.Vec4;

@:access(s2d.graphics.Lighting)
class Sprite extends Object {
	public var cropRect:Vec4 = new Vec4(0.0, 0.0, 1.0, 1.0);

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
