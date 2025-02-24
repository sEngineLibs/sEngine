package s2d.stage.objects;

import kha.FastFloat;
import s2d.PhysicalObject;

abstract class StageObject extends PhysicalObject<StageObject> {
	var layer:Layer;

	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;

	public function new(layer:Layer) {
		super(null);
		this.layer = layer;
	}

	function get_x():FastFloat {
		return this.transform.global.translationX;
	}

	function set_x(value:FastFloat):FastFloat {
		this.transform.global.translationX = value;
		return value;
	}

	function get_y():FastFloat {
		return this.transform.global.translationY;
	}

	function set_y(value:FastFloat):FastFloat {
		this.transform.global.translationY = value;
		return value;
	}
}
