package s2d.objects;

import kha.math.FastVector2;
import kha.math.FastVector4;
// s2d
import s2d.geometry.Mesh;

using s2d.core.extensions.VectorExt;

class Sprite extends StageObject {
	var index:UInt;

	public var mesh:Mesh;
	public var cropRect:FastVector4 = new FastVector4(0.0, 0.0, 1.0, 1.0);
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

	public function new(atlas:SpriteAtlas, ?polygons:Array<FastVector2>) {
		super(atlas.layer);
		layer.addSprite(this);
		this.atlas = atlas;
		if (polygons != null)
			this.mesh = polygons;
	}

	function onZChanged() {
		var i = 0;
		for (sprite in layer.sprites) {
			if (sprite.finalZ <= finalZ) {
				layer.sprites.rearrange(index, i);
				index = i;
				break;
			}
			++i;
		}
	}

	function onTransformationChanged() {}

	#if (S2D_SPRITE_INSTANCING == 1)
	function set_atlas(value:SpriteAtlas) {
		value.addSprite(this);
		atlas = value;
		return value;
	}
	#end
}
