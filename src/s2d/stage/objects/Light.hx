package s2d.stage.objects;

#if (S2D_LIGHTING == 1)
import se.Color;

class Light extends LayerObject {
	public var color:Color = "white";
	public var power:Float = 15.0;
	public var radius:Float = 1.0;
	#if (S2D_LIGHTING_SHADOWS == 1)
	public var isMappingShadows:Bool = false;
	#end

	public function new(layer:StageLayer) {
		super(layer);
		layer.addLight(this);
	}
}
#end
