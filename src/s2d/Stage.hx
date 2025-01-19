package s2d;

#if (S2D_RP_ENV_LIGHTING == 1)
import kha.Image;
#end
import s2d.math.Mat3;

@:access(s2d.objects.Object)
class Stage {
	public var layers:Array<Layer> = [];
	public var camera:Camera = new Camera();
	public var viewProjection(get, null):Mat3;

	public inline function new() {}

	inline function get_viewProjection() {
		return S2D.projection * camera;
	}

	#if (S2D_RP_ENV_LIGHTING == 1)
	@:isVar public var environmentMap(default, set):Image;

	inline function set_environmentMap(value:Image):Image {
		environmentMap = value;
		environmentMap.generateMipmaps(4);
		return value;
	}
	#end
}
