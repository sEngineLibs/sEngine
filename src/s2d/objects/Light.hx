package s2d.objects;

import kha.Color;
#if (S2D_LIGHTING_SHADOWS == 1)
import s2d.ShadowBuffers.LightShadowBuffer;
#end

class Light extends StageObject {
	public var color:Color = Color.White;
	public var power:Float = 15.0;
	public var radius:Float = 1.0;
	#if (S2D_LIGHTING_DEFERRED == 1)
	public var volume:Float = 0.0;
	#end

	#if (S2D_LIGHTING_SHADOWS == 1)
	var shadowBuffer:LightShadowBuffer;

	@:isVar public var isMappingShadows(default, set):Bool = false;

	function set_isMappingShadows(value:Bool) {
		if (!isMappingShadows && value)
			@:privateAccess layer.shadowBuffers.addLight(this);
		else if (isMappingShadows && !value)
			@:privateAccess layer.shadowBuffers.removeLight(this);
		isMappingShadows = value;
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
			@:privateAccess shadowBuffer.updateLightShadows();
		#end
	}
}
