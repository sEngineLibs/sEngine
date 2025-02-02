package s2d;

#if (S2D_LIGHTING_ENVIRONMENT == 1)
import kha.Image;
#end
import s2d.math.Mat3;

@:access(s2d.objects.Object)
class Stage {
	public var layers:Array<Layer> = [];
	public var camera:Camera = new Camera();
	public var viewProjection:Mat3;

	public function new() {}

	public function updateViewProjection() {
		viewProjection = S2D.projection * camera;
	}

	#if (S2D_LIGHTING_ENVIRONMENT == 1)
	@:isVar public var environmentMap(default, set):Image;

	function set_environmentMap(value:Image):Image {
		environmentMap = value;
		environmentMap.generateMipmaps(4);
		return value;
	}
	#end
}
