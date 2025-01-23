package s2d.objects;

import kha.Color;

class Light extends StageObject {
	public var color:Color = Color.White;
	public var power:Float = 15.0;
	public var radius:Float = 1.0;
	#if (S2D_LIGHTING_DEFERRED == 1)
	public var volume:Float = 0.0;
	#end

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowMapIndex:Int = -1;

	@:isVar public var isMappingShadows(default, set):Bool = false;

	@:access(s2d.Layer)
	function set_isMappingShadows(value:Bool) {
		isMappingShadows = value;
		layer.adjustShadowMaps(this);
		return value;
	}
	#end

	public function new(layer:Layer) {
		super(layer);
		layer.addLight(this);
	}

	function onZChanged() {}

	function onTransformationChanged() {
		#if (S2D_LIGHTING_SHADOWS == 1)
		if (isMappingShadows)
			@:privateAccess layer.drawLightShadows(this);
		#end
	}
}
