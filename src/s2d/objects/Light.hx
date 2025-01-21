package s2d.objects;

import kha.Color;

class Light extends StageObject {
	public var color:Color = Color.White;
	public var power:Float = 1.0;
	public var radius:Float = 1.0;
	#if (S2D_LIGHTING_DEFERRED == 1)
	public var volume:Float = 0.0;
	#end
	#if (S2D_LIGHTING_SHADOWS == 1)
	@:isVar public var isCastingShadows(default, set):Bool = false;
	#end

	public inline function new(layer:Layer) {
		super(layer);
		layer.addLight(this);
		#if (S2D_LIGHTING_SHADOWS == 1)
		isCastingShadows = true;
		#end
	}

	#if (S2D_LIGHTING_SHADOWS == 1)
	@:access(s2d.Layer)
	inline function set_isCastingShadows(value:Bool) {
		if (!isCastingShadows && value)
			layer.adjustShadowMaps(1);
		else if (isCastingShadows && !value)
			layer.adjustShadowMaps(-1);
		isCastingShadows = value;
		return value;
	}
	#end
}
