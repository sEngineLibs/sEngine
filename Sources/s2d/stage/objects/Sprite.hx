package s2d.stage.objects;

import se.math.Vec2;
import se.math.Vec4;
import s2d.geometry.Mesh;

using se.extensions.VectorExt;

class Sprite extends StageObject {
	var _id:UInt;

	public var mesh:Mesh;
	public var cropRect:Vec4 = new Vec4(0.0, 0.0, 1.0, 1.0);
	#if (S2D_SPRITE_INSTANCING == 1)
	@:isVar public var atlas(default, set):SpriteAtlas;
	#else
	public var atlas:SpriteAtlas;
	#end

	#if (S2D_LIGHTING && S2D_LIGHTING_SHADOWS == 1)
	@:isVar public var isCastingShadows(default, set):Bool = false;
	public var shadowOpacity:Float = 1.0;

	function set_isCastingShadows(value:Bool) {
		if (!isCastingShadows && value)
			@:privateAccess layer.shadowBuffer.addSprite(this);
		else if (isCastingShadows && !value)
			@:privateAccess layer.shadowBuffer.removeSprite(this);
		isCastingShadows = value;
		return value;
	}
	#end

	public function new(atlas:SpriteAtlas, ?polygons:Array<Vec2>) {
		super(atlas.layer);
		layer.addSprite(this);
		this.atlas = atlas;
		if (polygons != null)
			this.mesh = polygons;
	}

	#if (S2D_SPRITE_INSTANCING == 1)
	function set_atlas(value:SpriteAtlas) {
		value.addSprite(this);
		atlas = value;
		return value;
	}
	#end
}
