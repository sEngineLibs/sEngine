package s2d;

import kha.FastFloat;
// s2d
import s2d.math.Mat3;

@:forward(rotation)
abstract Camera(Mat3) from Mat3 to Mat3 {
	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;

	public function new() {
		this = Mat3.lookAt({x: 0.0, y: 0.0}, {x: 0.0, y: -1.0}, {x: 0.0, y: 1.0});
	}

	function get_x():FastFloat {
		return this.translationX;
	}

	function set_x(value:FastFloat):FastFloat {
		this.translationX = value;
		return value;
	}

	function get_y():FastFloat {
		return this.translationY;
	}

	function set_y(value:FastFloat):FastFloat {
		this.translationY = value;
		return value;
	}
}
