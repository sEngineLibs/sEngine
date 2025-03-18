package s2d.stage;

import s2d.elements.Canvas;
#if (S2D_LIGHTING_ENVIRONMENT == 1)
import kha.Image;
#end
import se.SEngine;
import se.math.Vec2;
import se.math.Mat3;
import se.math.VectorMath;

@:access(s2d.stage.objects.Object)
class Stage extends Canvas {
	public static var current:Stage;

	public var layers:Array<Layer> = [];
	public var camera:Camera = new Camera();
	public var viewProjection:Mat3;

	public function updateViewProjection() {
		viewProjection = SEngine.projection * camera.view;
	}

	public static function local2WorldSpace(point:Vec2):Vec2 {
		var p:Vec2 = (inverse(Stage.current.viewProjection) * vec3(point, 1.0)).xy;
		return p;
	}

	public static function world2LocalSpace(point:Vec2):Vec2 {
		var p:Vec2 = (Stage.current.viewProjection * vec3(point, 1.0)).xy;
		return p;
	}

	public static function screen2LocalSpace(point:Vec2):Vec2 {
		return vec2(point.x / SEngine.width, point.y / SEngine.height) * 2.0 - 1.0;
	}

	public static function local2ScreenSpace(point:Vec2):Vec2 {
		return vec2(point.x * SEngine.width, point.y * SEngine.height) * 0.5 - 0.5;
	}

	public static function screen2WorldSpace(point:Vec2):Vec2 {
		return local2WorldSpace(screen2LocalSpace(point));
	}

	public static function world2ScreenSpace(point:Vec2):Vec2 {
		return local2ScreenSpace(world2LocalSpace(point));
	}

	#if (S2D_LIGHTING_ENVIRONMENT == 1)
	@:isVar public var environmentMap(default, set):Image;

	private function set_environmentMap(value:Image):Image {
		environmentMap = value;
		environmentMap.generateMipmaps(4);
		return value;
	}
	#end
}
