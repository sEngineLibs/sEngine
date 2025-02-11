package se.s2d.objects;

import kha.FastFloat;
import se.PhysicalObject2D;

abstract class StageObject extends PhysicalObject2D<StageObject> {
	var layer:Layer;

	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;

	public function new(layer:Layer) {
		super();
		this.layer = layer;
	}

	function onParentChanged() {}

	function get_x():FastFloat {
		return this.transform.translationX;
	}

	function set_x(value:FastFloat):FastFloat {
		this.transform.translationX = value;
		return value;
	}

	function get_y():FastFloat {
		return this.transform.translationY;
	}

	function set_y(value:FastFloat):FastFloat {
		this.transform.translationY = value;
		return value;
	}
}
