package s2d.stage;

import se.math.Mat3;
import se.math.VectorMath;

@:forward(rotation)
abstract Camera(Transform) from Transform to Transform {
	public var x(get, set):Float;
	public var y(get, set):Float;

	public function new() {
		this = Mat3.lookAt({x: 0.0, y: 0.0}, {x: 0.0, y: -1.0}, {x: 0.0, y: 1.0});
	}

	function get_x():Float {
		return this.global.translationX;
	}

	inline function set_x(value:Float):Float {
		this.global.translationX = value;
		return value;
	}

	function get_y():Float {
		return this.global.translationY;
	}

	inline function set_y(value:Float):Float {
		this.global.translationY = value;
		return value;
	}
}
