package s2d.objects;

import kha.Color;
#if (S2D_LIGHTING_SHADOWS == 1)
import haxe.ds.Vector;
import kha.math.FastVector2;
#end

class Light extends StageObject {
	public var color:Color = Color.White;
	public var power:Float = 1.0;
	public var radius:Float = 1.0;
	#if (S2D_LIGHTING_DEFERRED == 1)
	public var volume:Float = 0.0;
	#end

	public inline function new(layer:Layer) {
		super();
		layer.addLight(this);
	}
}
